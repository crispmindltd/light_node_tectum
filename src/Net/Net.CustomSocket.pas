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
      FID: String;
      FFullReceived: String;
      FResponses: TStringList;
      FSendLock, FReceiveLock: TCriticalSection;

      function GetAnswer(AReqID: String): String;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Connect(AAddress: String = '185.180.223.168'; APort: Word = 8760);
      function DoRequest(AReqID,ARequest: String): String;
      procedure Disconnect;
  end;

implementation

{ TCustomSocket }

procedure TCustomSocket.Connect(AAddress: String; APort: Word);
var
  splt: TArray<String>;
begin
  if TSocketState.Connected in State then exit;

  try
    inherited Connect('',AAddress,'',APort);
    Sleep(500);

    splt := ReceiveString.Split([' ']);
    FID := splt[1];
    Logs.DoLog(Format('Connected to remote,ID=%s',[FID]),NONE);
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
      Close(True);
    {$ELSE IFDEF LINUX}
      Close;
    {$ENDIF}

    Logs.DoLog(Format('<Remote %s> disonnected',[FID]),NONE);
  end;
end;

function TCustomSocket.DoRequest(AReqID,ARequest: String): String;
var
  timeout: TDateTime;
begin
  Logs.DoLog(Format('<Remote %s>[%s] %s',[FID,AReqID,ARequest]),OUTGO,tcp);
  FSendLock.Enter;
  try
    Send(AnsiString(TrimRight(Format('%s %s',[ARequest,AReqID])))+#13);
    Sleep(100);
  finally
    FSendLock.Leave;
  end;

  FReceiveLock.Enter;
  timeout := IncMilliSecond(Now, RECEIVE_ANSWER_TIMEOUT);
  try
    repeat
      FFullReceived := ReceiveString;
      while not (FFullReceived.EndsWith(#13#10) or (Now < timeout)) do
      begin
        if Now > timeout then
        begin
          Logs.DoLog(Format('<Remote %s>[%s] did not respond',[FID,AReqID]),ERROR,tcp);
          raise ESocketError.Create('Server did not respond');
        end;
        FFullReceived := FFullReceived + ReceiveString;
      end;
      Result := GetAnswer(AReqID);
    until not Result.IsEmpty;
    Logs.DoLog(Format('<Remote %s>[%s] %s',[FID,AReqID,Result]),INCOM,tcp);
  finally
    FReceiveLock.Leave;
  end;
end;

function TCustomSocket.GetAnswer(AReqID: String): String;
var
  i: Integer;
begin
  Result := '';
  FResponses.AddStrings(FFullReceived.Split([#13#10]));
  FFullReceived := '';
  for i := 0 to FResponses.Count-1 do
    if FResponses.Strings[i].Contains(AReqID) then
    begin
      Result := FResponses.Strings[i].Trim;
      FResponses.Delete(i);
      break;
    end;
end;

end.
