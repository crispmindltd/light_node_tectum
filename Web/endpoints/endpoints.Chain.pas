unit endpoints.Chain;

interface

uses
  App.Exceptions,
  App.Intf,
  Classes,
  endpoints.Base,
  JSON,
  IdCustomHTTPServer,
  server.Types,
  SyncObjs,
  SysUtils;

type
  TChainEndpoints = class(TEndpointsBase)
  public
    constructor Create;
    destructor Destroy; override;

    function blocksCountL(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
    function blocksCount(AReqID: String; AEvent: TEvent; AComType: THTTPCommandType;
      AParams: TStrings; ABody: String): TEndpointResponse;
  end;

implementation

function TChainEndpoints.blocksCount(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
  response: String;
  blockCount: Int64;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcGET then raise ENotSupportedError.Create('');
    JSON := TJSONObject.Create;
    try
      response := AppCore.GetBlocksCount(AReqID);
      blockCount := response.Split([' '])[2].ToInt64;
      JSON.AddPair('blocksCount',TJSONNumber.Create(blockCount));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

function TChainEndpoints.blocksCountL(AReqID: String; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: String): TEndpointResponse;
var
  JSON: TJSONObject;
begin
  Result.ReqID := AReqID;
  try
    JSON := TJSONObject.Create;
    if AComType <> hcGET then raise ENotSupportedError.Create('');
    try
      JSON.AddPair('blocksCount',TJSONNumber.Create(AppCore.GetChainBlocksCount));
      Result.Code := HTTP_SUCCESS;
      Result.Response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then AEvent.SetEvent;
  end;
end;

constructor TChainEndpoints.Create;
begin
  inherited;
end;

destructor TChainEndpoints.Destroy;
begin

  inherited;
end;

end.
