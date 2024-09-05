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

    function DoReg(AReqID: string; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: string): TEndpointResponse;
    function DoAuth(AReqID: string; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: string): TEndpointResponse;
    function DoRecoverKeys(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetPublicKeyByAccID(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function GetPublicKeyBySessionKey(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
  end;

implementation

{ TMainEndpoints }

function TMainEndpoints.DoAuth(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  SplittedResponse: TArray<string>;
  Login, Password, Response, SessionKey: string;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not(JSON.TryGetValue('login', Login) and
        JSON.TryGetValue('password', Password)) then
        raise EValidError.Create('request parameters error');
    finally
      JSON.Free;
    end;

    Response := AppCore.DoAuth(AReqID, login, Password);
    SplittedResponse := Response.Split([' ']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('user_id', TJSONNumber.Create(SplittedResponse[4]));
      JSON.AddPair('session_key', SplittedResponse[2]);
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

constructor TMainEndpoints.Create;
begin
  inherited;
end;

destructor TMainEndpoints.Destroy;
begin

  inherited;
end;

function TMainEndpoints.GetPublicKeyByAccID(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  Response: string;
  Params: TStringList;
  UserID: Integer;
begin
  Result.ReqID := AReqID;
  Params := TStringList.Create(dupIgnore, True, False);
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    Params.AddStrings(AParams);
    if Params.Values['user_id'].IsEmpty or
      (not TryStrToInt(Params.Values['user_id'], UserID)) then
      raise EValidError.Create('request parameters error');

    Response := AppCore.GetPubKeyByID(AReqID, UserID);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('public_key', Response.Split([' '])[2]);
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    params.Free;
    if Assigned(AEvent) then
      AEvent.SetEvent;
  end;
end;

function TMainEndpoints.GetPublicKeyBySessionKey(AReqID: string; AEvent: TEvent;
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
    if Params.Values['session_key'].IsEmpty then
      raise EValidError.Create('request parameters error');

    Response := AppCore.GetPubKeyBySessionKey(AReqID,
      Params.Values['session_key']);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('public_key', Response.Split([' '])[2]);
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

function TMainEndpoints.DoRecoverKeys(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  PubKey, PrKey, Seed, Response: string;
begin
  Result.ReqID := '';
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.ParseJSONValue(ABody, False, True) as TJSONObject;
    try
      if not JSON.TryGetValue('seed_phrase', Seed) then
        raise EValidError.Create('request parameters error');
    finally
      JSON.Free;
    end;

    Response := AppCore.DoRecoverKeys(Seed, PubKey, PrKey);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('private_key', PrKey);
      JSON.AddPair('public_key', PubKey);
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

function TMainEndpoints.DoReg(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  PubKey, PrKey, Login, Password, Address, Seed, Response, SavingPath: string;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcPOST then
      raise ENotSupportedError.Create('');

    Seed := GenSeedPhrase;
    Response := AppCore.DoReg(AReqID, Seed, PubKey, PrKey, Login, Password,
      Address, SavingPath);
    JSON := TJSONObject.Create;
    try
      JSON.AddPair('client_ID', TJSONNumber.Create(Response.Split([' '])
        [2].ToInt64));
      JSON.AddPair('seed_phrase', Seed);
      JSON.AddPair('login', Login);
      JSON.AddPair('password', Password);
      JSON.AddPair('address', Address);
      JSON.AddPair('private_key', PrKey);
      JSON.AddPair('public_key', PubKey);
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
