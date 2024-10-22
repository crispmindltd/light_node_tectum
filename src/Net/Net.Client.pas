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
  Sync.TokensChains,
  SysUtils;

type
  TServerStatus = (ssStarted, ssShuttingDown, ssStoped);

  TNodeClient = class
  const
    ShuttingDownTimeout = 10000;
  strict private
    FStatus: TServerStatus;
  private
    FTETChainBlocksUpdater: TTETChainBlocksUpdater;
    FTokensChainsBlocksUpdater: TTokensChainsBlocksUpdater;
    FRemoteServer: TCustomSocket;

    procedure StartTETChainSync(AAddress: string);
    procedure OnTETChainUpdaterTerminate(Sender: TObject);
    procedure KillTETChainUpdater;
    procedure StartTokensChainsSync(AAddress: string);
    procedure OnTokensChainsUpdaterTerminate(Sender: TObject);
    procedure KillTokensChainsUpdater;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
    function DoRequest(AReqID, ARequest: string): string;
    function DoRequestToValidator(ARequest: string): string;
    procedure Stop;
end;

implementation

{ TNodeClient }

procedure TNodeClient.StartTETChainSync(AAddress: string);
var
  Splitted: TArray<string>;
begin
  if Assigned(FTETChainBlocksUpdater) then
    exit;

  Splitted := AAddress.Split([' ', ':']);
  FTETChainBlocksUpdater := TTETChainBlocksUpdater.Create(Splitted[0],
    Splitted[1].ToInteger);
  FTETChainBlocksUpdater.OnDoTerminate := onTETChainUpdaterTerminate;
  FTETChainBlocksUpdater.Resume;
end;

procedure TNodeClient.StartTokensChainsSync(AAddress: string);
var
  Splitted: TArray<string>;
begin
  if Assigned(FTokensChainsBlocksUpdater) then
    exit;

  Splitted := AAddress.Split([' ', ':']);
  FTokensChainsBlocksUpdater := TTokensChainsBlocksUpdater.Create(Splitted[0],
    Splitted[1].ToInteger);
  FTokensChainsBlocksUpdater.OnDoTerminate := onTokensChainsUpdaterTerminate;
  FTokensChainsBlocksUpdater.Resume;
end;

constructor TNodeClient.Create;
begin
  inherited Create;

  FRemoteServer := TCustomSocket.Create;
  FStatus := ssStoped;
end;

destructor TNodeClient.Destroy;
begin
  Stop;
  FRemoteServer.Free;

  inherited;
end;

function TNodeClient.DoRequest(AReqID, ARequest: string): string;
begin
  try
    FRemoteServer.Connect;
    try
      Result := FRemoteServer.DoRequest(AReqID, ARequest);
    finally
      FRemoteServer.Disconnect;
    end;
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond', ERROR, tcp);
      FRemoteServer.Disconnect;
      Result := 'URKError * * 15'
    end;
  end;
end;

function TNodeClient.DoRequestToValidator(ARequest: string): string;
var
  Address: string;
  Splitted: TArray<string>;
  AttemptsCount: Integer;
  Validator: TLightSocket;
begin
  Result := '';
  AttemptsCount := 0;
  Validator := TLightSocket.Create;
  try
    repeat
      Address := '';
      repeat
        Address := Nodes.GetAnotherNodeToConnect(Address);
        Splitted := Address.Split([':']);
      until Validator.Connect(Splitted[0], Splitted[1].ToInteger);

      try
        Result := Validator.DoRequest(ValidateCommandCode, ARequest);
      except
        on E:ESocketError do
        begin
          Logs.DoLog('Changing validator...', ERROR);
          Result := '';
        end;
      end;
      Inc(AttemptsCount);
      if AttemptsCount = 3 then
        raise EValidatorDidNotAnswerError.Create('');
    until not Result.IsEmpty;
  finally
    Validator.Free;
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

procedure TNodeClient.OnTETChainUpdaterTerminate(Sender: TObject);
var
  Updater: TTETChainBlocksUpdater;
  AnotherAddress: string;
begin
  Updater := Sender as TTETChainBlocksUpdater;
  if Updater.IsError and (FStatus = ssStarted) then
  begin
    AnotherAddress := Nodes.GetAnotherNodeToConnect(Updater.Address);
    FTETChainBlocksUpdater := nil;
    StartTETChainSync(AnotherAddress);
  end else
    FTETChainBlocksUpdater := nil;
end;

procedure TNodeClient.OnTokensChainsUpdaterTerminate(Sender: TObject);
var
  Updater: TTokensChainsBlocksUpdater;
  AnotherAddress: string;
begin
  Updater := Sender as TTokensChainsBlocksUpdater;
  if Updater.IsError and (FStatus = ssStarted) then
  begin
    AnotherAddress := Nodes.GetAnotherNodeToConnect(Updater.Address);
    FTokensChainsBlocksUpdater := nil;
    StartTokensChainsSync(AnotherAddress);
  end else
    FTokensChainsBlocksUpdater := nil;
end;

procedure TNodeClient.Start;
begin
  if FStatus <> ssStoped then
    exit;

  StartTETChainSync(Nodes.GetNodeToConnect);
  StartTokensChainsSync(Nodes.GetNodeToConnect);
  FStatus := ssStarted;
end;

procedure TNodeClient.Stop;
begin
  if FStatus <> ssStarted then
    exit;

  FStatus := ssShuttingDown;
  KillTETChainUpdater;
  KillTokensChainsUpdater;
  FTETChainBlocksUpdater.Free;
  FTokensChainsBlocksUpdater.Free;

  FStatus := ssStoped;
end;

end.
