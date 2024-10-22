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
  NODE_VERSION = 'v0.9.4 - beta';

type
  TSettingsFile = class
    private
      FPath: string;
      FIni: TIniFile;
      FSyncTokens: TStringList;

      function GetFullPath: string;
      function CheckAddress(const AAddress: string): Boolean;
      procedure FillNodesList(AAddresses: string);
      procedure SetHTTPPort(APort: string);

      procedure ReadTokensToSyncFromFile;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Init;
      procedure AddTokenToSync(ATokenID: Integer);
      function GetTokensToSynchronize: TArray<Integer>; overload;
      procedure RemoveTokenToSync(ATokenID: Integer);
  end;

implementation

{ TSettingsFile }

procedure TSettingsFile.AddTokenToSync(ATokenID: Integer);
begin
  FSyncTokens.Add(ATokenID.ToString);
  FIni.WriteString('sync', 'tokens', Format('[%s]', [FSyncTokens.DelimitedText]));
  FIni.UpdateFile;
end;

function TSettingsFile.CheckAddress(const AAddress: string): Boolean;
var
  i, j: Integer;
  Splitted: TArray<string>;
begin
  if not(AAddress.Contains('.') and AAddress.Contains(':')) then
    exit(False);
  Splitted := AAddress.Split(['.', ':']);
  if (Length(Splitted) <> 5) then
    exit(False);
  for i := 0 to Length(Splitted) - 1 do
    if not TryStrToInt(Splitted[i], j) then
      exit(False);

  Result := True;
end;

constructor TSettingsFile.Create;
begin
  FPath := ExtractFilePath(ParamStr(0));

  FIni := TIniFile.Create(GetFullPath);
  if not FileExists(GetFullPath) then  //initialize the .ini file if it doesn’t already exist
  begin
    FIni.WriteString('connections', 'listen_to', DefaultTCPListenTo);
    FIni.WriteString('connections', 'nodes', Format('[%s]', [DefaultNodeAddress]));
    FIni.WriteString('http', 'port', DefaultPortHTTP.ToString);
    FIni.WriteString('sync', 'tokens', '[]');
    FIni.UpdateFile;
  end;

  FSyncTokens := TStringList.Create(dupIgnore, True, False);
  FSyncTokens.Delimiter := ',';
end;

destructor TSettingsFile.Destroy;
begin
  FSyncTokens.Free;
  FIni.Free;

  inherited;
end;

procedure TSettingsFile.FillNodesList(AAddresses: string);
var
  i: Integer;
  Splitted: TArray<string>;
begin
  Splitted := AAddresses.Trim(['[', ']']).Split([',']);
  if Length(Splitted) = 0 then
    exit;

  for i := 0 to Length(Splitted) - 1 do
    if CheckAddress(Splitted[i]) then
      Nodes.AddNodeToPool(Splitted[i])
    else
      raise Exception.Create(Format('Address "%s" is invalid', [Splitted[i]]));
end;

function TSettingsFile.GetFullPath: string;
begin
  Result := TPath.Combine(FPath, ConstStr.SettingsFileName);
end;

function TSettingsFile.GetTokensToSynchronize: TArray<Integer>;
var
  i: Integer;
begin
  SetLength(Result, FSyncTokens.Count);
  for i := 0 to FSyncTokens.Count - 1 do
    Result[i] := FSyncTokens.Strings[i].ToInteger;
end;

procedure TSettingsFile.ReadTokensToSyncFromFile;
var
  Splitted: TArray<string>;
  i, Value: Integer;
begin
  FSyncTokens.Clear;
  Splitted := FIni.ReadString('sync', 'tokens', '[]').Trim(['[', ']']).Split([',']);
  for i := 0 to Length(Splitted) - 1 do
    if TryStrToInt(Splitted[i], Value) then
      FSyncTokens.Add(Splitted[i]);
end;

procedure TSettingsFile.RemoveTokenToSync(ATokenID: Integer);
var
  Index: Integer;
begin
  Index := FSyncTokens.IndexOf(ATokenID.ToString);
  if Index > -1 then
  begin
    FSyncTokens.Delete(Index);
    FIni.WriteString('sync', 'tokens', Format('[%s]', [FSyncTokens.DelimitedText]));
    FIni.UpdateFile;
  end;
end;

procedure TSettingsFile.Init;
var
  Value: string;
begin
  if not FileExists(GetFullPath) then
    raise Exception.Create('Settings file not found. Please, restart the application');

  Value := FIni.ReadString('connections', 'listen_to', '');
  if Value.IsEmpty then
    raise Exception.Create('incorrect settings file');
  if CheckAddress(Value) then
    ListenTo := Value
  else
    raise Exception.Create(Format('address "%s" is invalid', [Value]));

  Value := FIni.ReadString('connections', 'nodes', '');
  FillNodesList(Value);
  if Nodes.IsEmpty then
    raise Exception.Create('nodes addresses are not specified');

  Value := FIni.ReadString('http', 'port', '');
  if Value.IsEmpty then
    raise Exception.Create('incorrect settings file');
  SetHTTPPort(Value);

  ReadTokensToSyncFromFile;
end;

procedure TSettingsFile.SetHTTPPort(APort: string);
var
  PortValue: Integer;
begin
  if (not TryStrToInt(APort, PortValue)) or (PortValue > 65535) or (PortValue < 0) then
    raise Exception.Create(Format('HTTP port "%s" is invalid', [APort]));

  HTTPPort := PortValue;
end;

end.
