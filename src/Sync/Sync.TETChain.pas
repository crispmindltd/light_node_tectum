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
      procedure DoRequests;
      procedure DoTETChainTotalCountRequest;
      procedure DoTETChainBlocksRequest;
      procedure ReceiveTETChainBlocks(const ATETBlocksCountNow: Int64);
      procedure DoTokenICORequest;
      procedure ReceiveTokenICOBlocks(const ABlocksCountNow: Integer);
    protected
      procedure Execute; override;
    public
      constructor Create(AAddress: String; APort: Word);
      destructor Destroy; override;
  end;

implementation

{ TBLocksUpdater }

constructor TTETChainBlocksUpdater.Create(AAddress: String; APort: Word);
begin
  inherited Create(ConstStr.DBCPath, AAddress,APort);

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
      DoTETChainTotalCountRequest;

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

procedure TTETChainBlocksUpdater.ReceiveTETChainBlocks(
  const ATETBlocksCountNow: Int64);
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  if Terminated then
    exit;
  if IncomCount <= 0 then
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
    [TET_CHAIN_SYNC_COMMAND_CODE,IncomCount]),INCOM,TLogFolder.sync);
  AppCore.SetTETChainBlocks(ATETBlocksCountNow,BytesToReceive);
  UI.ShowDownloadProgress;
end;

procedure TTETChainBlocksUpdater.ReceiveTokenICOBlocks(
  const ABlocksCountNow: Integer);
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
    [TOKEN_ICO_SYNC_COMMAND_CODE,IncomCount]),INCOM,TLogFolder.sync);
  AppCore.SetTokenICOBlocks(ABlocksCountNow,BytesToReceive);
end;

procedure TTETChainBlocksUpdater.DoTETChainBlocksRequest;
var
  TETBlocksCountBytes: array[0..7] of Byte;
  TETBlocksCount: Int64 absolute TETBlocksCountBytes;
begin
  FBytesRequest[0] := TET_CHAIN_SYNC_COMMAND_CODE;
  TETBlocksCount := AppCore.GetTETChainBlocksCount;
  Move(TETBlocksCountBytes[0],FBytesRequest[1],8);

  FSocket.Send(FBytesRequest,0,9);
  ReceiveTETChainBlocks(TETBlocksCount);
end;

procedure TTETChainBlocksUpdater.DoTETChainTotalCountRequest;
var
  IncomCountBytes: array[0..7] of Byte;
  IncomCount: Int64 absolute IncomCountBytes;
begin
  FSocket.Send([TET_CHAIN_TOTAL_COUNT_COMMAND_CODE],0,1);
  Logs.DoLog(Format('<DBC>[%d]',
    [TET_CHAIN_TOTAL_COUNT_COMMAND_CODE]),OUTGO,TLogFolder.sync);

  GetResponse(IncomCountBytes);
  if Terminated then
    exit;

  Logs.DoLog(Format('<DBC>[%d]: Blocks to receive = %d',
    [TET_CHAIN_TOTAL_COUNT_COMMAND_CODE,IncomCount]),INCOM,TLogFolder.sync);

  UI.ShowTotalBlocksToDownload(IncomCount);
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
    if Terminated then
      exit;
    DoTETChainBlocksRequest;
    if Terminated then
      exit;
    DoTokenICORequest;
  except
    on E:EReceiveTimeout do
      if not DoTryReconnect then raise;
  end;
end;

procedure TTETChainBlocksUpdater.DoTokenICORequest;
var
  ICOBlocksCountBytes: array[0..7] of Byte;
  ICOBlocksCount: Int64 absolute ICOBlocksCountBytes;
begin
  FBytesRequest[0] := TOKEN_ICO_SYNC_COMMAND_CODE;
  ICOBlocksCount := AppCore.GetTokenICOBlocksCount;
  Move(ICOBlocksCountBytes[0],FBytesRequest[1],8);

  FSocket.Send(FBytesRequest,0,9);
  ReceiveTokenICOBlocks(ICOBlocksCount);
end;

end.
