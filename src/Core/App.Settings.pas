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
      FPath: string;
      FIni: TIniFile;
      FSyncTokens: TStringList;

      function GetFullPath: string;
      function CheckAddress(const AAddress: string): Boolean;
      procedure FillNodesList(AAddresses: string);
      procedure SetHTTPPort(APort: string);

      procedure ReadTokensToSyncFromFile;
      procedure WriteTokensToSyncToFile;
    public
      constructor Create;
      destructor Destroy; override;

      procedure Init;
      procedure AddTokenToSync(ATokenID: Integer);
      function GetTokensToSynchronize: TArray<Integer>;
      procedure RemoveTokenToSync(ATokenID: Integer);
  end;

implementation

{ TSettingsFile }

procedure TSettingsFile.AddTokenToSync(ATokenID: Integer);
begin
  FSyncTokens.Add(ATokenID.ToString);
end;

function TSettingsFile.CheckAddress(const AAddress: string): Boolean;
var
  i,j: Integer;
  splt: TArray<string>;
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
    FIni.WriteString('sync','tokens','[]');
    FIni.UpdateFile;
  end;

  FSyncTokens := TStringList.Create(dupIgnore,True,False);
  FSyncTokens.Delimiter := ',';
end;

destructor TSettingsFile.Destroy;
begin
  WriteTokensToSyncToFile;
  FSyncTokens.Free;
  FIni.Free;

  inherited;
end;

procedure TSettingsFile.FillNodesList(AAddresses: string);
var
  i: Integer;
  splt: TArray<string>;
begin
  splt := AAddresses.Trim(['[',']']).Split([',']);
  if Length(splt) = 0 then exit;

  for i := 0 to Length(splt)-1 do
    if CheckAddress(splt[i]) then
      Nodes.AddNodeToPool(splt[i])
    else
      raise Exception.Create(Format('Address "%s" is invalid',[splt[i]]));
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
  SplittedString: TArray<string>;
  i,Value: Integer;
begin
  FSyncTokens.Clear;
  SplittedString := FIni.ReadString('sync','tokens','[]').Trim(['[',']']).Split([',']);
  for i := 0 to Length(SplittedString) - 1 do
    if TryStrToInt(SplittedString[i],Value) then
      FSyncTokens.Add(SplittedString[i]);
end;

procedure TSettingsFile.RemoveTokenToSync(ATokenID: Integer);
var
  Index: Integer;
begin
  Index := FSyncTokens.IndexOf(ATokenID.ToString);
  if Index > -1 then
    FSyncTokens.Delete(Index);
end;

procedure TSettingsFile.Init;
var
  str: string;
begin
  if not FileExists(GetFullPath) then
    raise Exception.Create('Settings file not found. Please, restart the application');

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

  ReadTokensToSyncFromFile;
end;

procedure TSettingsFile.SetHTTPPort(APort: string);
var
  n: Integer;
begin
    if (not TryStrToInt(APort,n)) or (n > 65535) or (n < 0) then
      raise Exception.Create(Format('HTTP port "%s" is invalid',[APort]));

  HTTPPort := n;
end;

procedure TSettingsFile.WriteTokensToSyncToFile;
var
  str: string;
begin
  str := FSyncTokens.DelimitedText;
  FIni.WriteString('sync','tokens',Format('[%s]',[str]));
  FIni.UpdateFile;
end;

end.
