unit Sync.Tokens;

interface

uses
  App.Constants,
  App.Exceptions,
  App.Intf,
  App.Logs,
  Blockchain.BaseTypes,
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
      procedure ReceiveSmartKeyBlocks(const ABlocksCountNow: Int64);
      procedure DoTokenBlocksRequest(ATokenID: Integer);
      procedure ReceiveTokenBlocks(ATokenID: Integer;
        const ABlocksCountNow: Int64);
    protected
      procedure Execute; override;
    public
      constructor Create(AAddress: String; APort: Word);
      destructor Destroy; override;
  end;

implementation

{ TTokensChainsBlocksUpdater }

constructor TTokensChainsBlocksUpdater.Create(AAddress: String; APort: Word);
begin
  inherited Create(ConstStr.SmartCPath, AAddress,APort);

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

procedure TTokensChainsBlocksUpdater.ReceiveSmartKeyBlocks(
  const ABlocksCountNow: Int64);
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
    [SMARTKEY_SYNC_COMMAND_CODE,IncomCount]),INCOM,TLogFolder.sync);
  AppCore.SetSmartKeyBlocks(ABlocksCountNow,BytesToReceive);
end;

procedure TTokensChainsBlocksUpdater.ReceiveTokenBlocks(ATokenID: Integer;
  const ABlocksCountNow: Int64);
//var
//  incomCountBytes: array[0..3] of Byte;
//  incomCount: Integer absolute incomCountBytes;
//  inBytes: TBytesBlocks;
begin
//  GetResponse(incomCountBytes,4);
//  if Terminated then
//    exit(False);
//  Result := incomCount > -1;
//  if incomCount <= 0 then
//  begin
//    FNeedDelay := True;
//    exit;
//  end;
//
//  FNeedDelay := False;
//  GetResponse(inBytes,incomCount * AppCore.GetSmartBlockSize(ASmartID));
//  if Terminated then
//    exit;
//
//  Logs.DoLog(Format('<SmartC>[%d]: smartID=%d, blocksReceived=%d',
//    [SMART_SYNC_COMMAND_CODE,ASmartID,incomCount]),INCOM,TLogFolder.sync);
//  AppCore.SetSmartBlocks(ASmartID,ABlocksCountNow,inBytes,incomCount);
end;

procedure TTokensChainsBlocksUpdater.DoTokenBlocksRequest(ATokenID: Integer);
var
  TokenIDBytes: array[0..3] of Byte;
  TokenID: Integer absolute TokenIDBytes;
  TokenBlocksCountBytes: array[0..7] of Byte;
  TokenBlocksCount: Int64 absolute TokenBlocksCountBytes;
begin
  FBytesRequest[0] := TOKEN_SYNC_COMMAND_CODE;
  TokenID := ATokenID;
  Move(TokenIDBytes[0],FBytesRequest[1],4);
  TokenBlocksCount := AppCore.GetTokenChainBlocksCount(ATokenID);
  Move(TokenBlocksCountBytes[0],FBytesRequest[5],8);

  FSocket.Send(FBytesRequest,0,13);
  ReceiveTokenBlocks(ATokenID,TokenBlocksCount);
end;

procedure TTokensChainsBlocksUpdater.DoRequests;
var
  ICODat: TTokenICODat;
  i: Integer;
begin
  if FNeedDelay then
    BreakableSleep(RequestLongDelay)
  else
    Sleep(RequestShortDelay);
  if Terminated then
    exit;

  try
    DoSmartKeyRequest;
    if Terminated then
      exit;

    for i := 0 to AppCore.GetTokenICOBlocksCount - 1 do
    begin
      if Terminated then
        exit;

//      DoSmartRequest(smartKey.SmartID);
    end;
  except
    on E:EReceiveTimeout do
      if not DoTryReconnect then raise;
  end;
end;

procedure TTokensChainsBlocksUpdater.DoSmartKeyRequest;
var
  SmartKeyBlocksCountBytes: array[0..7] of Byte;
  SmartKeyBlocksCount: Int64 absolute SmartKeyBlocksCountBytes;
begin
  FBytesRequest[0] := SMARTKEY_SYNC_COMMAND_CODE;
  SmartKeyBlocksCount := AppCore.GetSmartKeyBlocksCount;
  Move(SmartKeyBlocksCountBytes[0],FBytesRequest[1],8);

  FSocket.Send(FBytesRequest,0,9);
  ReceiveSmartKeyBlocks(SmartKeyBlocksCount);
end;

end.
