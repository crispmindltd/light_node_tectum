unit endpoints.Account;

interface

uses
  App.Exceptions,
  App.Intf,
  Classes,
  endpoints.Base,
  JSON,
  IdCustomHTTPServer,
  IOUtils,
  server.Types,
  SyncObjs,
  SysUtils,
  WordsPool;

type
  TMainEndpoints = class(TEndpointsBase)
  public
    constructor Create;
    destructor Destroy; override;

    function reg(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function auth(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function recoverKeys(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getPublicKeyByAccID(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function getPublicKeyBySessionKey(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
  end;

implementation

{ TMainEndpoints }

function TMainEndpoints.auth(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
  AParams: TStrings; ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  login,pw,response,sessionKey: String;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not(JSON.TryGetValue('login', login) and JSON.TryGetValue('password', pw)) then
        raise EValidError.Create('request parameters error');
    finally
      JSON.Free;
    end;

    response := AppCore.DoAuth(AReqID,login,pw);
    JSON := TJSONObject.Create;
    try
      sessionKey := response.Split([' '])[2];
      JSON.AddPair('session_key',sessionKey);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

constructor TMainEndpoints.Create;
begin
  inherited;
end;

destructor TMainEndpoints.Destroy;
begin

  inherited;
end;

function TMainEndpoints.getPublicKeyByAccID(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  response: String;
  params: TStringList;
  userID: Integer;
begin
  Result.ReqID := AReqID;
  params := TStringList.Create(dupIgnore,True,False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    params.AddStrings(AParams);
    if params.Values['user_id'].IsEmpty or (not TryStrToInt(params.Values['user_id'],userID)) then
      raise EValidError.Create('request parameters error');

    response := AppCore.GetPubKeyByID(AReqID,userID);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('public_key',response.Split([' '])[2]);
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

function TMainEndpoints.getPublicKeyBySessionKey(AReqID: String; AEvent: TEvent;
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
    if params.Values['session_key'].IsEmpty then
      raise EValidError.Create('request parameters error');

    response := AppCore.GetPubKeyBySessionKey(AReqID,params.Values['session_key']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('public_key',response.Split([' '])[2]);
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

function TMainEndpoints.recoverKeys(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  pubKey,prKey,seed,response: String;
begin
  Result.ReqID := '';
  try
    if AComType <> hcPOST then raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not JSON.TryGetValue('seed_phrase', seed) then
        raise EValidError.Create('request parameters error');
    finally
      JSON.Free;
    end;

    response := AppCore.DoRecoverKeys(seed,pubKey,prKey);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('private_key',prKey);
      JSON.AddPair('public_key',pubKey);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TMainEndpoints.reg(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings;
  ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  pubKey,prKey,login,pass,addr,seed,response,sPath: String;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then raise ENotSupportedError.Create('');

    seed := GenSeedPhrase;
    response := AppCore.DoReg(AReqID,seed,pubKey,prKey,login,pass,addr,sPath);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('client_ID',TJSONNumber.Create(response.Split([' '])[2].ToInt64));
      JSON.AddPair('seed_phrase',seed);
      JSON.AddPair('login', login);
      JSON.AddPair('password',pass);
      JSON.AddPair('address',addr);
      JSON.AddPair('private_key',prKey);
      JSON.AddPair('public_key',pubKey);
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
