unit App.Settings;

interface

uses
  App.Constants,
  Classes,
  IniFiles,
  IOUtils,
  Net.Data,
  SysUtils;

const
  NODE_VERSION = 'v0.9.3 - beta';

type
  TSettingsFile = class
    private
      FPath: String;
      FIni: TIniFile;

      function GetFullPath: String;
      function CheckAddress(const AAddress: String): Boolean;
      procedure FillNodesList(AAddresses: String);
      procedure SetHTTPPort(APort: String);
    public
      constructor Create;
      destructor Destroy; override;

      procedure Init;
  end;

implementation

{ TSettingsFile }

function TSettingsFile.CheckAddress(const AAddress: String): Boolean;
var
  i,j: Integer;
  splt: TArray<String>;
begin
  if not(AAddress.Contains('.') and AAddress.Contains(':')) then
    Exit(False);
  splt := AAddress.Split(['.',':']);
  if (Length(splt) <> 5) then
    Exit(False);
  for i := 0 to Length(splt)-1 do
    if not TryStrToInt(splt[i],j) then
      Exit(False);

  Result := True;
end;

constructor TSettingsFile.Create;
begin
  FPath := ExtractFilePath(ParamStr(0));

  FIni := TIniFile.Create(GetFullPath);
  if not FileExists(GetFullPath) then  //initialize the .ini file if it doesn’t already exist
  begin
    FIni.WriteString('connections','listen_to',DefaultTCPListenTo);
    FIni.WriteString('connections', 'nodes',Format('[%s]',[DefaultNodeAddress]));
    FIni.WriteString('http','port',DefaultPortHTTP.ToString);
    FIni.UpdateFile;
  end;
end;

destructor TSettingsFile.Destroy;
begin
  FIni.Free;

  inherited;
end;

procedure TSettingsFile.FillNodesList(AAddresses: String);
var
  i: Integer;
  splt: TArray<String>;
begin
  splt := AAddresses.Trim(['[',']']).Split([',']);
  if Length(splt) = 0 then exit;

  for i := 0 to Length(splt)-1 do
    if CheckAddress(splt[i]) then
      Nodes.AddNodeToPool(splt[i])
    else
      raise Exception.Create(Format('Address "%s" is invalid',[splt[i]]));
end;

function TSettingsFile.GetFullPath: String;
begin
  Result := TPath.Combine(FPath, ConstStr.SettingsFileName);
end;

procedure TSettingsFile.Init;
var
  str: String;
  AddrSL: TStringList;
begin
  if not FileExists(GetFullPath) then
    raise Exception.Create('Settings file not found. Please, restart the application');

  AddrSL := TStringList.Create(dupIgnore,True,False);
  try
    str := FIni.ReadString('connections','listen_to','');
    if str.IsEmpty then
      raise Exception.Create('incorrect settings file');
    if CheckAddress(str) then
      ListenTo := str
    else
      raise Exception.Create(Format('address "%s" is invalid',[str]));

    str := FIni.ReadString('connections','nodes','');
    FillNodesList(str);
    if Nodes.IsEmpty then
      raise Exception.Create('nodes addresses are not specified');

    str := FIni.ReadString('http','port','');
    if str.IsEmpty then
      raise Exception.Create('incorrect settings file');
    SetHTTPPort(str);
  finally
    AddrSL.Clear;
    AddrSL.Free;
  end;
end;

procedure TSettingsFile.SetHTTPPort(APort: String);
var
  n: Integer;
begin
    if (not TryStrToInt(APort,n)) or (n > 65535) or (n < 0) then
      raise Exception.Create(Format('HTTP port "%s" is invalid',[APort]));

  HTTPPort := n;
end;

end.
