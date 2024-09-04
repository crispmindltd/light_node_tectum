unit Net.ConnectedClient;

interface

uses
  App.Intf,
  App.Logs,
  Blockchain.Intf,
  Classes,
  Crypto,
  Net.Data,
  Net.Socket,
  SysUtils;

type
  TCheckFunc = function(AValue: String): Boolean of object;

  TConnectedClient = class(TThread)
    const
      RECEIVE_DATA_TIMEOUT = 10000;
    private
      FSocket: TSocket;
      FID: String;
      FIsActual: Boolean;
      FOnNewValidationRequest: TCheckFunc;
      FOnValidationDone: TGetStrProc;

      procedure Disconnect;
      procedure ReceiveRequest;
      function GetFullAddress: String;
      function DoValidation: String;
      function GetChainBlocksToSend(out AAmount: Integer): TBytesBlocks;
      function GetTokenICOBlocksToSend(out AAmount: Integer): TBytesBlocks;
      function GetSmartBlocksToSend(out ASmartID: Integer;
        out AAmount: Integer): TBytesBlocks;
      function GetDynBlocksToSend(var ADynID: Integer;
        out AAmount: Integer): TBytesBlocks;
    protected
      procedure Execute; override;
    public
      constructor Create(ASocket: TSocket; AOnNewValidationRequest: TCheckFunc;
        AOnValidationDone: TGetStrProc);
      destructor Destroy; override;

      property fullAddress: String read GetFullAddress;
      property getID: String read FID;
      property isActual: Boolean read FIsActual;
  end;

implementation

{ TConnectedClient }

constructor TConnectedClient.Create(ASocket: TSocket;
  AOnNewValidationRequest: TCheckFunc; AOnValidationDone: TGetStrProc);
begin
  inherited Create;

  FSocket := ASocket;
  FreeOnterminate := False;
  FIsActual := True;
  FOnNewValidationRequest := AOnNewValidationRequest;
  FOnValidationDone := AOnValidationDone;
  FSocket.ReceiveTimeout := RECEIVE_DATA_TIMEOUT;
  Randomize;
  FID := 'C' + (Random(9998) + 1).ToString;
  Logs.DoLog(Format('%s connected, ID = %s',[GetFullAddress, FID]),INCOM);
end;

destructor TConnectedClient.Destroy;
begin
  Disconnect;
  FSocket.Free;

  inherited;
end;

procedure TConnectedClient.Disconnect;
begin
  if TSocketState.Connected in FSocket.State then
  {$IFDEF MSWINDOWS}
    FSocket.Close(True);
  {$ELSE IFDEF LINUX}
    FSocket.Close;
  {$ENDIF}
end;

function TConnectedClient.DoValidation: String;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
  reqBytes: TBytes;
  incomStr: String;
  splt: TArray<String>;
begin
  FSocket.Receive(incomCountBytes,0,4,[TSocketFlag.WAITALL]);
  SetLength(reqBytes,incomCount);
  FSocket.Receive(reqBytes,0,incomCount,[TSocketFlag.WAITALL]);
  try
    incomStr := TEncoding.ANSI.GetString(reqBytes);
    splt := incomStr.Trim.Split([' '], '<', '>');
    if not FOnNewValidationRequest(splt[7]) then
      Exit(Format('URKError U16 * 41505 <UserKey:%s>',[splt[1]]));
    Logs.DoLog(Format('<From %s>[%d]: %s',[FID,VALIDATE_COMMAND_CODE,incomStr]),INCOM,tcp);
    try
      if ECDSACheckTextSign(splt[5].Trim(['<','>']),splt[6],HexToBytes(splt[7])) then
      try
        Result := AppCore.SendToConfirm(splt[1],incomStr);
      except
        on E:ESocketError do
          Result := Format('URKError U16 * 41500 <UserKey:%s>',[splt[1]]);
      end else
        Result := Format('URKError U16 * 41502 <UserKey:%s>',[splt[1]]);
    finally
      FOnValidationDone(splt[7]);
    end;
  except
    Result := Format('URKError U16 * 41501 <UserKey:%s>',[splt[1]]);
  end;
end;

function TConnectedClient.GetChainBlocksToSend(out AAmount: Integer): TBytesBlocks;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
begin
  FSocket.Receive(incomCountBytes,0,4,[TSocketFlag.WAITALL]);
