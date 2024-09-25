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

    function BlocksCountLocal(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
    function BlocksCount(AReqID: string; AEvent: TEvent;
      AComType: THTTPCommandType; AParams: TStrings; ABody: string)
      : TEndpointResponse;
  end;

implementation

function TChainEndpoints.BlocksCount(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
  Response: string;
  BlocksNumber: Int64;
begin
  Result.ReqID := AReqID;
  try
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');

    JSON := TJSONObject.Create;
    try
//      Response := AppCore.GetBlocksCount(AReqID);
      BlocksNumber := Response.Split([' '])[2].ToInt64;
      JSON.AddPair('blocksCount', TJSONNumber.Create(BlocksNumber));
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

function TChainEndpoints.BlocksCountLocal(AReqID: string; AEvent: TEvent;
  AComType: THTTPCommandType; AParams: TStrings; ABody: string): TEndpointResponse;
var
  JSON: TJSONObject;
begin
  Result.ReqID := AReqID;
  try
    JSON := TJSONObject.Create;
    if AComType <> hcGET then
      raise ENotSupportedError.Create('');
    try
//      JSON.AddPair('blocksCount',
//        TJSONNumber.Create(AppCore.GetChainBlocksCount));
      Result.Code := HTTP_SUCCESS;
      Result.response := JSON.ToString;
    finally
      JSON.Free;
    end;
  finally
    if Assigned(AEvent) then
      AEvent.SetEvent;
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
