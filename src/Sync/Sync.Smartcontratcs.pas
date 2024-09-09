unit Sync.Smartcontratcs;

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
  TSmartBlocksUpdater = class(TSyncChain)
    private
      FBytesRequest: array[0..8] of Byte;

      procedure DoRequests;
      function DoSmartRequest(ASmartID: Integer): Boolean;
      function ReceiveSmartBlocks(const ASmartID: Integer;
        const ABlocksCountNow: Integer): Boolean;
      function DoDynamicRequest(ADynID: Integer): Boolean;
      function ReceiveDynamicBlocks(const ADynID: Integer;
        const ABlocksCountNow: Integer): Boolean;
    protected
      procedure Execute; override;
    public
      constructor Create(AAddress: String; APort: Word);
      destructor Destroy; override;
  end;

implementation

{ TBLocksUpdater }

constructor TSmartBlocksUpdater.Create(AAddress: String; APort: Word);
begin
  inherited Create(ConstStr.SmartCPath, AAddress,APort);

end;

destructor TSmartBlocksUpdater.Destroy;
begin

  inherited;
end;

procedure TSmartBlocksUpdater.Execute;
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

function TSmartBlocksUpdater.ReceiveDynamicBlocks(const ADynID,
  ABlocksCountNow: Integer): Boolean;
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
  GetResponse(inBytes,incomCount * AppCore.GetDynBlockSize(ADynID));
  if Terminated then exit;

  Logs.DoLog(Format('<SmartC>[%d]: dynID=%d, blocksReceived=%d',
    [SMART_DYN_SYNC_COMMAND_CODE,ADynID,incomCount]),INCOM,TLogFolder.sync);
  AppCore.SetDynBlocks(ADynID,ABlocksCountNow,inBytes,incomCount);
end;

function TSmartBlocksUpdater.ReceiveSmartBlocks(const ASmartID: Integer;
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
  GetResponse(inBytes,incomCount * AppCore.GetSmartBlockSize(ASmartID));
  if Terminated then exit;

  Logs.DoLog(Format('<SmartC>[%d]: smartID=%d, blocksReceived=%d',
    [SMART_SYNC_COMMAND_CODE,ASmartID,incomCount]),INCOM,TLogFolder.sync);
  AppCore.SetSmartBlocks(ASmartID,ABlocksCountNow,inBytes,incomCount);
end;

function TSmartBlocksUpdater.DoSmartRequest(ASmartID: Integer): Boolean;
var
  smIDBytes:array[0..3] of Byte;
  smartID: Integer absolute smIDBytes;
  bCountBytes:array[0..3] of Byte;
  blocksCount: Integer absolute bCountBytes;
begin
  FBytesRequest[0] := SMART_SYNC_COMMAND_CODE;
  smartID := ASmartID;
  Move(smIDBytes[0],FBytesRequest[1],4);   //add smart ID into request
  blocksCount := AppCore.GetSmartBlocksCount(smartID);
  Move(bCountBytes[0],FBytesRequest[5],4); //add smart blocks count into request

  FSocket.Send(FBytesRequest,0,9);
  Logs.DoLog(Format('<SmartC>[%d]: smartID=%d, blockNum=%d',
    [SMART_SYNC_COMMAND_CODE,smartID,blocksCount]),OUTGO,TLogFolder.sync);
  Result := ReceiveSmartBlocks(smartID,blocksCount);
end;

function TSmartBlocksUpdater.DoDynamicRequest(ADynID: Integer): Boolean;
var
  dynIDBytes:array[0..3] of Byte;
  dynID: Integer absolute dynIDBytes;
  bCountBytes:array[0..3] of Byte;
  blocksCount: Integer absolute bCountBytes;
begin
  FBytesRequest[0] := SMART_DYN_SYNC_COMMAND_CODE;
  dynID := ADynID;
  Move(dynIDBytes[0],FBytesRequest[1],4);   //add dynamic block ID into request
  blocksCount := AppCore.GetDynBlocksCount(dynID);
  Move(bCountBytes[0],FBytesRequest[5],4); //add dynamic blocks count into request

  FSocket.Send(FBytesRequest,0,9);
  Logs.DoLog(Format('<SmartC>[%d]: dynID=%d, blockNum=%d',
    [SMART_DYN_SYNC_COMMAND_CODE,dynID,blocksCount]),OUTGO,TLogFolder.sync);
  Result := ReceiveDynamicBlocks(dynID,blocksCount);
end;

procedure TSmartBlocksUpdater.DoRequests;
var
  smartKey: TCSmartKey;
  i: Integer;
begin
  if FNeedDelay then
    BreakableSleep(REQUEST_LONG_DELAY)
  else
    Sleep(REQUEST_SHORT_DELAY);
  if Terminated then exit;

  try
    DoSmartRequest(-1);  //loading SmartKey.db
    if Terminated then exit;

    for i := 0 to AppCore.GetSmartBlocksCount(-1)-1 do
    begin
      if Terminated then exit;

      smartKey := AppCore.GetOneSmartKeyBlock(i);
//        if not UI.IsChainNeedSync(smartKey.SmartID.ToString + '.chn') then
      DoDynamicRequest(smartKey.SmartID);
      if Terminated then exit;
      DoSmartRequest(smartKey.SmartID);
    end;
  except
    on E:EReceiveTimeout do
      if not DoTryReconnect then raise;
  end;
end;

end.