//  Logs.DoLog(Format('<From %s>[%d]: blockNum=%d',
//    [FID,CHAIN_SYNC_COMMAND_CODE,incomCount]),INCOM,sync);
  Result := AppCore.GetChainBlocks(incomCount,AAmount);
end;

function TConnectedClient.GetDynBlocksToSend(var ADynID: Integer;
  out AAmount: Integer): TBytesBlocks;
var
  dynIDBytes:array[0..3] of Byte;
  incomDynID: Integer absolute dynIDBytes;
  incomCountBytes: array[0..3] of Byte;
  incomBlocksCount: Integer absolute incomCountBytes;
begin
  if ADynID = -1 then     //sync chain dynaminc blocks
  begin
    incomDynID := ADynID;
    FSocket.Receive(incomCountBytes,0,4,[TSocketFlag.WAITALL]);
//    Logs.DoLog(Format('<From %s>[%d]: blockNum=%d',
//    [FID,CHAIN_DYN_SYNC_COMMAND_CODE,incomBlocksCount]),INCOM,sync);
  end else
  begin                   //sync token dynamic blocks
    FSocket.Receive(dynIDBytes,0,4,[TSocketFlag.WAITALL]);
    FSocket.Receive(incomCountBytes,0,4,[TSocketFlag.WAITALL]);
//    Logs.DoLog(Format('<From %s>[%d]: dynID=%d, blockNum=%d',
//      [FID,SMART_DYN_SYNC_COMMAND_CODE,incomDynID,incomBlocksCount]),INCOM,sync);
    ADynID := incomDynID;
  end;

  Result := AppCore.GetDynBlocks(incomDynID,incomBlocksCount,AAmount);
end;

procedure TConnectedClient.Execute;
begin
  inherited;

  try
    repeat
      ReceiveRequest;
    until not FIsActual or Terminated;
  except
    on E:ESocketError do
      Logs.DoLog(Format('%s unexpectedly disconnected',[FID]),OUTGO);
  end;
end;

function TConnectedClient.GetFullAddress: String;
begin
  Result := Format('%s:%d',[FSocket.Endpoint.Address.Address,FSocket.Endpoint.Port]);
end;

function TConnectedClient.GetTokenICOBlocksToSend(out AAmount: Integer): TBytesBlocks;
var
  incomCountBytes: array[0..3] of Byte;
  incomCount: Integer absolute incomCountBytes;
begin
  FSocket.Receive(incomCountBytes,0,4,[TSocketFlag.WAITALL]);
//  Logs.DoLog(Format('<From %s>[%d]: blockNum=%d',
//    [FID,TOKEN_ICO_SYNC_COMMAND_CODE,incomCount]),INCOM,sync);
  Result := AppCore.GetICOBlocks(incomCount,AAmount);
end;

function TConnectedClient.GetSmartBlocksToSend(out ASmartID: Integer;
  out AAmount: Integer): TBytesBlocks;
var
  smIDBytes:array[0..3] of Byte;
  incomSmartID: Integer absolute smIDBytes;
  incomCountBytes: array[0..3] of Byte;
  incomBlocksCount: Integer absolute incomCountBytes;
begin
  FSocket.Receive(smIDBytes,0,4,[TSocketFlag.WAITALL]);
  FSocket.Receive(incomCountBytes,0,4,[TSocketFlag.WAITALL]);
//  Logs.DoLog(Format('<From %s>[%d]: smartID=%d, blockNum=%d',
//    [FID,SMART_SYNC_COMMAND_CODE,incomSmartID,incomBlocksCount]),INCOM,sync);
  Result := AppCore.GetSmartBlocks(incomSmartID,incomBlocksCount,AAmount);
  ASmartID := incomSmartID;
end;

procedure TConnectedClient.ReceiveRequest;
var
  command: Byte;
  ID: Integer;
  tranferResult: String;
  outgoCountBytes: array[0..3] of Byte;
  outgoBlocksAmount: Integer absolute outgoCountBytes;
  bytes: TBytes;
  toSend: TBytesBlocks;
