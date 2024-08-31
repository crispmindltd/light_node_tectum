unit Sync.Chain;

interface

uses
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
  TChainBlocksUpdater = class(TSyncChain)
    private
      FBytesRequest: array[0..4] of Byte;

      procedure DoRequests;
      procedure DoChainTotalCountRequest;
      function DoChainRequest: Boolean;
      function ReceiveChainBlocks(const ABlocksCountNow: Integer): Boolean;
      procedure DoDynamicTotalCountRequest;
      function DoDynamicRequest: Boolean;
      function ReceiveDynamicBlocks(const ABlocksCountNow: Integer): Boolean;
      function DoTokenICORequest: Boolean;
      function ReceiveTokenICOBlocks(const ABlocksCountNow: Integer): Boolean;
    protected
      procedure Execute; override;
    public
      constructor Create(AAddress: String; APort: Word);
      destructor Destroy; override;
  end;

implementation

{ TBLocksUpdater }

constructor TChainBlocksUpdater.Create(AAddress: String; APort: Word);
begin
  inherited Create('DBC',AAddress,APort);

end;

destructor TChainBlocksUpdater.Destroy;
begin

  inherited;
end;

procedure TChainBlocksUpdater.Execute;
begin
  try
    inherited;
    if Terminated or IsError then exit;

    try
      DoChainTotalCountRequest;
      DoDynamicTotalCountRequest;
      UI.ShowTotalCountBlocksDownloadRemain;

      while not(Terminated or IsError) do
        DoRequests;

      if not IsError then
        FSocket.Send([DISCONNECTING_CODE],0,1);
    except
      on E:EReceiveTimeout do DoCantReconnect;
    end;
  finally
    FDone.SetEvent;
  end;
end;

function TChainBlocksUpdater.ReceiveChainBlocks(
  const ABlocksCountNow: Integer): Boolean;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
  inBytes: TBytesBlocks;
begin
  GetResponse(incomCountBytes,4);
  if Terminated then Exit(False);
  Result := incomCount > -1;
  if incomCount <= 0 then
  begin
    FNeedDelay := True;
    exit;
  end;

  FNeedDelay := False;
  GetResponse(inBytes,incomCount * AppCore.GetChainBlockSize);
  if Terminated then exit;
  Logs.DoLog(Format('<DBC>[%d]: blocksReceived=%d',
    [CHAIN_SYNC_COMMAND_CODE,incomCount]),INCOM,TLogFolder.sync);
  AppCore.SetChainBlocks(ABlocksCountNow,inBytes,incomCount);
end;

function TChainBlocksUpdater.ReceiveDynamicBlocks(
  const ABlocksCountNow: Integer): Boolean;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
  inBytes: TBytesBlocks;
begin
  GetResponse(incomCountBytes,4);
  if Terminated then Exit(False);
  Result := incomCount > -1;
  if incomCount <= 0 then
    exit;

  GetResponse(inBytes,incomCount * AppCore.GetDynBlockSize(-1));
  if Terminated then exit;
  Logs.DoLog(Format('<DBC>[%d]: blocksReceived=%d',
    [CHAIN_DYN_SYNC_COMMAND_CODE,incomCount]),INCOM,TLogFolder.sync);
  AppCore.SetDynBlocks(-1,ABlocksCountNow,inBytes,incomCount);
end;

function TChainBlocksUpdater.ReceiveTokenICOBlocks(
  const ABlocksCountNow: Integer): Boolean;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
  inBytes: TBytesBlocks;
begin
  GetResponse(incomCountBytes,4);
  if Terminated then Exit(False);
  Result := incomCount > -1;
  if incomCount <= 0 then
    exit;

  GetResponse(inBytes,incomCount * AppCore.GetICOBlockSize);
  if Terminated then exit;
  Logs.DoLog(Format('<DBC>[%d]: blocksReceived=%d',
    [TOKEN_ICO_SYNC_COMMAND_CODE,incomCount]),INCOM,TLogFolder.sync);
  AppCore.SetICOBlocks(ABlocksCountNow,inBytes,incomCount);
end;

function TChainBlocksUpdater.DoChainRequest: Boolean;
var
  chCountBytes:array[0..3] of Byte;
  blocksCount: Integer absolute chCountBytes;
