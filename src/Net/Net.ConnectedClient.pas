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
  TCheckFunc = function(AValue: string): Boolean of object;

  TConnectedClient = class(TThread)
    const
      RECEIVE_DATA_TIMEOUT = 10000;
    private
      FSocket: TSocket;
      FID: string;
      FIsActual: Boolean;
      FOnNewValidationRequest: TCheckFunc;
      FOnValidationDone: TGetStrProc;

      procedure Disconnect;
      procedure ReceiveRequest;
      function GetFullAddress: string;
      function DoValidation: string;
      function GetTETChainBlocksToSend(out ABlocksNumber: Integer): TBytes;
      function GetDynTETChainBlocksToSend(out ABlocksNumber: Integer): TBytes;
      function GetTokenICOBlocksToSend(out ABlocksNumber: Integer): TBytes;
      function GetSmartKeyBlocksToSend(out ABlocksNumber: Integer): TBytes;
      function GetTokenChainBlocksToSend(out ATokenID: Integer;
        out ABlocksNumber: Integer): TBytes;
      function GetDynTokenChainBlocksToSend(out ATokenID: Integer;
        out ABlocksNumber: Integer): TBytes;
    protected
      procedure Execute; override;
    public
      constructor Create(ASocket: TSocket; AOnNewValidationRequest: TCheckFunc;
        AOnValidationDone: TGetStrProc);
      destructor Destroy; override;

      property fullAddress: string read GetFullAddress;
      property getID: string read FID;
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
  FID := 'C' + (Random(9998) + 1).Tostring;
  Logs.DoLog(Format('%s connected, ID = %s',[GetFullAddress, FID]), INCOM);
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

function TConnectedClient.DoValidation: string;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
  IncomBytes: TBytes;
  IncomStr: string;
  Splitted: TArray<string>;
begin
  FSocket.Receive(IncomCountBytes, 0, 4, [TSocketFlag.WAITALL]);
  SetLength(IncomBytes, IncomCount);
  FSocket.Receive(IncomBytes, 0, IncomCount, [TSocketFlag.WAITALL]);
  try
    IncomStr := TEncoding.ANSI.GetString(IncomBytes);
    Splitted := IncomStr.Trim.Split([' '], '<', '>');
    if not FOnNewValidationRequest(Splitted[7]) then
      Exit(Format('URKError U16 * 41505 <UserKey:%s>', [Splitted[1]]));
    try
      if ECDSACheckTextSign(Splitted[5].Trim(['<','>']), Splitted[6],
        HexToBytes(Splitted[7])) then
      try
        Result := AppCore.SendToConfirm(Splitted[1], IncomStr);
      except
        on E:ESocketError do
          Result := Format('URKError U16 * 41500 <UserKey:%s>', [Splitted[1]]);
      end else
        Result := Format('URKError U16 * 41502 <UserKey:%s>', [Splitted[1]]);
    finally
      FOnValidationDone(Splitted[7]);
    end;
  except
    Result := Format('URKError U16 * 41501 <UserKey:%s>', [Splitted[1]]);
  end;
end;

function TConnectedClient.GetTETChainBlocksToSend(out ABlocksNumber: Integer): TBytes;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
begin
  FSocket.Receive(IncomCountBytes, 0, 4, [TSocketFlag.WAITALL]);
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
      Logs.DoLog(Format('%s unexpectedly disconnected', [FID]), OUTGO);
  end;
end;

function TConnectedClient.GetDynTETChainBlocksToSend(
  out ABlocksNumber: Integer): TBytes;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
begin
  FSocket.Receive(IncomCountBytes, 0, 4, [TSocketFlag.WAITALL]);
  Result := AppCore.GetDynTETChainBlocks(IncomCount);
  ABlocksNumber := Length(Result) div AppCore.GetDynTETChainBlockSize;
end;

function TConnectedClient.GetDynTokenChainBlocksToSend(out ATokenID,
  ABlocksNumber: Integer): TBytes;
var
  DataBytes: array[0..3] of Byte;
  DataInt: Integer absolute DataBytes;
begin
  FSocket.Receive(DataBytes, 0, 4, [TSocketFlag.WAITALL]);
  ATokenID := DataInt;
  FSocket.Receive(DataBytes, 0, 4, [TSocketFlag.WAITALL]);
  Result := AppCore.GetDynTokenChainBlocks(ATokenID, DataInt);
  ABlocksNumber := Length(Result) div AppCore.GetDynTokenChainBlockSize;
end;

function TConnectedClient.GetFullAddress: string;
begin
  Result := Format('%s:%d',[FSocket.Endpoint.Address.Address,
    FSocket.Endpoint.Port]);
end;

function TConnectedClient.GetSmartKeyBlocksToSend(
  out ABlocksNumber: Integer): TBytes;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
