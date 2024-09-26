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
  Sync.TETChain,
  Sync.Tokens,
  SyncObjs,
  SysUtils;

type
  TServerStatus = (ssStarted,ssShuttingDown,ssStoped);

  TNodeClient = class
  const
    ShuttingDownTimeout = 10000;
  strict private
    FStatus: TServerStatus;
  private
    FTETChainBlocksUpdater: TTETChainBlocksUpdater;
    FTokensChainsBlocksUpdater: TTokensChainsBlocksUpdater;
    FTETChainSyncDone: TEvent;
    FTokensSyncDone: TEvent;
    FRemoteServer: TCustomSocket;

    procedure StartTETChainSync(AAddress: String);
    procedure onTETChainUpdaterTerminate(Sender: TObject);
    procedure KillTETChainUpdater;
    procedure StartTokensChainsSync(AAddress: String);
    procedure onTokensChainsUpdaterTerminate(Sender: TObject);
    procedure KillTokensChainsUpdater;
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

procedure TNodeClient.StartTETChainSync(AAddress: String);
var
  splt: TArray<string>;
begin
  if Assigned(FTETChainBlocksUpdater) then exit;

  splt := AAddress.Split([' ',':']);
  FTETChainBlocksUpdater := TTETChainBlocksUpdater.Create(splt[0],
    splt[1].ToInteger);
  FTETChainBlocksUpdater.SyncDoneEvent := FTETChainSyncDone;
  FTETChainBlocksUpdater.OnTerminate := onTETChainUpdaterTerminate;
  FTETChainBlocksUpdater.Resume;
end;

procedure TNodeClient.StartTokensChainsSync(AAddress: String);
var
  splt: TArray<string>;
begin
  if Assigned(FTokensChainsBlocksUpdater) then exit;

  splt := AAddress.Split([' ',':']);
  FTokensChainsBlocksUpdater := TTokensChainsBlocksUpdater.Create(splt[0],
    splt[1].ToInteger);
  FTokensChainsBlocksUpdater.SyncDoneEvent := FTokensSyncDone;
  FTokensChainsBlocksUpdater.OnTerminate := onTokensChainsUpdaterTerminate;
  FTokensChainsBlocksUpdater.Resume;
end;

constructor TNodeClient.Create;
begin
  inherited Create;

  FRemoteServer := TCustomSocket.Create;
  FStatus := ssStoped;
  FTETChainSyncDone := TEvent.Create;
  FTokensSyncDone := TEvent.Create;
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
  FTETChainSyncDone.Free;
  FTokensSyncDone.Free;

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
      Result := 'URKError * * 15'
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

procedure TNodeClient.KillTETChainUpdater;
begin
  if Assigned(FTETChainBlocksUpdater) then
    FTETChainBlocksUpdater.Terminate;
end;

procedure TNodeClient.KillTokensChainsUpdater;
begin
  if Assigned(FTokensChainsBlocksUpdater) then
    FTokensChainsBlocksUpdater.Terminate;
end;

procedure TNodeClient.onTETChainUpdaterTerminate(Sender: TObject);
var
  chUpdater: TTETChainBlocksUpdater;
  anotherAddr: String;
begin
  chUpdater := Sender as TTETChainBlocksUpdater;
  if chUpdater.IsError and (FStatus = ssStarted) then
  begin
    anotherAddr := Nodes.GetAnotherNodeToConnect(chUpdater.Address);
    FTETChainBlocksUpdater := nil;
    StartTETChainSync(anotherAddr);
  end else
    FTETChainBlocksUpdater := nil;
end;

procedure TNodeClient.onTokensChainsUpdaterTerminate(Sender: TObject);
var
  smUpdater: TTokensChainsBlocksUpdater;
  anotherAddr: String;
begin
  smUpdater := Sender as TTokensChainsBlocksUpdater;
  if smUpdater.IsError and (FStatus = ssStarted) then
  begin
    anotherAddr := Nodes.GetAnotherNodeToConnect(smUpdater.Address);
    FTokensChainsBlocksUpdater := nil;
    StartTokensChainsSync(anotherAddr);
  end else
    FTokensChainsBlocksUpdater := nil;
end;

procedure TNodeClient.Start;
begin
  if FStatus <> ssStoped then exit;

  StartTETChainSync(Nodes.GetNodeToConnect);
  StartTokensChainsSync(Nodes.GetNodeToConnect);
  FStatus := ssStarted;
end;

procedure TNodeClient.Stop;
begin
  if FStatus <> ssStarted then exit;

  FStatus := ssShuttingDown;
  KillTETChainUpdater;
  KillTokensChainsUpdater;
  FTETChainSyncDone.WaitFor(ShuttingDownTimeout);
  FTokensSyncDone.WaitFor(ShuttingDownTimeout);
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
