unit endpoints.Token;

interface

uses
  App.Exceptions,
  App.Intf,
  Blockchain.BaseTypes,
  Classes,
  DateUtils,
  endpoints.Base,
  JSON,
  IdCustomHTTPServer,
  IOUtils,
  Net.Data,
  server.Types,
  SyncObjs,
  SysUtils;

type
  TTokenEndpoints = class(TEndpointsBase)
  private
    function GetTokensList(AParams: TStrings): TEndpointResponse;
    function DoNewToken(AReqID: string; ABody: string): TEndpointResponse;
  public
    constructor Create;
    destructor Destroy; override;

    function Tokens(AReqID: string; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: string): TEndpointResponse;
    function GetNewTokenFee(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function DoTokenTransfer(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetTokenTransferFee(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function DoCoinTransfer(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetCoinTransferFee(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetCoinsBalances(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetCoinsTransferHistory(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetCoinsTransferHistoryUser(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetTokenBalanceWithAddress(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetTokenBalanceWithTicker(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetTokensTransferHistory(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetAddressByID(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetAddressByTicker(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
  end;

implementation

function StrToExtended(AStrValue:string):Extended;
begin
  if FormatSettings.DecimalSeparator = '.' then
    Result := AStrValue.Replace(',', '.').ToExtended
  else
    Result := AStrValue.ToExtended;
end;

// calculates digits after decimal separator
function DecimalsCount(const AValue: string): Integer;
begin
  var LValue:string := AValue //
    .Trim //
    .Replace('.', FormatSettings.DecimalSeparator) //
    .Replace(',', FormatSettings.DecimalSeparator) //
    .ToUpper;

  var Exponent:Integer := 0;
  const ExponentPos = Pos('E', LValue);

  if ExponentPos > 0 then begin
    Exponent := StrToInt(Copy(LValue, ExponentPos + 1));
    LValue := Copy(LValue, 1, ExponentPos - 1);
  end;

  const DecimalPos = Pos(FormatSettings.DecimalSeparator, LValue);

  if DecimalPos = 0 then
    Result := -Exponent
  else
    Result := Length(LValue) - DecimalPos - Exponent;

  if Result < 0 then Result := 0;
end;

{ TTokenEndpoints }

function TTokenEndpoints.DoCoinTransfer(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  SessionKey, TransTo, Response: string;
  Amount: Extended;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not(JSON.TryGetValue('session_key', SessionKey) and
             JSON.TryGetValue('to', TransTo) and
             JSON.TryGetValue('amount', Amount)) then
        raise EValidError.Create('request parameters error');

      const TETsDecimals = 8;
      const AmountStr = JSON.GetValue<string>('amount', '');
      if not AmountStr.IsEmpty and (DecimalsCount(AmountStr) > TETsDecimals) then
        raise EValidError.Create('too much decimals');

    finally
      JSON.Free;
    end;

    Response := AppCore.DoCoinsTransfer(AReqID, SessionKey, TransTo, Amount);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('hash', Response.Split([' '])[3].ToLower);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetCoinsTransferHistory(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON, JSONNestedObject: TJSONObject;
  JSONArray: TJSONArray;
  Params: TStringList;
  TETTransfersInfo: TArray<TExplorerTransactionInfo>;
  i, Rows, Skip: Integer;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['rows'].IsEmpty then
      Rows := 20
    else if not TryStrToInt(Params.Values['rows'], Rows) then
      raise EValidError.Create('request parameters error');
    if Params.Values['skip'].IsEmpty then
      Skip := 0
    else if not TryStrToInt(Params.Values['skip'], Skip) then
      raise EValidError.Create('request parameters error');

    TETTransfersInfo := AppCore.GetChainTransations(Skip, Rows);
    JSON := TJSONObject.Create;
    try
      JSONArray := TJSONArray.Create;
      for i := 0 to Rows - 1 do
      begin
        JSONArray.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
        JSONNestedObject.AddPair('date', TJSONNumber.Create(
          DateTimeToUnix(TETTransfersInfo[i].DateTime)));
        JSONNestedObject.AddPair('block',
          TJSONNumber.Create(TETTransfersInfo[i].BlockNum));
        JSONNestedObject.AddPair('address_from', TETTransfersInfo[i].TransFrom);
        JSONNestedObject.AddPair('address_to', TETTransfersInfo[i].TransTo);
        JSONNestedObject.AddPair('hash', TETTransfersInfo[i].Hash);
        JSONNestedObject.AddPair('amount',
          TJSONNumber.Create(TETTransfersInfo[i].Amount));
        JSONNestedObject.AddPair('fee', TJSONNumber.Create(0));
      end;
      JSON.AddPair('transactions', JSONArray);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetCoinsTransferHistoryUser(AReqID: string;
  AEvent: TEvent; AComType: THTTPCommandType; AParams: TStrings; ABody: string)
  : TEndpointResponse;
var
  JSON, JSONNestedObject: TJSONObject;
  JSONArray: TJSONArray;
  Params: TStringList;
  TETTransfersInfo: TArray<THistoryTransactionInfo>;
  TransInfo: TArray<string>;
  i, UserId, Rows, Skip: Integer;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['user_id'].IsEmpty or
      not TryStrToInt(Params.Values['user_id'], UserId) then
      raise EValidError.Create('request parameters error');
    if Params.Values['rows'].IsEmpty then
      Rows := 20
    else if not TryStrToInt(Params.Values['rows'], Rows) then
      raise EValidError.Create('request parameters error');
    if Params.Values['skip'].IsEmpty then
      Skip := 0
    else if not TryStrToInt(Params.Values['skip'], Skip) then
      raise EValidError.Create('request parameters error');

    TETTransfersInfo := AppCore.GetChainUserTransactions(UserId, Skip, Rows);
    JSON := TJSONObject.Create;
    try
      JSONArray := TJSONArray.Create;
      for i := 0 to Rows - 1 do
      begin
        JSONArray.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
        JSONNestedObject.AddPair('date', TJSONNumber.Create(
          DateTimeToUnix(TETTransfersInfo[i].DateTime)));
        JSONNestedObject.AddPair('block',
          TJSONNumber.Create(TETTransfersInfo[i].BlockNum));
        JSONNestedObject.AddPair('address', TETTransfersInfo[i].Address);
        JSONNestedObject.AddPair('incoming',
          TJSONBool.Create(TETTransfersInfo[i].Incom));
        JSONNestedObject.AddPair('hash', TETTransfersInfo[i].Hash);
        JSONNestedObject.AddPair('amount',
          TJSONNumber.Create(TETTransfersInfo[i].Amount));
        JSONNestedObject.AddPair('fee', TJSONNumber.Create(0));
      end;
      JSON.AddPair('transactions', JSONArray);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

constructor TTokenEndpoints.Create;
begin
  inherited;
end;

destructor TTokenEndpoints.Destroy;
begin

  inherited;
end;

function TTokenEndpoints.GetAddressByID(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  Response: string;
  Params: TStringList;
  TokenId: Integer;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['smart_id'].IsEmpty or
      (not TryStrToInt(Params.Values['smart_id'], TokenId)) then
      raise EValidError.Create('request parameters error');

    Response := AppCore.GetSmartAddressByID(TokenId);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('smart_address', Response);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetAddressByTicker(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  Response: string;
  Params: TStringList;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['ticker'].IsEmpty then
      raise EValidError.Create('request parameters error');

    Response := AppCore.GetSmartAddressByTicker(Params.Values['ticker']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('smart_address', Response);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetTokenBalanceWithAddress(AReqID: string;
  AEvent: TEvent; AComType: THTTPCommandType; AParams: TStrings; ABody: string)
  : TEndpointResponse;
var
  JSON: TJSONObject;
  Params: TStringList;
  balance: Extended;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['address_tet'].IsEmpty or
      Params.Values['smart_address'].IsEmpty then
      raise EValidError.Create('request parameters error');

    balance := AppCore.GetLocalTokenBalance(Params.Values['smart_address'],
                                            Params.Values['address_tet']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('balance', FormatFloat('0.########', balance));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetTokenBalanceWithTicker(AReqID: string;
  AEvent: TEvent; AComType: THTTPCommandType; AParams: TStrings; ABody: string)
  : TEndpointResponse;
var
  JSON: TJSONObject;
  balance: Extended;
  Params: TStringList;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['address_tet'].IsEmpty or
       Params.Values['ticker'].IsEmpty then
      raise EValidError.Create('request parameters error');

    balance := AppCore.GetLocalTokenBalance(Params.Values['ticker'].ToUpper,
                                            Params.Values['address_tet']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('balance', FormatFloat('0.########', balance));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetTokensList(AParams: TStrings): TEndpointResponse;
var
  JSON, JSONNestedObject: TJSONObject;
  JSONArray: TJSONArray;
  TokensICOs: TArray<TTokenICODat>;
  Params: TStringList;
  SmartKey: TCSmartKey;
  i,Rows,Skip: Integer;
begin
  Params := TStringList.Create(dupIgnore, True, False);
  try
    Params.AddStrings(AParams);
    if Params.Values['rows'].IsEmpty then
      Rows := 20
    else if not TryStrToInt(Params.Values['rows'], Rows) then
      raise EValidError.Create('request parameters error');
    if Params.Values['skip'].IsEmpty then
      Skip := 0
    else if not TryStrToInt(Params.Values['skip'], Skip) then
      raise EValidError.Create('request parameters error');

    TokensICOs := AppCore.GetTokensICOs(Skip, Rows);
    JSON := TJSONObject.Create;
    try
      JSONArray := TJSONArray.Create;
      for i := 0 to Rows - 1 do
      begin
        if not AppCore.TryGetTokenBase(Trim(TokensICOs[i].Abreviature),SmartKey) then
          continue;

        JSONArray.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
        JSONNestedObject.AddPair('id', TJSONNumber.Create(SmartKey.SmartID));
        JSONNestedObject.AddPair('owner_id', TJSONNumber.Create(TokensICOs[i].OwnerID));
        JSONNestedObject.AddPair('name', TokensICOs[i].ShortName);
        JSONNestedObject.AddPair('date', TJSONNumber.Create(
          DateTimeToUnix(TokensICOs[i].RegDate)));
        JSONNestedObject.AddPair('ticker', Trim(TokensICOs[i].Abreviature));
        JSONNestedObject.AddPair('amount',
          TJSONNumber.Create(TokensICOs[i].TockenCount));
        JSONNestedObject.AddPair('decimals',
          TJSONNumber.Create(TokensICOs[i].FloatSize));
        JSONNestedObject.AddPair('info', TokensICOs[i].FullName);
        JSONNestedObject.AddPair('address',SmartKey.key1);
      end;
      JSON.AddPair('tokens', JSONArray);

      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
  end;
end;

function TTokenEndpoints.GetTokenTransferFee(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.Create;
    try
      JSON.AddPair('fee', TJSONNumber.Create(0));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetCoinsBalances(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  Params: TStringList;
  Response: Extended;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if (AComType <> hcGET) and (AComType <> hcPOST) then
      raise ENotSupportedError.Create('');

    if AComType = hcGET then
      Params.AddStrings(AParams)
    else
    begin
      JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
      try
        Params.AddStrings(GetBodyParamsFromJSON(JSON));
      finally
        JSON.Free;
      end;
    end;
    if Params.Values['tet_address'].IsEmpty then
      raise EValidError.Create('request parameters error');

    Response := AppCore.GetLocalTETBalance(Params.Values['tet_address']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('tet_balance', FormatFloat('0.########', Response));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetCoinTransferFee(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.Create;
    try
      JSON.AddPair('fee', TJSONNumber.Create(0));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetNewTokenFee(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  Params: TStringList;
  Response: Integer;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['token_amount'].IsEmpty or Params.Values['decimals'].IsEmpty
    then
      raise EValidError.Create('request parameters error');

    Response := AppCore.GetNewTokenFee(Params.Values['token_amount'].ToInt64,
      Params.Values['decimals'].ToInteger);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('fee', TJSONNumber.Create(Response));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.DoNewToken(AReqID: string; ABody: string)
  : TEndpointResponse;
var
  JSON: TJSONObject;
  SplittedResponse: TArray<string>;
  FullName, ShortName, Ticker, Response, SessionKey: string;
  TokenNumber: Int64;
  Decimals: Integer;
begin
  Result.ReqID := AReqID;

  JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
  try
    if not(JSON.TryGetValue('session_key', SessionKey) and
      JSON.TryGetValue('full_name', FullName) and JSON.TryGetValue('short_name',
      ShortName) and JSON.TryGetValue('ticker', Ticker) and
      JSON.TryGetValue('token_amount', TokenNumber) and JSON.TryGetValue('decimals',
      Decimals)) then
      raise EValidError.Create('request parameters error');
  finally
    JSON.Free;
  end;

  Response := AppCore.DoNewToken(AReqID, SessionKey, FullName, ShortName,
    Ticker.ToUpper, TokenNumber, Decimals);
  SplittedResponse := Response.Split([' ']);
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('transaction_hash', SplittedResponse[2]);
    JSON.AddPair('smartcontract_ID', TJSONNumber.Create(SplittedResponse[3].ToInt64));
    Result.Code := HTTP_SUCCESS;
    Result.Response := JSON.ToString;
  finally
    JSON.Free;
  end;
end;

function TTokenEndpoints.Tokens(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
begin
  Result.ReqID := AReqID;
  try
    case AComType of
      hcGET:
        Result := GetTokensList(AParams);
      hcPOST:
        Result := DoNewToken(AReqID, ABody);
    else
      raise ENotSupportedError.Create('');
    end;
  finally
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.GetTokensTransferHistory(AReqID: string;
  AEvent: TEvent; AComType: THTTPCommandType; AParams: TStrings; ABody: string)
  : TEndpointResponse;
var
  JSON, JSONNestedObject: TJSONObject;
  JSONArray: TJSONArray;
  Params: TStringList;
  TETTransfersInfo: TArray<TExplorerTransactionInfo>;
  i, Rows, Skip: Integer;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['ticker'].IsEmpty then
      raise EValidError.Create('request parameters error');
    if Params.Values['rows'].IsEmpty then
      Rows := 20
    else if not TryStrToInt(Params.Values['rows'], Rows) then
      raise EValidError.Create('request parameters error');
    if Params.Values['skip'].IsEmpty then
      Skip := 0
    else if not TryStrToInt(Params.Values['skip'], Skip) then
      raise EValidError.Create('request parameters error');

    TETTransfersInfo := AppCore.GetSmartTransactions(Params.Values['ticker'].ToUpper,
      Skip, Rows);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('ticker', Params.Values['ticker'].ToUpper);
      JSONArray := TJSONArray.Create;
      for i := 0 to Rows - 1 do
      begin
        JSONArray.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArray.Items[pred(JSONArray.Count)
          ] as TJSONObject;
        JSONNestedObject.AddPair('date', TJSONNumber.Create(
          DateTimeToUnix(TETTransfersInfo[i].DateTime)));
        JSONNestedObject.AddPair('block',
          TJSONNumber.Create(TETTransfersInfo[i].BlockNum));
        JSONNestedObject.AddPair('address_from', TETTransfersInfo[i].TransFrom);
        JSONNestedObject.AddPair('address_to', TETTransfersInfo[i].TransTo);
        JSONNestedObject.AddPair('hash', TETTransfersInfo[i].Hash);
        JSONNestedObject.AddPair('amount',
          TJSONNumber.Create(TETTransfersInfo[i].Amount));
        JSONNestedObject.AddPair('fee', TJSONNumber.Create(0));
      end;
      JSON.AddPair('transactions', JSONArray);

      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.DoTokenTransfer(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  Response: string;
  TransFrom, TransTo, SmartAddress, PrKey, PubKey: string;
  TokensAmount: Extended;
  CSmartKey: TCSmartKey;
  TokenICODat: TTokenICODat;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not (//
        JSON.TryGetValue('from', TransFrom)//
        and JSON.TryGetValue('to', TransTo)//
        and JSON.TryGetValue('smart_address', SmartAddress)//
        and JSON.TryGetValue('amount', TokensAmount)//
        and JSON.TryGetValue('private_key', PrKey)//
        and JSON.TryGetValue('public_key', PubKey)//
        ) then
        raise EValidError.Create('request parameters error');

      if not(
        AppCore.TryGetTokenBaseByAddress(SmartAddress, CSmartKey)//
        and AppCore.TryGetTokenICO(CSmartKey.Abreviature, TokenICODat)//
        ) then
        raise EValidError.Create('incorrect smart_address');

      const AmountStr = JSON.GetValue<string>('amount', '');
      if not AmountStr.IsEmpty and (DecimalsCount(AmountStr) > TokenICODat.FloatSize) then
        raise EValidError.Create('too much decimals');

    finally
      JSON.Free;
    end;

    Response := AppCore.DoTokenTransfer(AReqID, TransFrom, TransTo, SmartAddress,
      TokensAmount, PrKey, PubKey);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('hash', Response.Split([' '])[3].ToLower);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

end.
