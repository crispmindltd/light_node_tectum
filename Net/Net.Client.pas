unit Net.Client;

interface

uses
  App.Exceptions,
  App.Intf,
  App.Logs,
  Classes,
  Generics.Collections,
  Net.CustomSocket,
  Net.LightSocket,
  Net.Socket,
  Net.Data,
  Sync.Base,
  Sync.Chain,
  Sync.Smartcontratcs,
  SyncObjs,
  SysUtils;

type
  TServerStatus = (ssStarted,ssShuttingDown,ssStoped);

  TNodeClient = class
  const
    WAIT_FOR_SHUTTING_DOWN = 10000;
  strict private
    FStatus: TServerStatus;
  private
    FChainBlocksUpdater: TChainBlocksUpdater;
    FSmartBlocksUpdater: TSmartBlocksUpdater;
    FChainSyncDone: TEvent;
    FSmartSyncDone: TEvent;
    FRemoteServer: TCustomSocket;

    procedure StartChainSync(AAddress: String);
    procedure onChainUpdaterTerminate(Sender: TObject);
    procedure KillChainUpdater;
    procedure StartSmartSync(AAddress: String);
    procedure onSmartUpdaterTerminate(Sender: TObject);
    procedure KillSmartUpdater;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
//    procedure BeginSync(const AChainName: String; AIsSystemChain: Boolean);
//    procedure StopSync(const AChainName: String; AIsSystemChain: Boolean);
    function DoRequest(AReqID,ARequest: String): String;
    function DoRequestToValidator(ARequest: String): String;
    procedure Stop;
end;

implementation

{ TNodeClient }

procedure TNodeClient.StartChainSync(AAddress: String);
var
  splt: TArray<string>;
begin
  if Assigned(FChainBlocksUpdater) then exit;

  splt := AAddress.Split([' ',':']);
  FChainBlocksUpdater := TChainBlocksUpdater.Create(splt[0],splt[1].ToInteger);
  FChainBlocksUpdater.SyncDoneEvent := FChainSyncDone;
  FChainBlocksUpdater.OnTerminate := onChainUpdaterTerminate;
  FChainBlocksUpdater.Resume;
end;

procedure TNodeClient.StartSmartSync(AAddress: String);
var
  splt: TArray<string>;
begin
  if Assigned(FSmartBlocksUpdater) then exit;

  splt := AAddress.Split([' ',':']);
  FSmartBlocksUpdater := TSmartBlocksUpdater.Create(splt[0],splt[1].ToInteger);
  FSmartBlocksUpdater.SyncDoneEvent := FSmartSyncDone;
  FSmartBlocksUpdater.OnTerminate := onSmartUpdaterTerminate;
  FSmartBlocksUpdater.Resume;
end;

constructor TNodeClient.Create;
begin
  inherited Create;

  FRemoteServer := TCustomSocket.Create;
  FStatus := ssStoped;
  FChainSyncDone := TEvent.Create;
  FSmartSyncDone := TEvent.Create;
end;

//procedure TNodeClient.BeginSync(const AChainName: String; AIsSystemChain: Boolean);
//var
//  BU: TChainBlocksUpdater;
//begin
//  if AIsSystemChain then
//  begin
//    if not FChainBlocksUpdater.TryGetValue(AChainName,BU) then
//      StartChainSync(AChainName,Nodes.GetNodeToConnect);
//  end;
//end;

destructor TNodeClient.Destroy;
begin
  Stop;
  FRemoteServer.Free;
  FChainSyncDone.Free;
  FSmartSyncDone.Free;

  inherited;
end;

function TNodeClient.DoRequest(AReqID, ARequest: String): String;
begin
  try
    FRemoteServer.Connect;
    try
      Result := FRemoteServer.DoRequest(AReqID,ARequest);
    finally
      FRemoteServer.Disconnect;
    end;
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      FRemoteServer.Disconnect;
      raise;
    end;
  end;
end;

function TNodeClient.DoRequestToValidator(ARequest: String): String;
var
  addr: String;
  splt: TArray<String>;
  attemptsCount: Integer;
  FValidator: TLightSocket;
begin
  Result := '';
  attemptsCount := 0;
  FValidator := TLightSocket.Create;
  try
    repeat
      addr := '';
      repeat
        addr := Nodes.GetAnotherNodeToConnect(addr);
        splt := addr.Split([':']);
      until FValidator.Connect(splt[0],splt[1].ToInteger);

      try
        Result := FValidator.DoRequest(VALIDATE_COMMAND_CODE,ARequest);
      except
        on E:ESocketError do
        begin
          Logs.DoLog('Changing validator...',ERROR);
          Result := '';
        end;
      end;
      Inc(attemptsCount);
      if attemptsCount = 3 then
        raise EValidatorDidNotAnswerError.Create('');
    until not Result.IsEmpty;
  finally
    FValidator.Free;
  end;
end;

procedure TNodeClient.KillChainUpdater;
begin
  if Assigned(FChainBlocksUpdater) then
    FChainBlocksUpdater.Terminate;
end;

procedure TNodeClient.KillSmartUpdater;
begin
  if Assigned(FSmartBlocksUpdater) then
    FSmartBlocksUpdater.Terminate;
end;

procedure TNodeClient.onChainUpdaterTerminate(Sender: TObject);
var
  chUpdater: TChainBlocksUpdater;
  anotherAddr: String;
begin
  chUpdater := Sender as TChainBlocksUpdater;
  if chUpdater.IsError and (FStatus = ssStarted) then
  begin
    anotherAddr := Nodes.GetAnotherNodeToConnect(chUpdater.Address);
    FChainBlocksUpdater := nil;
    StartChainSync(anotherAddr);
  end else
    FChainBlocksUpdater := nil;
end;

procedure TNodeClient.onSmartUpdaterTerminate(Sender: TObject);
var
  smUpdater: TSmartBlocksUpdater;
  anotherAddr: String;
begin
  smUpdater := Sender as TSmartBlocksUpdater;
  if smUpdater.IsError and (FStatus = ssStarted) then
  begin
    anotherAddr := Nodes.GetAnotherNodeToConnect(smUpdater.Address);
    FSmartBlocksUpdater := nil;
    StartSmartSync(anotherAddr);
  end else
    FSmartBlocksUpdater := nil;
end;

procedure TNodeClient.Start;
begin
  if FStatus <> ssStoped then exit;

  StartChainSync(Nodes.GetNodeToConnect);
  StartSmartSync(Nodes.GetNodeToConnect);
  FStatus := ssStarted;
end;

procedure TNodeClient.Stop;
begin
  if FStatus <> ssStarted then exit;

  FStatus := ssShuttingDown;
  KillChainUpdater;
  KillSmartUpdater;
  FChainSyncDone.WaitFor(WAIT_FOR_SHUTTING_DOWN);
  FSmartSyncDone.WaitFor(WAIT_FOR_SHUTTING_DOWN);
  FStatus := ssStoped;
end;

//procedure TNodeClient.StopSync(const AChainName: String; AIsSystemChain: Boolean);
//var
//  BU: TChainBlocksUpdater;
//begin
//  if AIsSystemChain then
//  begin
//    if FChainsBlocksUpdaters.TryGetValue(AChainName,BU) then
//      KillChainUpdater(AChainName);
//  end;
//end;

end.
