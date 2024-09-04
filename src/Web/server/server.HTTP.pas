unit server.HTTP;

interface

uses
  App.Exceptions,
  App.Intf,
  App.Logs,
  Classes,
  endpoints.Account,
  endpoints.Chain,
  endpoints.Token,
  Generics.Collections,
  JSON,
  IdContext,
  IdCustomHTTPServer,
  IdHTTPServer,
  Net.Socket,
  server.Types,
  SyncObjs,
  SysUtils;

type
  THTTPServer = class(TIdHTTPServer)
  const
    COMMAND_DOING_TIMEOUT = 12000;
  strict private
    FMainEndpoints: TMainEndpoints;
    FChainEndpoints: TChainEndpoints;
    FTokenEndpoints: TTokenEndpoints;
  private
    FCommands: TDictionary<String,TEndpointFunc>;
    procedure CommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start(APort: Word = 8917);
    procedure Stop;
  end;

implementation

{ THTTPServer }

procedure THTTPServer.CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  rawBODY: AnsiString;
  URI, body: String;
  FNum: LongWord;
  event: TEvent;
  answer: TEndpointResponse;
  epfunc: TEndpointFunc;
begin
  URI := ARequestInfo.Uri.ToLower.Trim;
  FNum := TThread.CurrentThread.ThreadID;
  Logs.DoLog(Format('<R%d> %s',[FNum,ARequestInfo.RawHTTPCommand]), INCOM, http);

  try
    try
      if not FCommands.TryGetValue(URI,epfunc) then
        raise ENotFoundError.Create('')
      else if AppCore.DownloadRemain > 0 then
        raise EDownloadingNotFinished.Create('');

      //get http request body
      if Assigned(ARequestInfo.PostStream) then
      begin
        if (ARequestInfo.PostStream is TMemoryStream) then
        begin
          const ms = TMemoryStream(ARequestInfo.PostStream);
          SetString(rawBODY, PAnsiChar(ms.memory), ms.Size);
          body := UTF8ToWideString(rawBODY);
        end;
      end;

      event := TEvent.Create;
      try
        answer := epfunc('R'+FNum.ToString,event,ARequestInfo.CommandType,ARequestInfo.Params,body);
        if not (event.WaitFor(COMMAND_DOING_TIMEOUT) = wrSignaled) then
          raise ESocketError.Create('');
      finally
        event.Free;
      end;
    except
      on E:ENotFoundError do
      begin
        answer.Code := HTTP_NOT_FOUND;
        answer.Response := GetJSONErrorAsString(ERROR_NOT_FOUND,'unknown request');
      end;
      on E:EDownloadingNotFinished do
      begin
        answer.Code := HTTP_SERVICE_UNAVAILABLE;
        answer.Response := GetJSONErrorAsString(ERROR_DOWNLOADING_NOT_FINISHED,'please wait until the blocks are loaded.');
      end;
      on E:ENotSupportedError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_NOT_SUPPORTED,'method not supported');
      end;
      on E:EJSONParseException do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_VALID,'request body parsing error');
      end;
      on E:EValidError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_VALID,E.Message);
      end;
      on E:EAuthError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_AUTH,'incorrect login or password');
      end;
      on E:EKeyExpiredError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_KEY_EXPIRED,'key expired');
      end;
      on E:EAccAlreadyExistsError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_ACCOUNT_EXISTS,'account already exists');
      end;
      on E:EAddressNotExistsError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_ADDRESS_NOT_EXISTS,'the address does not exists');
      end;
      on E:EInsufficientFundsError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_INSUFFICIENT_FUNDS,'insufficient funds');
      end;
      on E:ETokenAlreadyExists do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_TOKEN_EXISTS,'account already exists');
      end;
      on E:ESameAddressesError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_SAME_ADDRESSES,E.Message);
      end;
      on E:EValidatorDidNotAnswerError do
      begin
        answer.Code := HTTP_INTERNAL_ERROR;
        answer.Response := GetJSONErrorAsString(ERROR_VALIDATOR_DID_NOT_ANSWER,'validator did not answer, try later');
      end;
      on E:ESmartNotExistsError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_SMART_NOT_EXISTS,'smart contract does not exists');
      end;
      on E:ENoInfoForThisSmartError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_NO_INFO_FOR_SMART,'this smartcontract does not have the requested information');
      end;
      on E:ENoInfoForThisAccountError do
      begin
        answer.Code := HTTP_INTERNAL_ERROR;
        answer.Response := GetJSONErrorAsString(ERROR_NO_INFO_FOR_ACCOUNT,'this account does not have the requested information');
      end;
      on E:ESocketError do
      begin
        answer.Code := HTTP_INTERNAL_ERROR;
        answer.Response := GetJSONErrorAsString(ERROR_NO_RESPONSE,'server did not respond, try later');
      end;
      on E:EInvalidSignError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_INVALID_SIGN,'signature not verified');
      end;
      on E:ERequestInProgressError do
      begin
        answer.Code := HTTP_BAD_REQUEST;
        answer.Response := GetJSONErrorAsString(ERROR_REQUEST_IN_PROGRESS,'the previous transaction has not yet been processed');
      end;
      on E:EUnknownError do
      begin
        answer.Code := HTTP_INTERNAL_ERROR;
        answer.Response := GetJSONErrorAsString(ERROR_UNKNOWN,'unknown error with code ' + E.Message);
      end;
      on E:Exception do
      begin
        answer.Code := HTTP_INTERNAL_ERROR;
        answer.Response := GetJSONErrorAsString(ERROR_UNKNOWN,'unknown error with message:' + E.Message);
      end;
    end;
  finally
    AResponseInfo.ResponseNo := answer.Code;
    AResponseInfo.ContentText := answer.Response;
    Logs.DoLog(Format('<%s> [%d] %s',[answer.ReqID, AResponseInfo.ResponseNo, AResponseInfo.ContentText]), OUTGO, http);
  end;
