unit endpoints.Token;

interface

uses
  App.Exceptions,
  App.Intf,
  Classes,
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
  public
    constructor Create;
    destructor Destroy; override;

    function newToken(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getNewTokenFee(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function tokenTransfer(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getTokenTransferFee(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function coinTransfer(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getCoinTransferFee(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getCoinsBalances(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function coinsTransferHistory(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getTokenBalanceWithAddress(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getTokenBalanceWithTicker(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getAddressByID(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getAddressByTicker(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
  end;

implementation

{ TTokenEndpoints }

function TTokenEndpoints.coinTransfer(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  sKey,transTo,response: String;
  amount: Extended;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not(JSON.TryGetValue('session_key', sKey) and JSON.TryGetValue('to', transTo) and
        JSON.TryGetValue('amount', amount)) then
        raise EValidError.Create('request parameters error');
    finally
      JSON.Free;
    end;

    response := AppCore.DoCoinsTransfer(AReqID,sKey,transTo,amount);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('hash',response.Split([' '])[3].ToLower);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.coinsTransferHistory(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON,JSONNestedObject: TJSONObject;
  JSONArray: TJSONArray;
  params: TStringList;
  response: String;
  splt,transInfo: TArray<String>;
  i,amount: Integer;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if (AComType <> hcGET) and (AComType <> hcPOST) then
      raise ENotSupportedError.Create('');

    if AComType = hcGET then
      params.AddStrings(AParams)
    else begin
      JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
      try
        params.AddStrings(GetBodyParamsFromJSON(JSON));
      finally
        JSON.Free;
      end;
    end;
    if params.Values['session_key'].IsEmpty or params.Values['amount'].IsEmpty or
      (not TryStrToInt(params.Values['amount'],amount)) then
      raise EValidError.Create('request parameters error');

    response := AppCore.DoGetCoinsTransfersHistory(params.Values['session_key'],amount);
    splt := response.Split([' '], '<', '>');
    JSON := TJSONObject.Create;
    try
      JSONArray := TJSONArray.Create;
      for i := 4 to Length(splt) - 1 do
      begin
        transInfo := splt[i].Trim(['<','>']).Split([' ']);
        JSONArray.AddElement(TJSONObject.Create);
        JSONNestedObject := JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
        JSONNestedObject.AddPair('blockNumber', TJSONNumber.Create(transInfo[5].ToInteger));
        JSONNestedObject.AddPair('time', FormatDateTime('dd.mm.yyyy hh:mm:ss',FloatToDateTime(transInfo[6].ToExtended)));
        JSONNestedObject.AddPair('tokenFar', transInfo[0]);
        JSONNestedObject.AddPair('transferSum', TJSONNumber.Create(transInfo[1].ToExtended));
        JSONNestedObject.AddPair('direction', TJSONNumber.Create(transInfo[2].ToInteger));
        JSONNestedObject.AddPair('hash', transInfo[3]);
        JSONNestedObject.AddPair('amount', TJSONNumber.Create(transInfo[4].ToExtended));
      end;
      JSON.AddPair('history',JSONArray);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then AEvent.SetEvent;
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

function TTokenEndpoints.getAddressByID(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  response: String;
  params: TStringList;
  smartId: Integer;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    params.AddStrings(AParams);
    if params.Values['smart_id'].IsEmpty or
      (not TryStrToInt(params.Values['smart_id'],smartId)) then
      raise EValidError.Create('request parameters error');

    response := AppCore.GetSmartAddressByID(smartId);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('smart_address',response);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.getAddressByTicker(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  response: String;
  params: TStringList;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    params.AddStrings(AParams);
    if params.Values['ticker'].IsEmpty then
      raise EValidError.Create('request parameters error');

    response := AppCore.GetSmartAddressByTicker(params.Values['ticker']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('smart_address',response);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.getTokenBalanceWithAddress(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  response: String;
  params: TStringList;
  splt: TArray<String>;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    params.AddStrings(AParams);
    if params.Values['address_tet'].IsEmpty or params.Values['smart_address'].IsEmpty then
      raise EValidError.Create('request parameters error');

    response := AppCore.DoGetTokenBalanceWithSmartAddress(AReqID,
      params.Values['address_tet'],params.Values['smart_address']);
    splt := response.Split([' ']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('balance',TJSONNumber.Create(splt[2].ToExtended));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.getTokenBalanceWithTicker(AReqID: String;
  AEvent: TEvent; AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  response: String;
  params: TStringList;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if (AComType <> hcGET) and (AComType <> hcPOST) then
      raise ENotSupportedError.Create('');

    if AComType = hcGET then
      params.AddStrings(AParams)
    else begin
      JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
      try
        params.AddStrings(GetBodyParamsFromJSON(JSON));
      finally
        JSON.Free;
      end;
    end;

    if params.Values['address_tet'].IsEmpty or params.Values['ticker'].IsEmpty then
      raise EValidError.Create('request parameters error');

    response := AppCore.DoGetTokenBalanceWithTicker(AReqID,
      params.Values['address_tet'],params.Values['ticker']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('balance',TJSONNumber.Create(response.Split([' '])[2].ToExtended));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.getTokenTransferFee(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.Create;
    try
      JSON.AddPair('fee',TJSONNumber.Create(0));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.getCoinsBalances(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON,JSONNestedObject: TJSONObject;
  JSONArray: TJSONArray;
  params: TStringList;
  response: Extended;
  tokenInfo: TArray<String>;
  i: Integer;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if (AComType <> hcGET) and (AComType <> hcPOST) then
      raise ENotSupportedError.Create('');

    if AComType = hcGET then
      params.AddStrings(AParams)
    else begin
      JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
      try
        params.AddStrings(GetBodyParamsFromJSON(JSON));
      finally
        JSON.Free;
      end;
    end;
    if params.Values['tet_address'].IsEmpty then
      raise EValidError.Create('request parameters error');

    response := AppCore.GetLocalTETBalance(params.Values['tet_address']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('tet_balance',FormatFloat('#################0.########',response));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.getCoinTransferFee(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.Create;
    try
      JSON.AddPair('fee',TJSONNumber.Create(0));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.getNewTokenFee(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  splt: TArray<String>;
  params: TStringList;
  response: Integer;
  tamount: Int64;
  decimals: Integer;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    params.AddStrings(AParams);
    if params.Values['token_amount'].IsEmpty or params.Values['decimals'].IsEmpty then
      raise EValidError.Create('request parameters error');

    response := AppCore.GetNewTokenFee(params.Values['token_amount'].ToInt64,
      params.Values['decimals'].ToInteger);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('fee',TJSONNumber.Create(response));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.newToken(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  splt: TArray<String>;
  fname,sname,ticker,response,sKey: String;
  tamount: Int64;
  decimals: Integer;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not(JSON.TryGetValue('session_key', sKey) and JSON.TryGetValue('full_name', fname) and
        JSON.TryGetValue('short_name', sname) and JSON.TryGetValue('ticker', ticker) and
        JSON.TryGetValue('token_amount', tamount) and JSON.TryGetValue('decimals', decimals)) then
          raise EValidError.Create('request parameters error');
    finally
      JSON.Free;
    end;

    response := AppCore.DoNewToken(AReqID,sKey,fname,sname,ticker.ToUpper,tamount,decimals);
    splt := response.Split([' ']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('transaction_hash',splt[2]);
      JSON.AddPair('smartcontract_ID',TJSONNumber.Create(splt[3].ToInt64));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TTokenEndpoints.tokenTransfer(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  response: String;
  transFrom,transTo,smart,prKey,pubKey: String;
  amount: Extended;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not(JSON.TryGetValue('from', transFrom) and JSON.TryGetValue('to', transTo) and
        JSON.TryGetValue('smart_address', smart) and JSON.TryGetValue('amount', amount) and
        JSON.TryGetValue('private_key', prKey) and JSON.TryGetValue('public_key', pubKey)) then
          raise EValidError.Create('request parameters error');
    finally
      JSON.Free;
    end;

    response := AppCore.DoTokenTransfer(AReqID,transFrom,transTo,smart,
      amount,prKey,pubKey);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('hash',response.Split([' '])[3].ToLower);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

end.
