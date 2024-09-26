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
      RECEIVE_DATA_TIMEOUT = 10000000;
    private
      FSocket: TSocket;
      FID: String;
      FIsActual: Boolean;
      FOnNewValidationRequest: TCheckFunc;
      FOnValidationDone: TGetStrProc;

      procedure Disconnect;
      procedure ReceiveRequest;
      function GetFullAddress: String;
//      function DoValidation: String;
      function GetTETChainBlocksToSend(out ABlocksNumber: Integer): TBytes;
      function GetTokenICOBlocksToSend(out ABlocksNumber: Integer): TBytes;
      function GetSmartKeyBlocksToSend(out ABlocksNumber: Integer): TBytes;
      function GetTokenChainBlocksToSend(out ATokenID: Integer;
        out ABlocksNumber: Integer): TBytes;
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

//function TConnectedClient.DoValidation: String;
//var
//  incomCountBytes: array[0..3] of Byte;
//  incomCount: Integer absolute incomCountBytes;
//  reqBytes: TBytes;
//  incomStr: String;
//  splt: TArray<String>;
//begin
//  FSocket.Receive(incomCountBytes,0,4,[TSocketFlag.WAITALL]);
//  SetLength(reqBytes,incomCount);
//  FSocket.Receive(reqBytes,0,incomCount,[TSocketFlag.WAITALL]);
//  try
//    incomStr := TEncoding.ANSI.GetString(reqBytes);
//    splt := incomStr.Trim.Split([' '], '<', '>');
//    if not FOnNewValidationRequest(splt[7]) then
//      Exit(Format('URKError U16 * 41505 <UserKey:%s>',[splt[1]]));
//    Logs.DoLog(Format('<From %s>[%d]: %s',[FID,VALIDATE_COMMAND_CODE,incomStr]),INCOM,tcp);
//    try
//      if ECDSACheckTextSign(splt[5].Trim(['<','>']),splt[6],HexToBytes(splt[7])) then
//      try
//        Result := AppCore.SendToConfirm(splt[1],incomStr);
//      except
//        on E:ESocketError do
//          Result := Format('URKError U16 * 41500 <UserKey:%s>',[splt[1]]);
//      end else
//        Result := Format('URKError U16 * 41502 <UserKey:%s>',[splt[1]]);
//    finally
//      FOnValidationDone(splt[7]);
//    end;
//  except
//    Result := Format('URKError U16 * 41501 <UserKey:%s>',[splt[1]]);
//  end;
//end;

function TConnectedClient.GetTETChainBlocksToSend(out ABlocksNumber: Integer): TBytes;
var
  IncomCountBytes: array[0..7] of Byte;
  IncomCount: Int64 absolute IncomCountBytes;
begin
  FSocket.Receive(incomCountBytes,0,8,[TSocketFlag.WAITALL]);
  Result := AppCore.GetTETChainBlocks(IncomCount);
  ABlocksNumber := Length(Result) div AppCore.GetTETChainBlockSize;
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

function TConnectedClient.GetSmartKeyBlocksToSend(
  out ABlocksNumber: Integer): TBytes;
var
  IncomCountBytes: array[0..7] of Byte;
  IncomCount: Int64 absolute IncomCountBytes;
begin
  FSocket.Receive(IncomCountBytes,0,8,[TSocketFlag.WAITALL]);
  Result := AppCore.GetSmartKeyBlocks(IncomCount);
  ABlocksNumber := Length(Result) div AppCore.GetSmartKeyBlockSize;
end;

function TConnectedClient.GetTokenICOBlocksToSend(out ABlocksNumber: Integer): TBytes;
var
  IncomCountBytes: array[0..7] of Byte;
  IncomCount: Int64 absolute IncomCountBytes;
begin
  FSocket.Receive(IncomCountBytes,0,8,[TSocketFlag.WAITALL]);
  Result := AppCore.GetTokenICOBlocks(IncomCount);
  ABlocksNumber := Length(Result) div AppCore.GetTokenICOBlockSize;
end;

function TConnectedClient.GetTokenChainBlocksToSend(out ATokenID: Integer;
  out ABlocksNumber: Integer): TBytes;
var
  TokenIDBytes: array[0..3] of Byte;
  TokenID: Integer absolute TokenIDBytes;
  IncomCountBytes: array[0..7] of Byte;
  IncomCount: Int64 absolute IncomCountBytes;