end;

constructor THTTPServer.Create;
begin
  inherited;

  FCommands := TDictionary<String,TEndpointFunc>.Create;
  FChainEndpoints := TChainEndpoints.Create;
  FCommands.Add('/blockscountl',FChainEndpoints.blocksCountL);
  FCommands.Add('/blockscount',FChainEndpoints.blocksCount);
  FMainEndpoints := TMainEndpoints.Create;
  FCommands.Add('/user/registration',FMainEndpoints.reg);
  FCommands.Add('/user/auth',FMainEndpoints.auth);
  FCommands.Add('/keys/recover',FMainEndpoints.recoverKeys);
  FCommands.Add('/keys/public/byuserid',FMainEndpoints.getPublicKeyByAccID);
  FCommands.Add('/keys/public/byskey',FMainEndpoints.getPublicKeyBySessionKey);
  FTokenEndpoints := TTokenEndpoints.Create;
  FCommands.Add('/coins/transfer',FTokenEndpoints.coinTransfer);
  FCommands.Add('/coins/transfer/fee',FTokenEndpoints.getCoinTransferFee);
  FCommands.Add('/coins/balances',FTokenEndpoints.getCoinsBalances);
  FCommands.Add('/coins/transfers',FTokenEndpoints.coinsTransferHistory);
  FCommands.Add('/tokens',FTokenEndpoints.tokens);
  FCommands.Add('/token/fee',FTokenEndpoints.getNewTokenFee);
  FCommands.Add('/token/transfer',FTokenEndpoints.tokenTransfer);
  FCommands.Add('/token/transfer/fee',FTokenEndpoints.getTokenTransferFee);
  FCommands.Add('/token/balance/byaddress',FTokenEndpoints.getTokenBalanceWithAddress);
  FCommands.Add('/token/balance/byticker',FTokenEndpoints.getTokenBalanceWithTicker);
  FCommands.Add('/token/address/byid',FTokenEndpoints.getAddressByID);
  FCommands.Add('/token/address/byticker',FTokenEndpoints.getAddressByTicker);

  OnCommandGet := CommandGet;
end;

destructor THTTPServer.Destroy;
begin
  FTokenEndpoints.Free;
  FChainEndpoints.Free;
  FMainEndpoints.Free;
  FCommands.Free;

  inherited;
end;

procedure THTTPServer.Start(APort: Word);
begin
  DefaultPort := APort;
  Active := True;
  Logs.DoLog('HTTP server started',NONE);
end;

procedure THTTPServer.Stop;
begin
  Active := False;
  Logs.DoLog('HTTP server stoped',NONE);
end;

end.
