unit Sync.Base;

interface

uses
  App.Exceptions,
  App.Intf,
  App.Logs,
  Classes,
  Math,
  Net.Socket,
  SyncObjs,
  SysUtils;

type
  TSyncChain = class(TThread)
    const
      REQUEST_LONG_DELAY = 4000;
      REQUEST_SHORT_DELAY = 100;
      RECEIVE_TIMEOUT = 10000;
      RECONNECT_ATTEMPTS = 3;
    private
      FIsError: Boolean;

      function GetNodeAddress: String;
    protected
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
      procedure GetResponse(var Bytes: array of Byte; Count: Integer);
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

procedure TSyncChain.GetResponse(var Bytes: array of Byte; Count: Integer);
var
  StartTime: Cardinal;
  toReceiveTotal,toReceiveNow,receivedTotal: Integer;
  rec: array of Byte;
begin
  StartTime := GetTickCount;
  toReceiveTotal := Count;
  receivedTotal := 0;
  while Count > 0 do
  begin
    while FSocket.ReceiveLength = 0 do
    begin
      if Terminated then exit;
      if IsTimeout(StartTime,RECEIVE_TIMEOUT) then
        raise EReceiveTimeout.Create('');
      Sleep(100);
    end;

    toReceiveNow := Min(Count,FSocket.ReceiveLength);
    SetLength(rec,toReceiveNow);
    FSocket.Receive(rec,0,toReceiveNow,[TSocketFlag.WAITALL]);
    Dec(Count,toReceiveNow);
    Move(rec[0],Bytes[receivedTotal],toReceiveNow);
    Inc(receivedTotal,toReceiveNow);
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
