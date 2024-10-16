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
      RequestLongDelay = 3000;
      RequestTokenDelay = 1500;
      RequestShortDelay = 100;
      ReceiveTimeout = 10000;
      ReconnectAttempts = 3;
    private
      FIsError: Boolean;

      function Connect: Boolean;
      procedure Disconnect;
      function GetNodeAddress: string;
    protected
      FBytesRequest: array[0..8] of Byte;
      FSocket: TSocket;
      FName: string;
      FAddress: string;
      FPort: Word;
      FNeedDelay: Boolean;
      FDone: TEvent;

      procedure Execute; override;
      procedure GetResponse(var ABytes: array of Byte);
      procedure BreakableSleep(ADelayDuration: Integer);
      function DoTryReconnect: Boolean;
      procedure DoCantReconnect;
    public
      constructor Create(AName, AAddress: string; APort: Word);
      destructor Destroy; override;

      property IsError: Boolean read FIsError write FIsError;
      property SyncDoneEvent: TEvent write FDone;
      property Address: string read GetNodeAddress;
      property Name: string read FName;
  end;

implementation

{ TSyncChain }

procedure TSyncChain.BreakableSleep(ADelayDuration: Integer);
var
  DelayValue: Integer;
begin
  repeat
    DelayValue := Min(ADelayDuration, 1000);
    Sleep(DelayValue);
    Dec(ADelayDuration, DelayValue);
  until Terminated or (ADelayDuration = 0);
end;

function TSyncChain.Connect: Boolean;
begin
  Result := True;
  try
    FSocket.Connect('', FAddress, '', FPort);
  except
    Result := False;
  end;
end;

constructor TSyncChain.Create(AName, AAddress: string; APort: Word);
begin
  inherited Create(True);

  FreeOnTerminate := True;
  FSocket := TSocket.Create(TSocketType.TCP, TEncoding.ANSI);
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
  Logs.DoLog(Format('<%s> Cant reconnect', [Name]), ERROR);
  FIsError := True;
end;

function TSyncChain.DoTryReconnect: Boolean;
var
  i: Integer;
begin
  Logs.DoLog(Format('<%s> Reconnect...', [Name]), NONE);
  Disconnect;
  i := 1;
  repeat
    BreakableSleep(1000 * i);
    if Terminated then
      exit(True);

    Result := Connect;
    if Result then
      Logs.DoLog(Format('<%s> Connection restored', [Name]), NONE);

    Inc(i);
  until Result or (i = ReconnectAttempts + 1);
end;

procedure TSyncChain.Execute;
begin
  inherited;

  FDone.ResetEvent;
  if not Connect then
  begin
    Logs.DoLog(Format('<%s> Cant connect to %s', [Name, Address]), ERROR);
    FIsError := True;
    BreakableSleep(5000);
    exit;
  end;

  Logs.DoLog(Format('<%s> Connected to %s', [Name, Address]), NONE);
end;

function TSyncChain.GetNodeAddress: string;
begin
  Result := Format('%s:%d', [FSocket.Endpoint.Address.Address,
    FSocket.Endpoint.Port]);
end;

procedure TSyncChain.GetResponse(var ABytes: array of Byte);
var
  StartTime: Cardinal;
  ToReceive, ReceivedPart, ReceivedTotal: Integer;
begin
  StartTime := GetTickCount;
  ReceivedTotal := 0;
  ToReceive := Length(ABytes);
  while ToReceive > 0 do
  begin
    while FSocket.ReceiveLength = 0 do
    begin
      if Terminated then
        exit;
      if IsTimeout(StartTime, ReceiveTimeout) then
        raise EReceiveTimeout.Create('');
      Sleep(50);
    end;

    ReceivedPart := Min(ToReceive, FSocket.ReceiveLength);
    FSocket.Receive(ABytes, ReceivedTotal, ReceivedPart, [TSocketFlag.WAITALL]);
    Dec(ToReceive, ReceivedPart);
    Inc(ReceivedTotal, ReceivedPart);
  end;
end;

end.
