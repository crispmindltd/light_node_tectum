unit Net.CustomSocket;

interface

uses
  App.Logs,
  Classes,
  DateUtils,
  Net.Socket,
  SyncObjs,
  SysUtils;

type
  TCustomSocket = class(TSocket)
    const
      RECEIVE_ANSWER_TIMEOUT = 15000;
    private
      FID: string;
      FFullReceived: string;
      FResponses: TStringList;
      FSendLock, FReceiveLock: TCriticalSection;

      function GetAnswer(AReqID: string): string;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Connect(AAddress: string = '185.180.223.168'; APort: Word = 8760);
      function DoRequest(AReqID, ARequest: string): string;
      procedure Disconnect;
  end;

implementation

{ TCustomSocket }

procedure TCustomSocket.Connect(AAddress: string; APort: Word);
var
  Splitted: TArray<string>;
begin
  if TSocketState.Connected in State then
    exit;

  try
    inherited Connect('', AAddress, '', APort);
    Sleep(500);

    Splitted := ReceiveString.Split([' ']);
    FID := Splitted[1];
    Logs.DoLog(Format('Connected to remote, ID = %s', [FID]), NONE);
  except
    raise ESocketError.Create('');
  end;
end;

constructor TCustomSocket.Create;
begin
  inherited Create(TSocketType.TCP, TEncoding.ANSI);

  FSendLock := TCriticalSection.Create;
  FReceiveLock := TCriticalSection.Create;
  FResponses := TStringList.Create;
  FResponses.Capacity := 100;
  FFullReceived := '';
end;

destructor TCustomSocket.Destroy;
begin
  FResponses.Free;
  FReceiveLock.Free;
  FSendLock.Free;
end;

procedure TCustomSocket.Disconnect;
begin
  if TSocketState.Connected in State then
  begin
    {$IFDEF MSWINDOWS}
      Close;
    {$ELSE IFDEF LINUX}
      Close(True);
    {$ENDIF}

    Logs.DoLog(Format('<Remote %s> disonnected', [FID]), NONE);
  end;
end;

function TCustomSocket.DoRequest(AReqID, ARequest: string): string;
var
  Timeout: TDateTime;
begin
  Logs.DoLog(Format('<Remote %s>[%s] %s', [FID, AReqID, ARequest]), OUTGO, tcp);
  FSendLock.Enter;
  try
    Send(Ansistring(TrimRight(Format('%s %s', [ARequest, AReqID]))) + #13);
    Sleep(100);
  finally
    FSendLock.Leave;
  end;

  FReceiveLock.Enter;
  Timeout := IncMilliSecond(Now, RECEIVE_ANSWER_TIMEOUT);
  try
    repeat
      FFullReceived := Receivestring;
      while not (FFullReceived.EndsWith(#13#10) or (Now < Timeout)) do
      begin
        if Now > Timeout then
        begin
          Logs.DoLog(Format('<Remote %s>[%s] did not respond', [FID, AReqID]), ERROR, tcp);
          raise ESocketError.Create('Server did not respond');
        end;
        FFullReceived := FFullReceived + ReceiveString;
      end;
      Result := GetAnswer(AReqID);
    until not Result.IsEmpty;
    Logs.DoLog(Format('<Remote %s>[%s] %s', [FID, AReqID, Result]), INCOM, tcp);
  finally
    FReceiveLock.Leave;
  end;
end;

function TCustomSocket.GetAnswer(AReqID: string): string;
var
  i: Integer;
begin
  Result := '';
  FResponses.Addstrings(FFullReceived.Split([#13#10]));
  FFullReceived := '';
  for i := 0 to FResponses.Count-1 do
    if FResponses.strings[i].Contains(AReqID) then
    begin
      Result := FResponses.Strings[i].Trim;
      FResponses.Delete(i);
      break;
    end;
end;

end.
