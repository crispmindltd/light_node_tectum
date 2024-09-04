unit endpoints.Base;

interface

uses
  JSON,
  SysUtils;

type
  TEndpointsBase = class
    private
    protected
      function GetBodyParamsFromJSON(AJSON: TJSONObject): TArray<String>;
    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

{ TEndpointsBase }

constructor TEndpointsBase.Create;
begin

end;

destructor TEndpointsBase.Destroy;
begin

  inherited;
end;

function TEndpointsBase.GetBodyParamsFromJSON(
  AJSON: TJSONObject): TArray<String>;
var
  JSONEnum: TJSONObject.TEnumerator;
  str: String;
begin
  Result := [];
  try
    JSONEnum := AJSON.GetEnumerator;
    while JSONEnum.MoveNext do
    begin
      str := JSONEnum.Current.ToString.Replace(':','=');
      str := str.Replace('"','',[rfReplaceAll]);
      str := str.Replace('[','',[rfReplaceAll]);
      str := str.Replace(']','',[rfReplaceAll]);
      Result := Result + [str];
    end;
  finally
    JSONEnum.Free;
  end;
end;

end.
