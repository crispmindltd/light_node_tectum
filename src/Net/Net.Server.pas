unit Net.Server;

interface

uses
  App.Intf,
  App.Logs,
  Classes,
  Net.ConnectedClient,
  Net.Socket,
  SyncObjs,
  SysUtils,
  Types;

type
  TServerStatus = (ssStarted, ssShuttingDown, ssStoped);

  TNodeServer = class
    strict private
      FAddress: string;
      FPort: Word;
      FClients: TList;
      FLock: TCriticalSection;
      FValidInProgressList: TStringList;
    private
      FListenSocket: TSocket;
      FServerStoped: TEvent;
      FStatus: TServerStatus;

      procedure AcceptCallback(const ASyncResult: IAsyncResult);
      procedure AcceptConnections;
      procedure DisconnectClient(ID: Integer);

      function ValidationBegin(AValue: string): Boolean;
      procedure ValidationDone(const AValue: string);
    public
      constructor Create;
      destructor Destroy; override;

      procedure Start(AAddress: string; APort: Word);
      procedure Stop;
  end;

implementation

{ TNodeServer }

procedure TNodeServer.AcceptCallback(const ASyncResult: IAsyncResult);
var
  FAcceptedSocket: TSocket;
  NewClient: TConnectedClient;
begin
  FAcceptedSocket := FListenSocket.EndAccept(ASyncResult);
  if Assigned(FAcceptedSocket) then
  begin
    NewClient := TConnectedClient.Create(FAcceptedSocket,ValidationBegin,ValidationDone);
    FClients.Add(NewClient);
    FListenSocket.BeginAccept(AcceptCallback, INFINITE);
  end else
    FStatus := ssShuttingDown;
end;

constructor TNodeServer.Create;
begin
  FClients := TList.Create;
  FValidInProgressList := TStringList.Create(dupError,False,False);
  FLock := TCriticalSection.Create;
  FListenSocket := TSocket.Create(TSocketType.TCP,TEncoding.ANSI);
  FServerStoped := TEvent.Create;
  FServerStoped.ResetEvent;
  FStatus := ssStoped;
end;

destructor TNodeServer.Destroy;
begin
  Stop;
  FClients.Clear;
  FClients.Free;
  FLock.Free;
  FValidInProgressList.Free;
  FServerStoped.Free;
  FListenSocket.Free;

  inherited;
end;

procedure TNodeServer.DisconnectClient(ID: Integer);
var
  Client: TConnectedClient;
begin
  Client := TConnectedClient(FClients[ID]);
  Client.Terminate;
  Client.WaitFor;
  Client.Free;
  FClients.Delete(ID);
end;

procedure TNodeServer.AcceptConnections;
begin
  FListenSocket.Listen(FAddress, '', FPort);
  FListenSocket.BeginAccept(AcceptCallback, INFINITE);

  TThread.CreateAnonymousThread(
    procedure
    var
      i: Integer;
    begin
      repeat
        Sleep(200);
        i := 0;
        while i <> FClients.Count do
        begin
          if not TConnectedClient(FClients.Items[i]).isActual or
            (FStatus = ssShuttingDown) then
            DisconnectClient(i)
          else
            Inc(i);
        end;
      until (FClients.Count = 0) and (FStatus = ssShuttingDown);

      FServerStoped.SetEvent;
    end).Start;
end;

procedure TNodeServer.Start(AAddress: string; APort: Word);
begin
  if FStatus <> ssStoped then exit;

  FAddress := AAddress;
  FPort := APort;

  AcceptConnections;
  FStatus := ssStarted;
end;

procedure TNodeServer.Stop;
begin
  if FStatus <> ssStarted then exit;

  if TSocketState.Connected in FListenSocket.State then
  {$IFDEF MSWINDOWS}
    FListenSocket.Close(True);
  {$ELSE IFDEF LINUX}
    FListenSocket.Close;
  {$ENDIF}

  FServerStoped.WaitFor(10000);
  FStatus := ssStoped;
end;

function TNodeServer.ValidationBegin(AValue: string): Boolean;
var
  Index: Integer;
begin
  FLock.Enter;
  try
    Index := FValidInProgressList.IndexOf(AValue);
    Result := Index = -1;
    if Result then
      FValidInProgressList.Add(AValue);
  finally
    FLock.Leave;
  end;
end;

procedure TNodeServer.ValidationDone(const AValue: string);
var
  Index: Integer;
begin
  FLock.Enter;
  try
    Index := FValidInProgressList.IndexOf(AValue);
    if Index > -1 then
      FValidInProgressList.Delete(Index);
  finally
    FLock.Leave;
  end;
end;

end.
