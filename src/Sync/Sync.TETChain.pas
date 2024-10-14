unit Sync.TETChain;

interface

uses
  App.Constants,
  App.Exceptions,
  App.Intf,
  App.Logs,
  Blockchain.Intf,
  Classes,
  Math,
  Net.Data,
  Net.Socket,
  Sync.Base,
  SyncObjs,
  SysUtils;

type
  TTETChainBlocksUpdater = class(TSyncChain)
    private
      FDynTETChainTotalBlocksToLoad: Integer;
      FTETChainTotalBlocksToLoad: Integer;

      procedure DoRequests;
      procedure DoTETChainsTotalBlocksNumberRequest;
      procedure DoTETChainBlocksRequest;
      procedure ReceiveTETChainBlocks(const ATETBlocksNumberNow: Integer);
      procedure DoDynTETChainBlocksRequest;
      procedure ReceiveDynTETChainBlocks(const ADynTETBlocksNumberNow: Integer);       
      procedure DoTokenICORequest;
      procedure ReceiveTokenICOBlocks(const ABlocksNumberNow: Integer);
    protected
      procedure Execute; override;
    public
      constructor Create(AAddress: string; APort: Word);
      destructor Destroy; override;
  end;

implementation

{ TBLocksUpdater }

constructor TTETChainBlocksUpdater.Create(AAddress: string; APort: Word);
begin
  inherited Create(ConstStr.DBCPath, AAddress, APort);

  FDynTETChainTotalBlocksToLoad := 0;
  FTETChainTotalBlocksToLoad := 0;
end;

destructor TTETChainBlocksUpdater.Destroy;
begin

  inherited;
end;

procedure TTETChainBlocksUpdater.Execute;
begin
  try
    inherited;
    if Terminated or IsError then
      exit;

    try
      DoTETChainsTotalBlocksNumberRequest;
      while (FDynTETChainTotalBlocksToLoad > AppCore.GetDynTETChainBlocksCount) and
        not Terminated do
        DoDynTETChainBlocksRequest;
      while (FTETChainTotalBlocksToLoad > AppCore.GetTETChainBlocksCount) and
        not Terminated do
        DoTETChainBlocksRequest;

      while not (Terminated or IsError) do
        DoRequests;
      if not IsError then
        FSocket.Send([DISCONNECTING_CODE], 0, 1);
    except
      on E:EReceiveTimeout do 
        DoCantReconnect;
    end;
  finally
    FDone.SetEvent;
  end;
end;

procedure TTETChainBlocksUpdater.ReceiveDynTETChainBlocks(
  const ADynTETBlocksNumberNow: Integer);
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  if Terminated or (IncomCount <= 0) then
  begin
    FNeedDelay := True;
    exit;
  end;

  FNeedDelay := False;
  SetLength(BytesToReceive, IncomCount * AppCore.GetDynTETChainBlockSize);
  GetResponse(BytesToReceive);
  if Terminated then
    exit;
  Logs.DoLog(Format('<DBC>[%d]: Blocks received = %d',
    [DYN_TET_CHAIN_SYNC_COMMAND_CODE, IncomCount]), INCOM, TLogFolder.sync);
  AppCore.SetDynTETChainBlocks(ADynTETBlocksNumberNow, BytesToReceive);
  if not AppCore.BlocksSyncDone then
    UI.ShowDownloadProgress;
end;

procedure TTETChainBlocksUpdater.ReceiveTETChainBlocks(
  const ATETBlocksNumberNow: Integer);
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  if Terminated or (IncomCount <= 0) then
  begin
    FNeedDelay := True;
    exit;
  end;

  FNeedDelay := False;
  SetLength(BytesToReceive, IncomCount * AppCore.GetTETChainBlockSize);
  GetResponse(BytesToReceive);
  if Terminated then
    exit;
  Logs.DoLog(Format('<DBC>[%d]: Blocks received = %d',
    [TET_CHAIN_SYNC_COMMAND_CODE, IncomCount]), INCOM, TLogFolder.sync);
  AppCore.SetTETChainBlocks(ATETBlocksNumberNow, BytesToReceive);
  if not AppCore.BlocksSyncDone then
    UI.ShowDownloadProgress;
end;

