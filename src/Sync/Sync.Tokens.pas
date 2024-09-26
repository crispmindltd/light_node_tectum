unit Sync.Tokens;

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
      procedure ReceiveSmartKeyBlocks(const ABlocksCountNow: Integer);
//      function DoSmartRequest(ASmartID: Integer): Boolean;
//      function ReceiveSmartBlocks(const ASmartID: Integer;
//        const ABlocksCountNow: Integer): Boolean;
//      function DoDynamicRequest(ADynID: Integer): Boolean;
//      function ReceiveDynamicBlocks(const ADynID: Integer;
//        const ABlocksCountNow: Integer): Boolean;
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
  const ABlocksCountNow: Integer);
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

//function TSmartBlocksUpdater.ReceiveDynamicBlocks(const ADynID,
//  ABlocksCountNow: Integer): Boolean;
//var
//  incomCountBytes: array[0..3] of Byte;
//  incomCount: Integer absolute incomCountBytes;
//  inBytes: TBytesBlocks;
//begin
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
//  GetResponse(inBytes,incomCount * AppCore.GetDynBlockSize(ADynID));
//  if Terminated then
//    exit;
//
//  Logs.DoLog(Format('<SmartC>[%d]: dynID=%d, blocksReceived=%d',
//    [SMART_DYN_SYNC_COMMAND_CODE,ADynID,incomCount]),INCOM,TLogFolder.sync);
//  AppCore.SetDynBlocks(ADynID,ABlocksCountNow,inBytes,incomCount);
//end;

//function TSmartBlocksUpdater.ReceiveSmartBlocks(const ASmartID: Integer;
//  const ABlocksCountNow: Integer): Boolean;
//var
//  incomCountBytes: array[0..3] of Byte;
//  incomCount: Integer absolute incomCountBytes;
//  inBytes: TBytesBlocks;
//begin
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
//end;

//function TSmartBlocksUpdater.DoSmartRequest(ASmartID: Integer): Boolean;
//var
//  smIDBytes:array[0..3] of Byte;
//  smartID: Integer absolute smIDBytes;
//  bCountBytes:array[0..3] of Byte;
//  blocksCount: Integer absolute bCountBytes;
//begin
//  FBytesRequest[0] := SMART_SYNC_COMMAND_CODE;
//  smartID := ASmartID;
//  Move(smIDBytes[0],FBytesRequest[1],4);   //add smart ID into request
//  blocksCount := AppCore.GetSmartBlocksCount(smartID);
//  Move(bCountBytes[0],FBytesRequest[5],4); //add smart blocks count into request
//
//  FSocket.Send(FBytesRequest,0,9);
//  Logs.DoLog(Format('<SmartC>[%d]: smartID=%d, blockNum=%d',
//    [SMART_SYNC_COMMAND_CODE,smartID,blocksCount]),OUTGO,TLogFolder.sync);
//  Result := ReceiveSmartBlocks(smartID,blocksCount);
//end;

//function TSmartBlocksUpdater.DoDynamicRequest(ADynID: Integer): Boolean;
//var
//  dynIDBytes:array[0..3] of Byte;
//  dynID: Integer absolute dynIDBytes;
//  bCountBytes:array[0..3] of Byte;
//  blocksCount: Integer absolute bCountBytes;
//begin
//  FBytesRequest[0] := SMART_DYN_SYNC_COMMAND_CODE;
//  dynID := ADynID;
//  Move(dynIDBytes[0],FBytesRequest[1],4);   //add dynamic block ID into request
//  blocksCount := AppCore.GetDynBlocksCount(dynID);
//  Move(bCountBytes[0],FBytesRequest[5],4); //add dynamic blocks count into request
//
//  FSocket.Send(FBytesRequest,0,9);
//  Logs.DoLog(Format('<SmartC>[%d]: dynID=%d, blockNum=%d',
//    [SMART_DYN_SYNC_COMMAND_CODE,dynID,blocksCount]),OUTGO,TLogFolder.sync);
//  Result := ReceiveDynamicBlocks(dynID,blocksCount);
//end;

procedure TTokensChainsBlocksUpdater.DoRequests;
var
//  smartKey: TCSmartKey;
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

//    for i := 0 to AppCore.GetSmartBlocksCount(-1)-1 do
//    begin
//      if Terminated then
//        exit;
//
//      smartKey := AppCore.GetOneSmartKeyBlock(i);
//      DoDynamicRequest(smartKey.SmartID);
//      if Terminated then
//        exit;
//      DoSmartRequest(smartKey.SmartID);
//    end;
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