unit Sync.Base;

interface

uses
  App.Exceptions,
  App.Intf,
  App.Logs,
  Blockchain.BaseTypes,
  Classes,
  Math,
  Net.Socket,
  SyncObjs,
  SysUtils;

type
  TSyncChain = class(TThread)
    const
      RequestLongDelay = 4000;
      RequestShortDelay = 100;
      RECEIVE_TIMEOUT = 10000000;
      RECONNECT_ATTEMPTS = 3;
    private
      FIsError: Boolean;
      function GetNodeAddress: String;
    protected
      FBytesRequest: array[0..8] of Byte;
      FSocket: TSocket;
      FName: String;
      FAddress: String;
      FPort: Word;
      FNeedDelay: Boolean;
      FDone: TEvent;

      procedure Execute; override;

      function Connect: Boolean;
      procedure Disconnect;
      function Reconnect: Boolean;
      procedure GetResponse(var ABytes: array of Byte);
      procedure BreakableSleep(ADelay: Integer);
      function DoTryReconnect: Boolean;
      procedure DoCantReconnect;
    public
      constructor Create(AName,AAddress: String; APort: Word);
      destructor Destroy; override;

      property IsError: Boolean read FIsError write FIsError;
      property SyncDoneEvent: TEvent write FDone;
      property Address: String read GetNodeAddress;
      property Name: String read FName;
  end;

implementation

procedure TSyncChain.BreakableSleep(ADelay: Integer);
var
  amount: Integer;
begin
  repeat
    amount := Min(ADelay,1000);
    Sleep(amount);
    Dec(ADelay,amount);
  until Terminated or (ADelay = 0);
end;

function TSyncChain.Connect: Boolean;
begin
  Result := True;
  try
    FSocket.Connect('',FAddress,'',FPort);
  except
    Result := False;
  end;
end;

{ TSuncChain }

constructor TSyncChain.Create(AName,AAddress: String; APort: Word);
begin
  inherited Create(True);

  FreeOnTerminate := True;
  FSocket := TSocket.Create(TSocketType.TCP,TEncoding.ANSI);

  FAddress := AAddress;
  FPort := APort;
  FName := AName;
  FNeedDelay := False;
  FIsError := False;
end;

destructor TSyncChain.Destroy;
begin
  Disconnect;
  FSocket.Free;

  inherited;
end;

procedure TSyncChain.Disconnect;
begin
  if TSocketState.Connected in FSocket.State then
  {$IFDEF MSWINDOWS}
    FSocket.Close(True);
  {$ELSE IFDEF LINUX}
    FSocket.Close;
  {$ENDIF}
end;

procedure TSyncChain.DoCantReconnect;
begin
  Logs.DoLog(Format('<%s> Cant reconnect',[Name]),ERROR);
  FIsError := True;
end;

function TSyncChain.DoTryReconnect: Boolean;
begin
  Logs.DoLog(Format('<%s> Reconnect...',[Name]),NONE);
  Result := Reconnect;
end;

procedure TSyncChain.Execute;
begin
  inherited;

  FDone.ResetEvent;
  if not Connect then
  begin
    Logs.DoLog(Format('<%s> Cant connect to %s',[Name,Address]),ERROR);
    FIsError := True;
    BreakableSleep(5000);
    exit;
  end;

  Logs.DoLog(Format('<%s> Connected to %s',[Name,Address]),NONE);
end;

function TSyncChain.GetNodeAddress: String;
begin
  Result := Format('%s:%d',[FSocket.Endpoint.Address.Address,FSocket.Endpoint.Port]);
end;

procedure TSyncChain.GetResponse(var ABytes: array of Byte);
var
  StartTime: Cardinal;
  ToReceiveTotal,ReceivedNow,ReceivedTotal: Int64;
begin
  StartTime := GetTickCount;
  ReceivedTotal := 0;
  ToReceiveTotal := Length(ABytes);
  while ToReceiveTotal > 0 do
  begin
    while FSocket.ReceiveLength = 0 do
    begin
      if Terminated then exit;
      if IsTimeout(StartTime,RECEIVE_TIMEOUT) then
        raise EReceiveTimeout.Create('');
      Sleep(50);
    end;

    ReceivedNow := Min(ToReceiveTotal,FSocket.ReceiveLength);
    FSocket.Receive(ABytes,ReceivedTotal,ReceivedNow,[TSocketFlag.WAITALL]);
    Dec(ToReceiveTotal,ReceivedNow);
    Inc(ReceivedTotal,ReceivedNow);
  end;
end;

function TSyncChain.Reconnect: Boolean;
var
  i: Integer;
begin
  Disconnect;

  i := 1;
  repeat
    BreakableSleep(1000 * i);
    if Terminated then Exit(True);

    Result := Connect;
    if Result then
      Logs.DoLog(Format('<%s> Connection restored',[Name]),NONE);

    Inc(i);
  until (i = RECONNECT_ATTEMPTS + 1) or Result;
end;

end.