begin
  FSocket.Receive(IncomCountBytes, 0, 4, [TSocketFlag.WAITALL]);
  Result := AppCore.GetSmartKeyBlocks(IncomCount);
  ABlocksNumber := Length(Result) div AppCore.GetSmartKeyBlockSize;
end;

function TConnectedClient.GetTokenICOBlocksToSend(out ABlocksNumber: Integer): TBytes;
var
  IncomCountBytes: array[0..3] of Byte;
  IncomCount: Integer absolute IncomCountBytes;
begin
  FSocket.Receive(IncomCountBytes, 0, 4, [TSocketFlag.WAITALL]);
  Result := AppCore.GetTokenICOBlocks(IncomCount);
  ABlocksNumber := Length(Result) div AppCore.GetTokenICOBlockSize;
end;

function TConnectedClient.GetTokenChainBlocksToSend(out ATokenID: Integer;
  out ABlocksNumber: Integer): TBytes;
var
  DataBytes: array[0..3] of Byte;
  DataInt: Integer absolute DataBytes;
begin
  FSocket.Receive(DataBytes, 0, 4, [TSocketFlag.WAITALL]);
  ATokenID := DataInt;
  FSocket.Receive(DataBytes, 0, 4, [TSocketFlag.WAITALL]);
  Result := AppCore.GetTokenChainBlocks(ATokenID, DataInt);
  ABlocksNumber := Length(Result) div AppCore.GetTokenChainBlockSize;
end;

procedure TConnectedClient.ReceiveRequest;
var
  Command: Byte;
  Response: string;
  OutgoBytes: array[0..3] of Byte;
  OutgoBlocksNumber: Integer absolute OutgoBytes;
  ToSend: TBytes;
  TokenID: Integer;
begin
  FSocket.Receive(Command, 0, 1, [TSocketFlag.WAITALL]);
  case Command of
    DisconnectingCode:
      begin
        FIsActual := False;
        Logs.DoLog(Format('%s disconnected', [FID]), OUTGO);
      end;

    ValidateCommandCode:
      begin
        Response := DoValidation;
        ToSend := TEncoding.ANSI.GetBytes(Response);
        OutgoBlocksNumber := Length(ToSend);
        FSocket.Send(OutgoBytes, 0, 4);
        FSocket.Send(ToSend, 0, OutgoBlocksNumber);
      end;

    TETChainsTotalNumberCode:
      begin
        OutgoBlocksNumber := AppCore.GetDynTETChainBlocksCount;
        FSocket.Send(OutgoBytes, 0, 4);
        OutgoBlocksNumber := AppCore.GetTETChainBlocksCount;
        FSocket.Send(OutgoBytes, 0, 4);
      end;

    TETChainSyncCommandCode:
      begin
        ToSend := GetTETChainBlocksToSend(OutgoBlocksNumber);
        FSocket.Send(OutgoBytes, 0, 4);
        if OutgoBlocksNumber > 0 then
          FSocket.Send(ToSend, 0, Length(ToSend));
      end;

    DynTETChainSyncCommandCode:
      begin
        ToSend := GetDynTETChainBlocksToSend(OutgoBlocksNumber);
        FSocket.Send(OutgoBytes, 0, 4);
        if OutgoBlocksNumber > 0 then
          FSocket.Send(ToSend, 0, Length(ToSend));
      end;

    TokenICOSyncCommandCode:
      begin
        ToSend := GetTokenICOBlocksToSend(OutgoBlocksNumber);
        FSocket.Send(OutgoBytes, 0, 4);
        if OutgoBlocksNumber > 0 then
          FSocket.Send(ToSend, 0, Length(ToSend));
      end;

    SmartKeySyncCommandCode:
      begin
        AppCore.UpdateTokensList;
        ToSend := GetSmartKeyBlocksToSend(OutgoBlocksNumber);
        FSocket.Send(OutgoBytes, 0, 4);
        if OutgoBlocksNumber > 0 then
          FSocket.Send(ToSend, 0, Length(ToSend));
      end;

    TokenChainSyncCommandCode:
      begin
        ToSend := GetTokenChainBlocksToSend(TokenID, OutgoBlocksNumber);
        FSocket.Send(OutgoBytes, 0, 4);
        if OutgoBlocksNumber > 0 then
          FSocket.Send(ToSend, 0, Length(ToSend));
      end;

    DynTokenChainSyncCommandCode:
      begin
        ToSend := GetDynTokenChainBlocksToSend(TokenID, OutgoBlocksNumber);
        FSocket.Send(OutgoBytes, 0, 4);
        if OutgoBlocksNumber > 0 then
          FSocket.Send(ToSend, 0, Length(ToSend));
      end

    else
      begin
        FIsActual := False;
        Logs.DoLog(Format('%s disconnected(unknown command)', [FID]), OUTGO);
      end;
  end;
end;

end.