procedure TTETChainBlocksUpdater.ReceiveTokenICOBlocks(
  const ABlocksNumberNow: Integer);
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  if Terminated or (IncomCount <= 0) then
    exit;

  SetLength(BytesToReceive, IncomCount * AppCore.GetTokenICOBlockSize);
  GetResponse(BytesToReceive);
  if Terminated then
    exit;
  Logs.DoLog(Format('<DBC>[%d]: Blocks received = %d',
    [TOKEN_ICO_SYNC_COMMAND_CODE, IncomCount]), INCOM, TLogFolder.sync);
  AppCore.SetTokenICOBlocks(ABlocksNumberNow, BytesToReceive);
end;

procedure TTETChainBlocksUpdater.DoTETChainBlocksRequest;
var
  TETBlocksCountBytes: array[0..3] of Byte;
  TETBlocksCount: Integer absolute TETBlocksCountBytes;
begin
  FBytesRequest[0] := TET_CHAIN_SYNC_COMMAND_CODE;
  TETBlocksCount := AppCore.GetTETChainBlocksCount;
  Move(TETBlocksCountBytes[0], FBytesRequest[1], 4);

  FSocket.Send(FBytesRequest, 0, 5);
  ReceiveTETChainBlocks(TETBlocksCount);
end;

procedure TTETChainBlocksUpdater.DoTETChainsTotalBlocksNumberRequest;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  ToLoadTotal: UInt64;
begin
  FSocket.Send([TET_CHAINS_TOTAL_NUMBER_COMMAND_CODE], 0, 1);
  Logs.DoLog(Format('<DBC>[%d]',
    [TET_CHAINS_TOTAL_NUMBER_COMMAND_CODE]), OUTGO, TLogFolder.sync);

  GetResponse(IncomCountBytes);
  if Terminated then
    exit;
  FDynTETChainTotalBlocksToLoad := IncomCount;
  GetResponse(IncomCountBytes);
  FTETChainTotalBlocksToLoad := IncomCount;
  ToLoadTotal := FDynTETChainTotalBlocksToLoad + FTETChainTotalBlocksToLoad;
  Logs.DoLog(Format('<DBC>[%d]: Blocks to receive = %d',
    [TET_CHAINS_TOTAL_NUMBER_COMMAND_CODE, ToLoadTotal]), INCOM, TLogFolder.sync);

  UI.ShowTotalBlocksToDownload(ToLoadTotal);
end;

procedure TTETChainBlocksUpdater.DoDynTETChainBlocksRequest;
var
  DynTETBlocksCountBytes: array[0..3] of Byte;
  DynTETBlocksCount: Integer absolute DynTETBlocksCountBytes;
begin
  FBytesRequest[0] := DYN_TET_CHAIN_SYNC_COMMAND_CODE;
  DynTETBlocksCount := AppCore.GetDynTETChainBlocksCount;
  Move(DynTETBlocksCountBytes[0], FBytesRequest[1], 4);

  FSocket.Send(FBytesRequest, 0, 5);
  ReceiveDynTETChainBlocks(DynTETBlocksCount);
end;

procedure TTETChainBlocksUpdater.DoRequests;
begin
  if FNeedDelay then
    BreakableSleep(RequestLongDelay)
  else
    Sleep(RequestShortDelay);
  if Terminated then
    exit;

  try
    DoTokenICORequest;
    if Terminated then
      exit;
    DoDynTETChainBlocksRequest;
    if Terminated then
      exit;
    DoTETChainBlocksRequest;
  except
    on E:EReceiveTimeout do
      if not DoTryReconnect then raise;
  end;
end;

procedure TTETChainBlocksUpdater.DoTokenICORequest;
var
  ICOBlocksCountBytes: array[0..3] of Byte;
  ICOBlocksCount: Integer absolute ICOBlocksCountBytes;
begin
  FBytesRequest[0] := TOKEN_ICO_SYNC_COMMAND_CODE;
  ICOBlocksCount := AppCore.GetTokenICOBlocksCount;
  Move(ICOBlocksCountBytes[0], FBytesRequest[1], 4);

  FSocket.Send(FBytesRequest, 0, 5);
  ReceiveTokenICOBlocks(ICOBlocksCount);
end;

end.
