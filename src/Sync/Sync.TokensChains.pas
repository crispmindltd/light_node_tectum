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
//      procedure DoTokenBlocksRequest(ATokenID: Integer);
//      procedure ReceiveTokenBlocks(ATokenID: Integer;
//        const ABlocksCountNow: Int64);
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

procedure TTokensChainsBlocksUpdater.ReceiveSmartKeyBlocks(
  const ASKBlocksNumberNow: Integer);
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  BytesToReceive: TBytes;
begin
  GetResponse(IncomCountBytes);
  if Terminated or (IncomCount <= 0) then
    exit;

  SetLength(BytesToReceive, IncomCount * AppCore.GetSmartKeyBlockSize);
  GetResponse(BytesToReceive);
  if Terminated then
    exit;
  Logs.DoLog(Format('<DBC>[%d]: Blocks received = %d',
    [SmartKeySyncCommandCode, IncomCount]), INCOM, TLogFolder.sync);
  AppCore.SetSmartKeyBlocks(ASKBlocksNumberNow, BytesToReceive);
end;

//procedure TTokensChainsBlocksUpdater.ReceiveTokenBlocks(ATokenID: Integer;
//  const ABlocksCountNow: Int64);
//var
//  IncomCountBytes: array[0..3] of Byte;
//  IncomCount: Integer absolute IncomCountBytes;
//  BytesToReceive: TBytes;
//begin
//  GetResponse(IncomCountBytes);
//  if Terminated or (IncomCount <= 0) then
//    exit;
//
//  FNeedDelay := False;
//  SetLength(BytesToReceive, IncomCount * AppCore.GetTokenBlockSize);
//  GetResponse(BytesToReceive);
//  if Terminated then
//    exit;
//  Logs.DoLog(Format('<SmartC>[%d]: Token ID = %d, Blocks received = %d',
//    [TOKEN_SYNC_COMMAND_CODE,ATokenID,IncomCount]),INCOM,TLogFolder.sync);
//  AppCore.SetTokenBlocks(ATokenID,ABlocksCountNow,BytesToReceive);
//end;

//procedure TTokensChainsBlocksUpdater.DoTokenBlocksRequest(ATokenID: Integer);
//var
//  TokenIDBytes: array[0..3] of Byte;
//  TokenID: Integer absolute TokenIDBytes;
//  TokenBlocksCountBytes: array[0..7] of Byte;
//  TokenBlocksCount: Int64 absolute TokenBlocksCountBytes;
//begin
//  FBytesRequest[0] := TOKEN_SYNC_COMMAND_CODE;
//  TokenID := ATokenID;
//  Move(TokenIDBytes[0],FBytesRequest[1],4);
//  TokenBlocksCount := AppCore.GetTokenChainBlocksCount(ATokenID);
//  Move(TokenBlocksCountBytes[0],FBytesRequest[5],8);
//
//  FSocket.Send(FBytesRequest,0,13);
//  ReceiveTokenBlocks(ATokenID,TokenBlocksCount);
//end;

procedure TTokensChainsBlocksUpdater.DoRequests;
var
  i: Integer;
begin
  BreakableSleep(RequestTokenDelay);
  if Terminated then
    exit;

  try
    DoSmartKeyRequest;
    if Terminated then
      exit;
//    for i in AppCore.GetTokensToSynchronize do
//    begin
//      if Terminated then
//        exit;
//
//      DoTokenBlocksRequest(i);
//    end;
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