begin
  FBytesRequest[0] := CHAIN_SYNC_COMMAND_CODE;
  blocksCount := AppCore.GetChainBlocksCount;
  Move(chCountBytes[0],FBytesRequest[1],4); //add chain blocks count into request

  FSocket.Send(FBytesRequest,0,5);
//  Logs.DoLog(Format('<DBC>[%d]: blockNum=%d',
//    [CHAIN_SYNC_COMMAND_CODE,blocksCount]),OUTGO,TLogFolder.sync);
  Result := ReceiveChainBlocks(blocksCount);
end;

procedure TChainBlocksUpdater.DoChainTotalCountRequest;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
  inBytes: TBytesBlocks;
begin
  FBytesRequest[0] := CHAIN_TOTAL_COUNT_COMMAND_CODE;
  FSocket.Send(FBytesRequest,0,1);
  Logs.DoLog(Format('<DBC>[%d]',
    [CHAIN_TOTAL_COUNT_COMMAND_CODE]),OUTGO,TLogFolder.sync);

  GetResponse(incomCountBytes,4);
  if Terminated then exit;

  Logs.DoLog(Format('<DBC>[%d]: blocksToReceive=%d',
    [CHAIN_TOTAL_COUNT_COMMAND_CODE,incomCount]),INCOM,TLogFolder.sync);
  AppCore.DownloadRemain := incomCount - AppCore.GetChainBlocksCount;
end;

function TChainBlocksUpdater.DoDynamicRequest: Boolean;
var
  bCountBytes:array[0..3] of Byte;
  blocksCount: Integer absolute bCountBytes;
begin
  FBytesRequest[0] := CHAIN_DYN_SYNC_COMMAND_CODE;
  blocksCount := AppCore.GetDynBlocksCount(-1);
  Move(bCountBytes[0],FBytesRequest[1],4); //add dynamic blocks count into request

  FSocket.Send(FBytesRequest,0,5);
//  Logs.DoLog(Format('<DBC>[%d]: blockNum=%d',
//    [CHAIN_DYN_SYNC_COMMAND_CODE,blocksCount]),OUTGO,TLogFolder.sync);
  Result := ReceiveDynamicBlocks(blocksCount);
end;

procedure TChainBlocksUpdater.DoDynamicTotalCountRequest;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
  inBytes: TBytesBlocks;
begin
  FBytesRequest[0] := DYN_CHAIN_TOTAL_COUNT_COMMAND_CODE;
  FSocket.Send(FBytesRequest,0,1);
  Logs.DoLog(Format('<DBC>[%d]',
    [DYN_CHAIN_TOTAL_COUNT_COMMAND_CODE]),OUTGO,TLogFolder.sync);

  GetResponse(incomCountBytes,4);
  if Terminated then exit;

  Logs.DoLog(Format('<DBC>[%d]: blocksToReceive=%d',
    [DYN_CHAIN_TOTAL_COUNT_COMMAND_CODE,incomCount]),INCOM,TLogFolder.sync);
  AppCore.DownloadRemain := incomCount - AppCore.GetDynBlocksCount(-1);
end;

procedure TChainBlocksUpdater.DoRequests;
var
  bBytes:array[0..3] of Byte;
  value: Integer absolute bBytes;
  blocksCount: Integer;
  inBytes: TBytesBlocks;
begin
  if FNeedDelay then
    BreakableSleep(REQUEST_LONG_DELAY)
  else
    Sleep(REQUEST_SHORT_DELAY);
  if Terminated then exit;

  try
    DoDynamicRequest;
    if Terminated then exit;
    DoChainRequest;
    if Terminated then exit;
    DoTokenICORequest;
  except
    on E:EReceiveTimeout do
      if not DoTryReconnect then raise;
  end;
end;

function TChainBlocksUpdater.DoTokenICORequest: Boolean;
var
  bCountBytes:array[0..3] of Byte;
  blocksCount: Integer absolute bCountBytes;
begin
  FBytesRequest[0] := TOKEN_ICO_SYNC_COMMAND_CODE;
  blocksCount := AppCore.GetIcoBlocksCount;
  Move(bCountBytes[0],FBytesRequest[1],4); //add token ICO blocks count into request

  FSocket.Send(FBytesRequest,0,5);
//  Logs.DoLog(Format('<DBC>[%d]: blockNum=%d',
//    [TOKEN_ICO_SYNC_COMMAND_CODE,blocksCount]),OUTGO,TLogFolder.sync);
  Result := ReceiveTokenICOBlocks(blocksCount);
end;

end.
