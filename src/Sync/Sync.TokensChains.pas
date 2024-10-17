unit Sync.TokensChains;

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
  TTokensChainsBlocksUpdater = class(TSyncChain)
    private
      procedure DoRequests;
      procedure DoSmartKeyRequest;
      procedure ReceiveSmartKeyBlocks(const ASKBlocksNumberNow: Integer);
      function DoTokenBlocksRequest(ATokenID: Integer): Boolean;
      function ReceiveTokenBlocks(ATokenID: Integer;
        const ABlocksCountNow: Integer): Boolean;
      function DoDynTokenBlocksRequest(ATokenID: Integer): Boolean;
      function ReceiveDynTokenBlocks(ATokenID: Integer;
        const ABlocksCountNow: Integer): Boolean;
    protected
      procedure Execute; override;
    public
      constructor Create(AAddress: string; APort: Word);
      destructor Destroy; override;
  end;

implementation

{ TTokensChainsBlocksUpdater }

constructor TTokensChainsBlocksUpdater.Create(AAddress: string; APort: Word);
begin
  inherited Create(ConstStr.SmartCPath, AAddress, APort);

end;

destructor TTokensChainsBlocksUpdater.Destroy;
begin

  inherited;
end;

procedure TTokensChainsBlocksUpdater.Execute;
begin
  try
    inherited;

    try
      while not (Terminated or IsError) do
        DoRequests;

      if not IsError then
        FSocket.Send([DisconnectingCode], 0, 1);
    except
      on E:EReceiveTimeout do
        DoCantReconnect;
    end;
  finally
    FDone.SetEvent;
  end;
end;

function TTokensChainsBlocksUpdater.ReceiveDynTokenBlocks(ATokenID: Integer;
  const ABlocksCountNow: Integer): Boolean;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  try
    if Terminated or (IncomCount = 0) then
      exit;

    SetLength(BytesToReceive, IncomCount * AppCore.GetDynTokenChainBlockSize);
    GetResponse(BytesToReceive);
    if Terminated then
      exit;
    Logs.DoLog(Format('<SmartC>[%d]: Token ID = %d, Blocks received = %d',
      [DynTokenChainSyncCommandCode, ATokenID, IncomCount]), INCOM, TLogFolder.sync);
    AppCore.SetDynTokenChainBlocks(ATokenID, ABlocksCountNow, BytesToReceive);
  finally
    Result := IncomCount = 0;
  end;
end;

procedure TTokensChainsBlocksUpdater.ReceiveSmartKeyBlocks(
  const ASKBlocksNumberNow: Integer);
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  if Terminated or (IncomCount = 0) then
    exit;

  SetLength(BytesToReceive, IncomCount * AppCore.GetSmartKeyBlockSize);
  GetResponse(BytesToReceive);
  if Terminated then
    exit;
  Logs.DoLog(Format('<DBC>[%d]: Blocks received = %d',
    [SmartKeySyncCommandCode, IncomCount]), INCOM, TLogFolder.sync);
  AppCore.SetSmartKeyBlocks(ASKBlocksNumberNow, BytesToReceive);
end;

function TTokensChainsBlocksUpdater.ReceiveTokenBlocks(ATokenID: Integer;
  const ABlocksCountNow: Integer): Boolean;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  try
    if Terminated or (IncomCount = 0) then
      exit;

    SetLength(BytesToReceive, IncomCount * AppCore.GetTokenChainBlockSize);
    GetResponse(BytesToReceive);
    if Terminated then
      exit;
    Logs.DoLog(Format('<SmartC>[%d]: Token ID = %d, Blocks received = %d',
      [TokenChainSyncCommandCode, ATokenID, IncomCount]), INCOM, TLogFolder.sync);
    AppCore.SetTokenChainBlocks(ATokenID, ABlocksCountNow, BytesToReceive);
  finally
    Result := IncomCount = 0;
  end;
end;

function TTokensChainsBlocksUpdater.DoTokenBlocksRequest(
  ATokenID: Integer): Boolean;
var
  DataBytes: array[0..3] of Byte;
  DataInt: Integer absolute DataBytes;
begin
  FBytesRequest[0] := TokenChainSyncCommandCode;
  DataInt := ATokenID;
  Move(DataBytes[0], FBytesRequest[1], 4);
  DataInt := AppCore.GetTokenChainBlocksCount(ATokenID);
  Move(DataBytes[0], FBytesRequest[5], 4);

  FSocket.Send(FBytesRequest, 0, 9);
  Result := ReceiveTokenBlocks(ATokenID, DataInt);
end;

function TTokensChainsBlocksUpdater.DoDynTokenBlocksRequest(
  ATokenID: Integer): Boolean;
var
  DataBytes: array[0..3] of Byte;
  DataInt: Integer absolute DataBytes;
begin
  FBytesRequest[0] := DynTokenChainSyncCommandCode;
  DataInt := ATokenID;
  Move(DataBytes[0], FBytesRequest[1], 4);
  DataInt := AppCore.GetTokenChainBlocksCount(ATokenID);
  Move(DataBytes[0], FBytesRequest[5], 4);

  FSocket.Send(FBytesRequest, 0, 9);
  Result := ReceiveDynTokenBlocks(ATokenID, DataInt);
end;

procedure TTokensChainsBlocksUpdater.DoRequests;
var
  TokenID: Integer;
begin
  BreakableSleep(RequestTokenDelay);
  if Terminated then
    exit;

  try
    DoSmartKeyRequest;
    if Terminated then
      exit;
    for TokenID in AppCore.GetTokensToSynchronize do
    begin
      while not (DoDynTokenBlocksRequest(TokenID) or Terminated) do
      begin
      end;

      while not (DoTokenBlocksRequest(TokenID) or Terminated) do
      begin
      end;
    end;
  except
    on E:EReceiveTimeout do
      if not DoTryReconnect then
        raise;
  end;
end;

procedure TTokensChainsBlocksUpdater.DoSmartKeyRequest;
var
  SmartKeyBlocksCountBytes: array[0..3] of Byte;
  SmartKeyBlocksCount: Integer absolute SmartKeyBlocksCountBytes;
begin
  FBytesRequest[0] := SmartKeySyncCommandCode;
  SmartKeyBlocksCount := AppCore.GetSmartKeyBlocksCount;
  Move(SmartKeyBlocksCountBytes[0], FBytesRequest[1], 4);

  FSocket.Send(FBytesRequest, 0, 5);
  ReceiveSmartKeyBlocks(SmartKeyBlocksCount);
end;

end.