begin
  FSocket.Receive(TokenIDBytes,0,4,[TSocketFlag.WAITALL]);
  FSocket.Receive(IncomCountBytes,0,8,[TSocketFlag.WAITALL]);
  Result := AppCore.GetTokenChainBlocks(TokenID,IncomCount);
  ATokenID := TokenID;
  ABlocksNumber := Length(Result) div AppCore.GetTokenBlockSize;
end;

procedure TConnectedClient.ReceiveRequest;
var
  Command: Byte;
//  tranferResult: String;
  OutgoBytes: array[0..7] of Byte;
  OutgoInt: Integer absolute OutgoBytes;
  OutgoInt64: Integer absolute OutgoBytes;
  ToSend: TBytes;
  TokenID: Integer;
begin
  FSocket.Receive(Command,0,1,[TSocketFlag.WAITALL]);
  case Command of
    DISCONNECTING_CODE:
      begin
        FIsActual := False;
        Logs.DoLog(Format('%s disconnected',[FID]),OUTGO);
      end;

//    VALIDATE_COMMAND_CODE:
//      begin
//        tranferResult := DoValidation;
//        bytes := TEncoding.ANSI.GetBytes(tranferResult);
//        outgoBlocksAmount := Length(bytes);
//        FSocket.Send(outgoCountBytes,0,4);
//        FSocket.Send(bytes,0,outgoBlocksAmount);
//        Logs.DoLog(Format('<To %s>[%d]: %s',[FID,VALIDATE_COMMAND_CODE,
//          tranferResult]),OUTGO,tcp);
//      end;

    TET_CHAIN_TOTAL_COUNT_COMMAND_CODE:
      begin
        OutgoInt64 := AppCore.GetTETChainBlocksCount;
        FSocket.Send(OutgoBytes,0,8);

        Logs.DoLog(Format('<To %s>[%d]: Total count = %d',
          [FID,TET_CHAIN_TOTAL_COUNT_COMMAND_CODE,OutgoInt64]),OUTGO,sync);
      end;

    TET_CHAIN_SYNC_COMMAND_CODE:
      begin
        ToSend := GetTETChainBlocksToSend(OutgoInt);
        FSocket.Send(OutgoBytes,0,4);
        if OutgoInt = 0 then
          exit;

        FSocket.Send(ToSend,0,Length(ToSend));
        Logs.DoLog(Format('<To %s>[%d]: Blocks sended = %d',
          [FID,TET_CHAIN_SYNC_COMMAND_CODE,OutgoInt]),OUTGO,sync);
      end;

    TOKEN_ICO_SYNC_COMMAND_CODE:
      begin
        ToSend := GetTokenICOBlocksToSend(OutgoInt);
        FSocket.Send(OutgoBytes,0,4);
        if OutgoInt = 0 then
          exit;

        FSocket.Send(ToSend,0,Length(ToSend));
        Logs.DoLog(Format('<To %s>[%d]: Blocks sended = %d',
          [FID,TOKEN_ICO_SYNC_COMMAND_CODE,OutgoInt]),OUTGO,sync);
      end;

    SMARTKEY_SYNC_COMMAND_CODE:
      begin
        ToSend := GetSmartKeyBlocksToSend(OutgoInt);
        FSocket.Send(OutgoBytes,0,4);
        if OutgoInt = 0 then
          exit;

        FSocket.Send(ToSend,0,Length(ToSend));
        Logs.DoLog(Format('<To %s>[%d]: Blocks sended = %d',
          [FID,SMARTKEY_SYNC_COMMAND_CODE,OutgoInt]),OUTGO,sync);
      end;

    TOKEN_SYNC_COMMAND_CODE:
      begin
        AppCore.UpdateTokensList;
        ToSend := GetTokenChainBlocksToSend(TokenID,OutgoInt);
        FSocket.Send(OutgoBytes,0,4);
        if OutgoInt <= 0 then
          exit;

        FSocket.Send(ToSend,0,Length(ToSend));
        Logs.DoLog(Format('<To %s>[%d]: Token ID = %d, Blocks sended = %d',
          [FID,TOKEN_SYNC_COMMAND_CODE,TokenID,OutgoInt]),OUTGO,sync);
      end;

    else
      begin
        FIsActual := False;
        Logs.DoLog(Format('%s disconnected(unknown command)',[FID]),OUTGO);
      end;
  end;
end;

end.