begin
  FSocket.Receive(command,0,1,[TSocketFlag.WAITALL]);
  case command of
    DISCONNECTING_CODE:
      begin
        FIsActual := False;
        Logs.DoLog(Format('%s disconnected',[FID]),OUTGO);
      end;

    VALIDATE_COMMAND_CODE:
      begin
        tranferResult := DoValidation;
        bytes := TEncoding.ANSI.GetBytes(tranferResult);
        outgoBlocksAmount := Length(bytes);
        FSocket.Send(outgoCountBytes,0,4);
        FSocket.Send(bytes,0,outgoBlocksAmount);
        Logs.DoLog(Format('<To %s>[%d]: %s',[FID,VALIDATE_COMMAND_CODE,
          tranferResult]),OUTGO,tcp);
      end;

    CHAIN_TOTAL_COUNT_COMMAND_CODE:
      begin
        outgoBlocksAmount := AppCore.GetChainBlocksCount;
        FSocket.Send(outgoCountBytes,0,4);

        Logs.DoLog(Format('<To %s>[%d]: totalCount=%d',
          [FID,CHAIN_TOTAL_COUNT_COMMAND_CODE,outgoBlocksAmount]),OUTGO,sync);
      end;

    CHAIN_SYNC_COMMAND_CODE:
      begin
        toSend := GetChainBlocksToSend(outgoBlocksAmount);
        FSocket.Send(outgoCountBytes,0,4);
        if outgoBlocksAmount = 0 then exit;

        FSocket.Send(toSend,0,outgoBlocksAmount * AppCore.GetChainBlockSize);
        Logs.DoLog(Format('<To %s>[%d]: blocksSended=%d',
          [FID,CHAIN_SYNC_COMMAND_CODE,outgoBlocksAmount]),OUTGO,sync);
      end;

    DYN_CHAIN_TOTAL_COUNT_COMMAND_CODE:
      begin
        outgoBlocksAmount := AppCore.GetDynBlocksCount(-1);
        FSocket.Send(outgoCountBytes,0,4);

        Logs.DoLog(Format('<To %s>[%d]: totalCount=%d',
          [FID,DYN_CHAIN_TOTAL_COUNT_COMMAND_CODE,outgoBlocksAmount]),OUTGO,sync);
      end;

    CHAIN_DYN_SYNC_COMMAND_CODE:
      begin
        ID := -1;
        toSend := GetDynBlocksToSend(ID,outgoBlocksAmount);
        FSocket.Send(outgoCountBytes,0,4);
        if outgoBlocksAmount = 0 then exit;

        FSocket.Send(toSend,0,outgoBlocksAmount * AppCore.GetDynBlockSize(ID));
        Logs.DoLog(Format('<To %s>[%d]: blocksSended=%d',
          [FID,CHAIN_DYN_SYNC_COMMAND_CODE,ID,outgoBlocksAmount]),OUTGO,sync);
      end;

    TOKEN_ICO_SYNC_COMMAND_CODE:
      begin
        toSend := GetTokenICOBlocksToSend(outgoBlocksAmount);
        FSocket.Send(outgoCountBytes,0,4);
        if outgoBlocksAmount = 0 then exit;

        FSocket.Send(toSend,0,outgoBlocksAmount * AppCore.GetICOBlockSize);
        Logs.DoLog(Format('<To %s>[%d]: blocksSended=%d',
          [FID,TOKEN_ICO_SYNC_COMMAND_CODE,outgoBlocksAmount]),OUTGO,sync);
      end;

    SMART_SYNC_COMMAND_CODE:
      begin
        AppCore.UpdateLists;
        toSend := GetSmartBlocksToSend(ID,outgoBlocksAmount);
        FSocket.Send(outgoCountBytes,0,4);
        if outgoBlocksAmount <= 0 then exit;

        FSocket.Send(toSend,0,outgoBlocksAmount * AppCore.GetSmartBlockSize(ID));
        Logs.DoLog(Format('<To %s>[%d]: smartID=%d, blocksSended=%d',
          [FID,SMART_SYNC_COMMAND_CODE,ID,outgoBlocksAmount]),OUTGO,sync);
      end;

    SMART_DYN_SYNC_COMMAND_CODE:
      begin
        toSend := GetDynBlocksToSend(ID,outgoBlocksAmount);
        FSocket.Send(outgoCountBytes,0,4);
        if outgoBlocksAmount = 0 then exit;

        FSocket.Send(toSend,0,outgoBlocksAmount * AppCore.GetDynBlockSize(ID));
        Logs.DoLog(Format('<To %s>[%d]: smartID=%d, blocksSended=%d',
          [FID,SMART_DYN_SYNC_COMMAND_CODE,ID,outgoBlocksAmount]),OUTGO,sync);
      end;

    else
      begin
        FIsActual := False;
        Logs.DoLog(Format('%s disconnected(unknown command)',[FID]),OUTGO);
      end;
  end;
end;

end.
