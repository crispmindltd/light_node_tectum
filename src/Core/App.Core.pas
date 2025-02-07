unit App.Core;

interface

uses
  App.Constants,
  App.Exceptions,
  App.Intf,
  App.Logs,
  App.Settings,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Blockchain.Main,
  Classes,
  ClpIAsymmetricCipherKeyPair,
  ClpIECPrivateKeyParameters,
  ClpIECPublicKeyParameters,
  ClpCryptoLibTypes,
  Crypto,
  IOUtils,
  Math,
  Net.Client,
  Net.Data,
  Net.Server,
  Net.Socket,
  Server.HTTP,
  Server.Types,
  SyncObjs,
  SysUtils;

type
  TAppCore = class(TInterfacedObject, IAppCore)
  strict private
    FSessionKey: string;
    FUserID: Integer;
    FTETAddress: string;
    FStartLoadingDone: Boolean;
  private
    FSettings: TSettingsFile;
    FBlockchain: TBlockchain;
    FNodeServer: TNodeServer;
    FNodeClient: TNodeClient;
    FHTTPServer: THTTPServer;

    function GenPass(x1:LongInt = 100000000; x2:LongInt = 999999999): string;
    function CheckTickerName(const ATicker: string): Boolean;
    function CheckShortName(const AShortName: string): Boolean;
    function Remove0x(AAddress: string): string;
    function SignTransaction(const AToSign: string; const APrivateKey: string): string;
    function IsURKError(const ATest: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function GetVersion: string;
    procedure Run;
    procedure Stop;
    function GetSessionKey: string;
    function GetTETAddress: string;
    function GetUserID: Integer;
    function GetLoadingStatus: Boolean;
    procedure SetSessionKey(const ASessionKey: string);
    procedure SetUserID(const AID: Integer);
    procedure SetLoadingStatus(const AIsDone: Boolean);

    //TET chain methods
    function GetTETChainBlockSize: Integer;
    function GetTETChainBlocksCount: Integer;
    function GetTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetTETChainBlocks(ASkip: Integer; ABytes: TBytes);
    function GetTETUserLastTransactions(AUserID: Integer; ASkip: Integer;
      ARows: Integer): TArray<THistoryTransactionInfo>;
    function GetTETTransactions(ASkip: Integer; ARows: Integer;
      AFromTheEnd: Boolean = True): TArray<TExplorerTransactionInfo>;
    function GetTETBalance(ABlockNum: Integer; ATETDyn:
      TTokenBase): Double; overload;
    function GetTETBalance(ATETAddress: string): Double; overload;
    //TET dynamic blocks sync methods
    function GetDynTETChainBlockSize: Integer;
    function GetDynTETChainBlocksCount: Integer;
    function GetDynTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetDynTETChainBlocks(ASkip: Integer; ABytes: TBytes);
    function TryGetDynTETBlock(ATETAddress: string; var ABlockID: Integer;
      out ATETDyn: TTokenBase): Boolean;

    //IcoDat blocks sync methods
    function GetTokenICOBlockSize: Integer;
    function GetTokenICOBlocksCount: Integer;
    function GetTokenICOBlocks(ASkip: Integer): TBytes;
    procedure SetTokenICOBlocks(ASkip: Integer; ABytes: TBytes);
    function GetTokensICOs(ASkip, ARows: Integer): TArray<TTokenICODat>;
    function TryGetTokenICO(ATicker: string; out ATokenICO: TTokenICODat): Boolean;

    //SmartKey blocks sync methods
    function GetSmartKeyBlocksCount: Integer;
    function GetSmartKeyBlockSize: Integer;
    function GetSmartKeyBlocks(ASkip: Integer): TBytes;
    procedure SetSmartKeyBlocks(ASkip: Integer; ABytes: TBytes);
    function GetAllSmartKeyBlocks: TArray<TCSmartKey>;
    function TryGetSmartKey(ATickerOrAddress: string;
      out ASmartKey: TCSmartKey): Boolean; overload;
    function TryGetSmartKey(ATokenID: Integer;
      out ASmartKey: TCSmartKey): Boolean; overload;

    //Tokens chains methods
    procedure UpdateTokensList;
    function GetTokensToSynchronize: TArray<Integer>;
    procedure AddTokenToSynchronize(ATokenID: Integer);
    procedure RemoveTokenFromSynchronize(ATokenID: Integer);
    function GetTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetTokenChainBlockSize: Integer;
    function GetTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetTokenChainBlocks(ATokenID: Integer; ASkip: Integer; ABytes: TBytes);
    function GetTokenBalance(ATokenID: Integer; ABlockNum: Integer;
      ATETDyn: TTokenBase): Double; overload;
    function GetTokenBalance(ATokenID: Integer; ATETAddress: string): Double; overload;
    function GetTokenBalanceWithTokenAddress(ATETAddress, ATokenAddress: string;
      out AFloatSize: Byte): Double;
    function GetTokenBalanceWithTicker(ATETAddress, ATicker: string;
      out AFloatSize: Byte): Double;
    function GetTokenUserTransactions(ATokenID: Integer; AUserID: Integer;
      ASkip: Integer; ARows: Integer; ALast: Boolean = False): TArray<THistoryTransactionInfo>;
    function GetTokenTransactions(ATokenID: Integer; ASkip: Integer; ARows: Integer;
      AFromTheEnd: Boolean = True): TArray<TExplorerTransactionInfo>;
    //Tokens dynamic blocks sync methods
    function GetDynTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetDynTokenChainBlockSize: Integer;
    function GetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer; ABytes: TBytes);

    function SearchTransactionsByBlockNum(const ABlockNum: Integer):
      TArray<TExplorerTransactionInfo>;
    function SearchTransactionByHash(const AHash: string;
      out ATransaction: TExplorerTransactionInfo): Boolean;
    function SearchTransactionsByAddress(
      const ATETAddress: string): TArray<TExplorerTransactionInfo>;

    function GetTETBlocksTotalCount(AReqID: string): string;
    procedure DoReg(AReqID, ASeed: string; ACallBackProc: TGetStrProc); overload;
    function DoReg(AReqID: string; ASeed: string; out APubKey: string;
      out APrKey: string; out ALogin: string; out APassword: string;
      out AAddress: string; out ASavingPath: string): string; overload;
    procedure DoAuth(AReqID, ALogin, APassword: string;
      ACallBackProc: TGetStrProc); overload;
    function DoAuth(AReqID, ALogin, APassword: string): string; overload;
    procedure DoTETTransfer(AReqID, ASessionKey, ATo: string;
      AAmount: Double; ACallBackProc: TGetStrProc); overload;
    function DoTETTransfer(AReqID, ASessionKey, ATo: string;
      AAmount: Double): string; overload;
    function DoRecoverKeys(ASeed: string; out PubKey: string;
      out PrKey: string): string;
    procedure DoNewToken(AReqID, ASessionKey, AFullName, AShortName,
      ATicker: string; AAmount: Int64; ADecimals: Integer;
      ACallBackProc: TGetStrProc); overload;
    function DoNewToken(AReqID, ASessionKey, AFullName, AShortName,
      ATicker: string; AAmount: Int64; ADecimals: Integer): string; overload;
    function GetNewTokenFee(AAmount: Int64; ADecimals: Integer): Integer;
    procedure DoTokenTransfer(AReqID, AAddrTETFrom, AAddrTETTo, ASmartAddr: string;
      AAmount: Double; APrKey, APubKey: string; ACallBackProc: TGetStrProc); overload;
    function DoTokenTransfer(AReqID, AAddrTETFrom, AAddrTETTo, ASmartAddr: string;
      AAmount: Double; APrKey, APubKey: string): string; overload;
    function SendToConfirm(AReqID, AToSend: string): string;
    function GetPubKeyByID(AReqID: string; AUserID: Integer): string;
    function GetPubKeyBySessionKey(AReqID, ASessionKey: string): string;
    function GetTokenAddress(ATokenID: Integer): string; overload;
    function GetTokenAddress(ATicker: string): string; overload;
    function TryGetTokenBaseByAddress(const AAddress: string;
      var ASmartKey: TCSmartKey): Boolean;
    function TrySaveKeysToFile(APrivateKey: string): Boolean;
    procedure TryExtractPrivateKeyFromFile(out PrKey: string;
      out PubKey: string);

    property SessionKey: string read GetSessionKey write SetSessionKey;
    property TETAddress: string read GetTETAddress;
    property UserID: Integer read GetUserID write SetUserID;
    property BlocksSyncDone: Boolean read GetLoadingStatus write SetLoadingStatus;
  end;

implementation

{ TAppCore }

function TAppCore.IsURKError(const ATest: string): Boolean;
begin
  Result := ATest.StartsWith(ConstStr.URKError);
end;

function TAppCore.CheckShortName(const AShortName: string): Boolean;
const
  Acceptable = 'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm0123456789-., ';
var
  i: Integer;
begin
  Result := False;
  if (Length(AShortName) < 3) or (Length(AShortName) > 32) then
    exit;
  for i := 1 to Length(AShortName) do
    if Acceptable.IndexOf(AShortName[i]) = -1 then
      exit;
  Result := True;
end;

function TAppCore.CheckTickerName(const ATicker: string): Boolean;
const
  Acceptable = 'QWERTYUIOPASDFGHJKLZXCVBNM1234567890';
var
  i: Integer;
begin
  Result := False;
  if (Length(ATicker) < 3) or (Length(ATicker) > 8) or TryStrToInt(ATicker[1], i) then
    exit;
  for i := 1 to Length(ATicker) do
    if Acceptable.IndexOf(ATicker[i]) = -1 then
      exit;
  Result := True;
end;

constructor TAppCore.Create;
begin
  FStartLoadingDone := False;
  FSessionKey := '';
  FTETAddress := '';
  FUserID := -1;

  Logs := TLogs.Create;
  FSettings := TSettingsFile.Create;
  FNodeServer := TNodeServer.Create;
  FNodeClient := TNodeClient.Create;
  FHTTPServer := THTTPServer.Create;
end;

destructor TAppCore.Destroy;
begin
  FNodeServer.Free;
  FHTTPServer.Free;
  FNodeClient.Free;
  FSettings.Free;
  if Assigned(FBlockchain) then
    FBlockchain.Free;
  Logs.Free;

  inherited;
end;

procedure TAppCore.DoAuth(AReqID, ALogin, APassword: string;
  ACallBackProc: TGetStrProc);
begin
  if not (ALogin.Contains('@') and ALogin.Contains('.')) then
    raise EValidError.Create('incorrect login');
  if APassword.IsEmpty then
    raise EValidError.Create('incorrect password');

  TThread.CreateAnonymousThread(
    procedure
    var
      Response: string;
    begin
      Response := FNodeClient.DoRequest(AReqID, Format('CheckPW * %s %s ipa',
        [ALogin, APassword]));

      TThread.Synchronize(nil,
      procedure
      begin
        ACallBackProc(Response);
      end);
    end).Start;
end;

function TAppCore.DoAuth(AReqID, ALogin, APassword: string): string;
var
  Splitted: TArray<string>;
begin
  if not (ALogin.Contains('@') and ALogin.Contains('.')) then
    raise EValidError.Create('incorrect login');
  if APassword.IsEmpty then
    raise EValidError.Create('incorrect password');

  Result := FNodeClient.DoRequest(AReqID,Format('CheckPW * %s %s ipa',
    [ALogin, APassword]));
  if IsURKError(Result) then
  begin;
    Splitted := Result.Split([' ']);
    case Splitted[3].ToInteger of
      93: raise EAuthError.Create('');
      816: raise EAuthError.Create('');
      else raise EUnknownError.Create(Splitted[3]);
    end;
  end;
end;

function TAppCore.DoNewToken(AReqID, ASessionKey, AFullName, AShortName,
  ATicker: string; AAmount: Int64; ADecimals: Integer): string;
var
  Splitted: TArray<string>;
  SmartKeyBlock: TCSmartKey;
  DateTime: string;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');

  AFullName := Trim(AFullName.Replace('<', '',
    [rfReplaceAll]).Replace('>', '', [rfReplaceAll]));
  if (Length(AFullName) < 10) or (Length(AFullName) > 255) then
    raise EValidError.Create('invalid token information');
  AShortName := Trim(AShortName.Replace('<', '',
    [rfReplaceAll]).Replace('>', '', [rfReplaceAll]));
  if not CheckShortName(AShortName) then
    raise EValidError.Create('invalid token name');

  ATicker := Trim(ATicker).ToUpper;
  if not CheckTickerName(ATicker) then
      raise EValidError.Create('invalid ticker');
  if FBlockchain.TryGetSmartKey(ATicker, SmartKeyBlock) then
    raise ETokenAlreadyExists.Create('');

  if (AAmount < 1000) or (AAmount > 9999999999999999) then
    raise EValidError.Create('invalid amount value');
  if (ADecimals < 2) or (ADecimals > 8) then
    raise EValidError.Create('invalid decimals value');
  if Length(AAmount.ToString) + ADecimals > 18 then
    raise EValidError.Create('invalid decimals value');

  DateTime := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);
  Result := FNodeCLient.DoRequest(AReqID,
    Format('AddNewIcoToken %s <%s> <0> <%s> <%s> <%s> <%d> <%d> <6> <2> <%s> <%s> <3>',
    [AReqID, ASessionKey, AFullName, AShortName, ATicker.ToUpper, AAmount,
     ADecimals, DateTime, DateTime]));
  if IsURKError(Result) then
  begin;
    Splitted := Result.Split([' ']);
    case Splitted[3].ToInteger of
      20: raise EKeyExpiredError.Create('');
      44: raise ETokenAlreadyExists.Create('');
      3203: raise EInsufficientFundsError.Create('');
      else raise EUnknownError.Create(Splitted[3]);
    end;
  end;
end;

procedure TAppCore.DoNewToken(AReqID, ASessionKey, AFullName, AShortName,
  ATicker: string; AAmount: Int64; ADecimals: Integer;
  ACallBackProc: TGetStrProc);
var
  SmartKeyBlock: TCSmartKey;
  DateTime: string;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');
  DateTime := FormatDateTime('dd.mm.yyyy hh:mm:ss', Now);

  AFullName := Trim(AFullName.Replace('<', '',
    [rfReplaceAll]).Replace('>', '', [rfReplaceAll]));
  if (Length(AFullName) < 10) or (Length(AFullName) > 255) then
    raise EValidError.Create('invalid token information');
  AShortName := Trim(AShortName.Replace('<', '',
    [rfReplaceAll]).Replace('>', '', [rfReplaceAll]));
  if not CheckShortName(AShortName) then
    raise EValidError.Create('invalid token name');

  ATicker := Trim(ATicker).ToUpper;
  if not CheckTickerName(ATicker) then
      raise EValidError.Create('invalid ticker');
  if FBlockchain.TryGetSmartKey(ATicker, SmartKeyBlock) then
    raise ETokenAlreadyExists.Create('');

  if (AAmount < 1000) or (AAmount > 9999999999999999) then
    raise EValidError.Create('invalid amount value');
  if (ADecimals < 2) or (ADecimals > 8) then
    raise EValidError.Create('invalid decimals value');
  if Length(AAmount.ToString) + ADecimals > 18 then
    raise EValidError.Create('invalid decimals value');

  TThread.CreateAnonymousThread(
  procedure
  var
    Response: string;
  begin
    Response := FNodeCLient.DoRequest(AReqID,
      Format('AddNewIcoToken %s <%s> <0> <%s> <%s> <%s> <%d> <%d> <6> <2> <%s> <%s> <3>',
      [AReqID, ASessionKey, AFullName, AShortName, ATicker.ToUpper, AAmount,
       ADecimals, DateTime, DateTime]));

    TThread.Synchronize(nil,
    procedure
    begin
      ACallBackProc(Response);
    end);
  end).Start;
end;

function TAppCore.DoReg(AReqID, ASeed: string; out APubKey, APrKey, ALogin,
  APassword, AAddress, ASavingPath: string): string;
var
  Keys: IAsymmetricCipherKeyPair;
  BytesArray: TCryptoLibByteArray;
  Splitted: TArray<string>;
begin
  if (Length(ASeed.Split([' '])) <> 12) then
    raise EValidError.Create('incorrect seed phrase');

  GenECDSAKeysOnPhrase(ASeed,Keys);
  SetLength(BytesArray,0);
  BytesArray := (Keys.Public as IECPublicKeyParameters).Q.GetEncoded;
  APubKey := BytesToHex(BytesArray).ToLower;

  AAddress := '0x' + APubKey.Substring(Length(APubKey) - 40, 40).ToLower;
  ALogin := AAddress + LOGIN_POSTFIX;
  APassword := GenPass;

  Result := FNodeClient.DoRequest(AReqID, Format('RegLight * %s %s 1 %s %s',
    [ALogin, APassword, APassword, APubKey]));
  if IsURKError(Result) then
  begin;
    Splitted := Result.Split([' ']);
    case Splitted[3].ToInteger of
      829: raise EAccAlreadyExistsError.Create('');
      else raise EUnknownError.Create(Splitted[3]);
    end;
  end;

  SetLength(BytesArray, 0);
  BytesArray := (Keys.Private as IECPrivateKeyParameters).D.ToByteArray;
  APrKey := BytesToHex(BytesArray).ToLower;

  ASavingPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'keys');
  if not DirectoryExists(ASavingPath) then TDirectory.CreateDirectory(ASavingPath);
  ASavingPath := TPath.Combine(ASavingPath, 'keys');
  ASavingPath := Format('%s_%s.txt', [ASavingPath, Result.Split([' '])[2]]);
  TFile.AppendAllText(ASavingPath, 'public key:' + APubKey + sLineBreak);
  TFile.AppendAllText(ASavingPath, 'private key:' + APrKey + sLineBreak);
  TFile.AppendAllText(ASavingPath, Format('seed phrase:"%s"', [ASeed]) +
    sLineBreak, TEncoding.ANSI);
  TFile.AppendAllText(ASavingPath, 'login:' + ALogin + sLineBreak);
  TFile.AppendAllText(ASavingPath, 'password:' + APassword + sLineBreak);
  TFile.AppendAllText(ASavingPath, 'address:' + AAddress);
end;

function TAppCore.DoTETTransfer(AReqID, ASessionKey, ATo: string;
  AAmount: Double): string;
var
  Splitted: TArray<string>;
  AmountStr: string;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');
  if (AAmount <= 0) or (AAmount > 999999999999999999) then
    raise EValidError.Create('incorrect amount');
  AmountStr := FormatFloat('0.########', AAmount);
  if (Length(AmountStr.Replace(',', '')) > 18) or
     (Length(Copy(AmountStr, AmountStr.IndexOf(',') + 2, 10)) > 8) then
    raise EValidError.Create('incorrect amount');

  Result := FNodeClient.DoRequest(AReqID, Format('TokenTransfer * %s * %s %s %s',
    [ASessionKey, ATo, AmountStr, AmountStr]));
  if IsURKError(Result) then
  begin;
    Splitted := Result.Split([' ']);
    case Splitted[3].ToInteger of
      20: raise EKeyExpiredError.Create('');
      55: raise EAddressNotExistsError.Create('');
      110: raise EInsufficientFundsError.Create('');
      4042: raise ESameAddressesError.Create('');
      else raise EUnknownError.Create(Splitted[3]);
    end;
  end;
end;

procedure TAppCore.DoTETTransfer(AReqID, ASessionKey, ATo: string;
  AAmount: Double; ACallBackProc: TGetStrProc);
var
  AmountStr: string;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');
  if (AAmount <= 0) or (AAmount > 999999999999999999) then
    raise EValidError.Create('incorrect amount');
  AmountStr := FormatFloat('0.########', AAmount);
  if (Length(AmountStr.Replace(',', '')) > 18) or
     (Length(Copy(AmountStr, AmountStr.IndexOf(',') + 2, 10)) > 8) then
    raise EValidError.Create('incorrect amount');

  TThread.CreateAnonymousThread(
    procedure
    var
      Response: string;
    begin
      Response := FNodeClient.DoRequest(AReqID, Format('TokenTransfer * %s * %s %s %s',
        [ASessionKey, ATo, AmountStr, AmountStr]));

      TThread.Synchronize(nil,
      procedure
      begin
        ACallBackProc(Response);
      end);
    end).Start;
end;

function TAppCore.DoTokenTransfer(AReqID, AAddrTETFrom, AAddrTETTo,
  ASmartAddr: string; AAmount: Double; APrKey, APubKey: string): string;
var
  AmountStr, Sign, SignLine: string;
  Splitted: TArray<string>;
  SmartKey: TCSmartKey;
begin
  AAddrTETFrom := Remove0x(AAddrTETFrom);
  if Length(AAddrTETFrom) <> 40 then
    raise EValidError.Create('invalid address "from"');
  AAddrTETTo := Remove0x(AAddrTETTo);
  if Length(AAddrTETFrom) <> 40 then
    raise EValidError.Create('invalid address "to"');
  if AAddrTETFrom.Equals(AAddrTETTo) then
    raise ESameAddressesError.Create('');
  if not FBlockchain.TryGetSmartKey(ASmartAddr, SmartKey) then
    raise ESmartNotExistsError.Create('');

  ASmartAddr := Remove0x(ASmartAddr);
  if Length(ASmartAddr) <> 40 then
    raise EValidError.Create('invalid smartcontract address');

  if (AAmount <= 0) or (AAmount > 999999999999999999) then
    raise EValidError.Create('invalid amount value');
  AmountStr := FormatFloat('0.########', AAmount);
  if (Length(AmountStr.Replace(',', '')) > 18) or
     (Length(Copy(AmountStr, AmountStr.IndexOf(',') + 2, 10)) > 8) then
    raise EValidError.Create('incorrect amount');

  if Length(APrKey) <> 64 then
    raise EValidError.Create('invalid private key');
  if Length(APubKey) <> 130 then
    raise EValidError.Create('invalid public key');

  SignLine := Format('%s %s %s %s',[AAddrTETFrom, AAddrTETTo, ASmartAddr, AmountStr]);
  Sign := SignTransaction(SignLine, APrKey).ToLower;
  if Sign.IsEmpty then
    raise EValidError.Create('invalid private key');

  Result := FNodeClient.DoRequestToValidator(
    Format('TknCTransfer %s %s %s %s <%s> %s %s %s',
    [AReqID, AAddrTETFrom, AAddrTETTo, AmountStr, SignLine, Sign,
     APubKey, ASmartAddr]));
  if IsURKError(Result) then
  begin;
    Splitted := Result.Split([' ']);
    case Splitted[3].ToInteger of
      41502: raise EInvalidSignError.Create('');
      41500: raise ESocketError.Create('');
      41501: raise EUnknownError.Create('41501');
      41505: raise ERequestInProgressError.Create('');
      110: raise EInsufficientFundsError.Create('');
      else raise EUnknownError.Create(Splitted[3]);
    end;
  end;
end;

procedure TAppCore.DoTokenTransfer(AReqID, AAddrTETFrom, AAddrTETTo,
  ASmartAddr: string; AAmount: Double; APrKey, APubKey: string;
  ACallBackProc: TGetStrProc);
var
  AmountStr, Sign, SignLine, Response: string;
begin
  AAddrTETFrom := Remove0x(AAddrTETFrom);
  if Length(AAddrTETFrom) <> 40 then
    raise EValidError.Create('invalid address "from"');
  AAddrTETTo := Remove0x(AAddrTETTo);
  if Length(AAddrTETFrom) <> 40 then
    raise EValidError.Create('invalid address "to"');
  if AAddrTETFrom.Equals(AAddrTETTo) then
    raise ESameAddressesError.Create('');
  ASmartAddr := Remove0x(ASmartAddr);
  if Length(ASmartAddr) <> 40 then
    raise EValidError.Create('invalid smartcontract address');

  if (AAmount <= 0) or (AAmount > 999999999999999999) then
    raise EValidError.Create('invalid amount value');
  AmountStr := FormatFloat('0.########', AAmount);
  if (Length(AmountStr.Replace(',', '')) > 18) or
     (Length(Copy(AmountStr, AmountStr.IndexOf(',') + 2, 10)) > 8) then
    raise EValidError.Create('incorrect amount');

  if Length(APrKey) <> 64 then
    raise EValidError.Create('invalid private key');
  if Length(APubKey) <> 130 then
    raise EValidError.Create('invalid public key');

  SignLine := Format('%s %s %s %s', [AAddrTETFrom, AAddrTETTo, ASmartAddr, AmountStr]);
  Sign := SignTransaction(SignLine, APrKey).ToLower;
  if Sign.IsEmpty then
    raise EValidError.Create('invalid private key');

  TThread.CreateAnonymousThread(
  procedure
  begin
    try
      try
        Response := FNodeClient.DoRequestToValidator(
          Format('TknCTransfer %s %s %s %s <%s> %s %s %s',
          [AReqID, AAddrTETFrom, AAddrTETTo, AmountStr, SignLine, Sign,
           APubKey, ASmartAddr]));
      except
        on E:EValidatorDidNotAnswerError do
          Response := Format('URKError U16 * 41501 <UserKey:%s>', [AReqID]);
      end;
    finally
      TThread.Synchronize(nil,
      procedure
      begin
        ACallBackProc(Response);
      end);
    end;
  end).Start;
end;

procedure TAppCore.DoReg(AReqID, ASeed: string; ACallBackProc: TGetStrProc);
var
  Keys: IAsymmetricCipherKeyPair;
  BytesArray: TCryptoLibByteArray;
  PubKey, Address, Login, Password: string;
begin
  if (Length(ASeed.Split([' '])) <> 12) then
    raise EValidError.Create('incorrect seed phrase');

  GenECDSAKeysOnPhrase(ASeed, Keys);
  SetLength(BytesArray, 0);
  BytesArray := (Keys.Public as IECPublicKeyParameters).Q.GetEncoded;
  PubKey := BytesToHex(BytesArray).ToLower;

  Address := '0x' + PubKey.Substring(Length(PubKey) - 40, 40).ToLower;
  Login := Address + LOGIN_POSTFIX;
  Password := GenPass;

  TThread.CreateAnonymousThread(
    procedure
    var
      Response, PrKey, SavingPath: string;
    begin
      Response := FNodeClient.DoRequest(AReqID, Format('RegLight * %s %s 1 %s %s',
        [Login, Password, Password, PubKey]));
      if not IsURKError(Response) then
      begin
        SetLength(BytesArray, 0);
        BytesArray := (Keys.Private as IECPrivateKeyParameters).D.ToByteArray;
        PrKey := BytesToHex(BytesArray).ToLower;

        SavingPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'keys');
        if not DirectoryExists(SavingPath) then
          TDirectory.CreateDirectory(SavingPath);
        SavingPath := TPath.Combine(SavingPath, 'keys');
        SavingPath := Format('%s_%s.txt', [SavingPath, Response.Split([' '])[2]]);
        TFile.AppendAllText(SavingPath, 'public key:' + PubKey + sLineBreak);
        TFile.AppendAllText(SavingPath, 'private key:' + PrKey + sLineBreak);
        TFile.AppendAllText(SavingPath, Format('seed phrase:"%s"', [ASeed]) +
          sLineBreak, TEncoding.ANSI);
        TFile.AppendAllText(SavingPath, 'login:' + Login + sLineBreak);
        TFile.AppendAllText(SavingPath, 'password:' + Password + sLineBreak);
        TFile.AppendAllText(SavingPath, 'address:' + Address);

        Response := Format('%s %s %s %s %s "%s"',[PubKey, PrKey, Login, Password,
          Address, SavingPath]);
      end;

      TThread.Synchronize(nil,
      procedure
      begin
        ACallBackProc(Response);
      end);
    end).Start;
end;

function TAppCore.GetNewTokenFee(AAmount: Int64; ADecimals: Integer): Integer;
begin
  if (AAmount < 1000) or (AAmount > 9999999999999999) then
    raise EValidError.Create('invalid amount value');
  if (ADecimals < 2) or (ADecimals > 8) then
    raise EValidError.Create('invalid decimals value');
  if Length(AAmount.ToString) + ADecimals > 18 then
    raise EValidError.Create('invalid decimals value');

  Result := Min((AAmount div (ADecimals * 10)) + 1, 10);
end;

function TAppCore.GetTokenBalanceWithTokenAddress(ATETAddress,
  ATokenAddress: string; out AFloatSize: Byte): Double;
var
  UserID: Integer;
  SmartKey: TCSmartKey;
  TokenICO: TTokenICODat;
begin
  if not FBlockchain.TryGetUserIDByTETAddress(ATETAddress, UserID) then
    raise EAddressNotExistsError.Create('');
  if not AppCore.TryGetSmartKey(ATokenAddress, SmartKey) then
    raise ESmartNotExistsError.Create('');
  TryGetTokenICO(SmartKey.Abreviature, TokenICO);
  AFloatSize := TokenICO.FloatSize;

  Result := GetTokenBalance(SmartKey.SmartID, ATETAddress);
end;

function TAppCore.GetTokenBalanceWithTicker(ATETAddress, ATicker: string;
  out AFloatSize: Byte): Double;
var
  UserID: Integer;
  SmartKey: TCSmartKey;
  TokenICO: TTokenICODat;
begin
  if (Length(ATicker) = 0) or not CheckTickerName(Trim(ATicker).ToUpper) then
    raise EValidError.Create('invalid ticker');

  if not FBlockchain.TryGetUserIDByTETAddress(ATETAddress, UserID) then
    raise EAddressNotExistsError.Create('');
  if not FBlockchain.TryGetSmartKey(ATicker, SmartKey) then
    raise ESmartNotExistsError.Create('');
  TryGetTokenICO(SmartKey.Abreviature, TokenICO);
  AFloatSize := TokenICO.FloatSize;

  Result := GetTokenBalance(SmartKey.SmartID, ATETAddress);
end;

function TAppCore.DoRecoverKeys(ASeed: string; out PubKey: string;
  out PrKey: string): string;
var
  FKeys: IAsymmetricCipherKeyPair;
  ByteArr: TCryptoLibByteArray;
begin
  if (Length(ASeed.Split([' '])) <> 12) then
    raise EValidError.Create('incorrect seed phrase');

  GenECDSAKeysOnPhrase(ASeed, FKeys);
  ByteArr := (FKeys.Public as IECPublicKeyParameters).Q.GetEncoded;
  SetLength(PubKey, Length(ByteArr) * 2);
  BinToHex(ByteArr, PChar(PubKey), Length(ByteArr));
  PubKey := PubKey.ToLower;

  SetLength(ByteArr, 0);
  PrKey := '';
  ByteArr := (FKeys.Private as IECPrivateKeyParameters).D.ToByteArray;
  SetLength(PrKey, Length(ByteArr) * 2);
  BinToHex(ByteArr, PChar(PrKey), Length(ByteArr));
  PrKey := PrKey.ToLower;
end;

procedure TAppCore.TryExtractPrivateKeyFromFile(out PrKey: string;
  out PubKey: string);
var
  Path: string;
  Lines: TArray<string>;
  i: Integer;
begin
  Path := TPath.Combine(ExtractFilePath(ParamStr(0)), 'keys');
  Path := TPath.Combine(Path, 'keys');
  Path := Format('%s_%d.txt', [Path, AppCore.UserID]);
  if not FileExists(Path) then
    raise EFileNotExistsError.Create('');
  Lines := TFile.ReadAllLines(Path);

  for i := 0 to Length(Lines) - 1 do
  begin
    if Lines[i].StartsWith('private key') then
      PrKey := Lines[i].Split([':'])[1]
    else if Lines[i].StartsWith('public key') then
      PubKey := Lines[i].Split([':'])[1];

    if not (PrKey.IsEmpty or PubKey.IsEmpty) then
      break;
  end;
end;

function TAppCore.GenPass(x1, x2: longint): string;
const
  p1 = 100000000;
var
  l,h: Int64;
  m: Real;
begin
  m := time * p1 + random;
  h := trunc(m);
  m := m - h;
  l := trunc(m * p1);
  Result := (l*(x2 - x1 + 1) div (p1) + x1).ToString;
end;

function TAppCore.GetTETBlocksTotalCount(AReqID: string): string;
begin
  Result := FNodeClient.DoRequest(AReqID, 'GetBlockCount1 * *');
end;

function TAppCore.GetLoadingStatus: Boolean;
begin
  Result := FStartLoadingDone;
end;

function TAppCore.GetPubKeyByID(AReqID: string; AUserID: Integer): string;
var
  Splitted: TArray<string>;
begin
  if AUserID < 0 then
    raise EValidError.Create('invalid account ID');

  Result := FNodeClient.DoRequest(AReqID,
    Format('GetUPubliKey * IPAZovO7l32 %d', [AUserID]));
  if IsURKError(Result) then
  begin;
    Splitted := Result.Split([' ']);
    case Splitted[3].ToInteger of
      31201: raise EAddressNotExistsError.Create('');
      31202: raise ENoInfoForThisAccountError.Create('');
      else raise EUnknownError.Create(Splitted[3]);
    end;
  end;
end;

function TAppCore.GetPubKeyBySessionKey(AReqID, ASessionKey: string): string;
var
  Splitted: TArray<string>;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');

  Result := FNodeClient.DoRequest(AReqID, 'GetMyPubliKey * ' + ASessionKey);
  if IsURKError(Result) then
  begin;
    Splitted := Result.Split([' ']);
    case Splitted[3].ToInteger of
      20: raise EKeyExpiredError.Create('');
      31202: raise ENoInfoForThisAccountError.Create('');
      else raise EUnknownError.Create(Splitted[3]);
    end;
  end;
end;

function TAppCore.GetTETUserLastTransactions(AUserID, ASkip,
  ARows: Integer): TArray<THistoryTransactionInfo>;
begin
  if AUserID < 0 then
    raise EValidError.Create('invalid "user id" value');
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  Result := FBlockchain.GetTETUserLastTransactions(AUserID, ASkip, ARows);
end;

function TAppCore.GetTETTransactions(ASkip: Integer; ARows: Integer;
  AFromTheEnd: Boolean): TArray<TExplorerTransactionInfo>;
begin
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  Result := FBlockchain.GetTETTransactions(ASkip, ARows, AFromTheEnd);
end;

function TAppCore.GetSessionKey: string;
begin
  Result := FSessionKey;
end;

function TAppCore.GetTokenAddress(ATokenID: Integer): string;
var
  SmartKey: TCSmartKey;
begin
  if ATokenID < 0 then
    raise EValidError.Create('invalid token ID');

  if FBlockchain.TryGetSmartKey(ATokenID, SmartKey) then
    Result := SmartKey.key1
  else
    raise ESmartNotExistsError.Create('');
end;

function TAppCore.GetTokenAddress(ATicker: string): string;
var
  SmartKey: TCSmartKey;
begin
  if (Length(ATicker) = 0) or not CheckTickerName(Trim(ATicker).ToUpper) then
    raise EValidError.Create('invalid ticker');

  if FBlockchain.TryGetSmartKey(ATicker.ToUpper, SmartKey) then
    Result := SmartKey.key1
  else
    raise ESmartNotExistsError.Create('');
end;

function TAppCore.GetTETAddress: string;
begin
  Result := FTETAddress;
end;

function TAppCore.GetTETChainBlockSize: Integer;
begin
  Result := FBlockchain.GetTETChainBlockSize;
end;

function TAppCore.GetTETChainBlocksCount: Integer;
begin
  Result := FBlockchain.GetTETChainBlocksCount;
end;

function TAppCore.GetTETChainBlocks(ASkip: Integer): TBytes;
begin
  Result := FBlockchain.GetTETChainBlocks(ASkip);
end;

procedure TAppCore.SetTETChainBlocks(ASkip: Integer; ABytes: TBytes);
begin
  FBlockchain.SetTETChainBlocks(ASkip, ABytes);
end;

function TAppCore.GetTETBalance(ABlockNum: Integer;
  ATETDyn: TTokenBase): Double;
var
  TETBlock: Tbc2;
  ICODat: TTokenICODat;
begin
  if not (FBlockchain.TryGetICOBlock(ATETDyn.TokenDatID, ICODat) and
          FBlockchain.TryGetTETChainBlock(ATETDyn.LastBlock, TETBlock)) then
    exit(0);

  if ABlockNum = TETBlock.Smart.tkn[1].TokenID then
		Result := TETBlock.Smart.tkn[1].Amount / Power(10, ICODat.FloatSize)
	else if ABlockNum = TETBlock.Smart.tkn[2].TokenID then
		Result := TETBlock.Smart.tkn[2].Amount / Power(10, ICODat.FloatSize)
	else
    raise EUnknownError.Create('');
end;

function TAppCore.GetTETBalance(ATETAddress: string): Double;
var
  TETDyn: TTokenBase;
  BlockNum: Integer;
begin
  if not FBlockchain.TryGetDynTETBlock(ATETAddress, BlockNum, TETDyn) then
    raise EAddressNotExistsError.Create('');

  Result := GetTETBalance(BlockNum, TETDyn);
end;

function TAppCore.GetDynTETChainBlockSize: Integer;
begin
  Result := FBlockchain.GetDynTETChainBlockSize;
end;

function TAppCore.GetDynTETChainBlocksCount: Integer;
begin
  Result := FBlockchain.GetDynTETChainBlocksCount;
end;

function TAppCore.GetDynTETChainBlocks(ASkip: Integer): TBytes;
begin
  Result := FBlockchain.GetDynTETChainBlocks(ASkip);
end;

procedure TAppCore.SetDynTETChainBlocks(ASkip: Integer; ABytes: TBytes);
begin
  FBlockchain.SetDynTETBlocks(ASkip, ABytes);
end;

function TAppCore.GetTokenICOBlockSize: Integer;
begin
  Result := FBlockchain.GetICOBlockSize;
end;

function TAppCore.GetTokenICOBlocksCount: Integer;
begin
  Result := FBlockchain.GetICOBlocksCount;
end;

function TAppCore.GetTokenICOBlocks(ASkip: Integer): TBytes;
begin
  Result := FBlockchain.GetICOBlocks(ASkip);
end;

procedure TAppCore.SetTokenICOBlocks(ASkip: Integer; ABytes: TBytes);
begin
  FBlockchain.SetICOBlocks(ASkip, ABytes);
end;

function TAppCore.GetTokensICOs(ASkip, ARows: Integer): TArray<TTokenICODat>;
begin
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  Result := FBlockchain.GetTokenICOs(ASkip, ARows);
end;

function TAppCore.TryGetTokenICO(ATicker: string;
  out ATokenICO: TTokenICODat): Boolean;
begin
  Result := FBlockchain.TryGetICOBlock(ATicker, ATokenICO);
end;

function TAppCore.GetSmartKeyBlocksCount: Integer;
begin
  Result := FBlockchain.GetSmartKeyBlocksCount;
end;

function TAppCore.GetSmartKeyBlockSize: Integer;
begin
  Result := FBlockchain.GetSmartKeyBlockSize;
end;

function TAppCore.GetSmartKeyBlocks(ASkip: Integer): TBytes;
begin
  Result := FBlockchain.GetSmartKeyBlocks(ASkip);
end;

procedure TAppCore.SetSmartKeyBlocks(ASkip: Integer; ABytes: TBytes);
begin
  FBlockchain.SetSmartKeyBlocks(ASkip, ABytes);
end;

function TAppCore.GetAllSmartKeyBlocks: TArray<TCSmartKey>;
begin
  Result := FBlockchain.GetSmartKeys(0, FBlockchain.GetSmartKeyBlocksCount);
end;

function TAppCore.TryGetSmartKey(ATickerOrAddress: string;
  out ASmartKey: TCSmartKey): Boolean;
begin
  Result := FBlockchain.TryGetSmartKey(ATickerOrAddress, ASmartKey);
end;

function TAppCore.TryGetDynTETBlock(ATETAddress: string; var ABlockID: Integer;
  out ATETDyn: TTokenBase): Boolean;
begin
  Result := FBlockchain.TryGetDynTETBlock(ATETAddress, ABlockID, ATETDyn);
end;

function TAppCore.TryGetSmartKey(ATokenID: Integer;
  out ASmartKey: TCSmartKey): Boolean;
begin
  Result := FBlockchain.TryGetSmartKey(ATokenID, ASmartKey);
end;

procedure TAppCore.UpdateTokensList;
begin
  FBlockchain.UpdateTokensList;
end;

function TAppCore.GetTokensToSynchronize: TArray<Integer>;
begin
  Result := FSettings.GetTokensToSynchronize;
end;

procedure TAppCore.AddTokenToSynchronize(ATokenID: Integer);
begin
  FSettings.AddTokenToSync(ATokenID);
end;

procedure TAppCore.RemoveTokenFromSynchronize(ATokenID: Integer);
begin
  FSettings.RemoveTokenToSync(ATokenID);
end;

function TAppCore.GetTokenChainBlocksCount(ATokenID: Integer): Integer;
begin
  Result := FBlockchain.GetTokenChainBlocksCount(ATokenID);
end;

function TAppCore.GetTokenChainBlockSize: Integer;
begin
  Result := SizeOf(TCbc4);
end;

function TAppCore.GetTokenBalance(ATokenID, ABlockNum: Integer;
  ATETDyn: TTokenBase): Double;
var
  TokenBlock: TCbc4;
  ICODat: TTokenICODat;
  TokenDyn: TCTokensBase;
begin
  if not (FBlockchain.TryGetDynTokenBlock(ATokenID, ATETDyn, ABlockNum, TokenDyn) and
          FBlockchain.TryGetTokenChainBlock(ATokenID, TokenDyn.LastBlock, TokenBlock) and
          FBlockchain.TryGetICOBlock(ATokenID, ICODat)) then
    exit(0);

  if ABlockNum = TokenBlock.Smart.tkn[1].TokenID then
		Result := TokenBlock.Smart.tkn[1].Amount / Power(10, ICODat.FloatSize)
	else if ABlockNum = TokenBlock.Smart.tkn[2].TokenID then
		Result := TokenBlock.Smart.tkn[2].Amount / Power(10, ICODat.FloatSize)
	else
    raise EUnknownError.Create('');
end;

function TAppCore.GetTokenBalance(ATokenID: Integer; ATETAddress: string): Double;
var
  TETDyn: TTokenBase;
  BlockNum: Integer;
begin
  if not FBlockchain.TryGetDynTETBlock(ATETAddress, BlockNum, TETDyn) then
    exit(0)
  else
    Result := GetTokenBalance(ATokenID, BlockNum, TETDyn);
end;

function TAppCore.GetTokenUserTransactions(ATokenID, AUserID, ASkip,
  ARows: Integer; ALast: Boolean): TArray<THistoryTransactionInfo>;
begin
  if AUserID < 0 then
    raise EValidError.Create('invalid "user id" value');
  if ATokenID < 0 then
    raise EValidError.Create('invalid "token id" value');
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  if ALast then
    Result := FBlockchain.GetTokenUserLastTransactions(ATokenID, AUserID, ARows);
end;

function TAppCore.GetTokenTransactions(ATokenID, ASkip, ARows: Integer;
  AFromTheEnd: Boolean): TArray<TExplorerTransactionInfo>;
begin
  if ATokenID < 0 then
    raise EValidError.Create('invalid "token id" value');
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');


  Result := FBlockchain.GetTokenTransactions(ATokenID, ASkip, ARows, AFromTheEnd);
end;

function TAppCore.GetTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
begin
  Result := FBlockchain.GetTokenChainBlocks(ATokenID, ASkip);
end;

procedure TAppCore.SetTokenChainBlocks(ATokenID: Integer; ASkip: Integer;
  ABytes: TBytes);
begin
  FBlockchain.SetTokenChainBlocks(ATokenID, ASkip, ABytes);
end;

function TAppCore.GetDynTokenChainBlocksCount(ATokenID: Integer): Integer;
begin
  Result := FBlockchain.GetDynTokenChainBlocksCount(ATokenID);
end;

function TAppCore.GetDynTokenChainBlockSize: Integer;
begin
  Result := FBlockchain.GetDynTokenChainBlockSize;
end;

function TAppCore.GetDynTokenChainBlocks(ATokenID, ASkip: Integer): TBytes;
begin
  Result := FBlockchain.GetDynTokenChainBlocks(ATokenID, ASkip);
end;

procedure TAppCore.SetDynTokenChainBlocks(ATokenID, ASkip: Integer;
  ABytes: TBytes);
begin
  FBlockchain.SetDynTokenChainBlocks(ATokenID, ASkip, ABytes);
end;

function TAppCore.GetUserID: Integer;
begin
  Result := FUserID;
end;

function TAppCore.GetVersion: string;
begin
  Result := NODE_VERSION;
end;

function TAppCore.Remove0x(AAddress: string): string;
begin
  if (Length(AAddress) > 40) and AAddress.StartsWith('0x') then
    Result := AAddress.Substring(2, Length(AAddress))
  else
    Result := AAddress;
end;

procedure TAppCore.Run;
var
  splt: TArray<string>;
  errStr: string;
begin
  try
    FSettings.Init;
    FBlockchain := TBlockchain.Create;
    splt := ListenTo.Split([':']);
    FNodeServer.Start(splt[0],splt[1].ToInteger);
    FHTTPServer.Start(HTTPPort);
    FNodeClient.Start;
  except
    on E:Exception do
    begin
      errStr := 'Error starting node: ' + E.Message;
      Logs.DoLog(errStr, ERROR);
      raise;
    end;
  end;
end;

function TAppCore.TrySaveKeysToFile(APrivateKey: string): Boolean;
var
  Path, PubKey: string;
begin
  Result := RestorePublicKey(APrivateKey, PubKey);
  if not Result then
    exit;

  Path := TPath.Combine(ExtractFilePath(ParamStr(0)), 'keys');
  if not DirectoryExists(Path) then
    TDirectory.CreateDirectory(Path);
  Path := TPath.Combine(Path, 'keys');
  Path := Format('%s_%d.txt', [Path, FUserID]);
  TFile.AppendAllText(Path, 'public key:' + PubKey + sLineBreak);
  TFile.AppendAllText(Path, 'private key:' + APrivateKey + sLineBreak);
end;

function TAppCore.SearchTransactionByHash(const AHash: string;
  out ATransaction: TExplorerTransactionInfo): Boolean;
begin
  Result := FBlockchain.SearchTransactionByHash(AHash, ATransaction);
end;

function TAppCore.SearchTransactionsByAddress(
  const ATETAddress: string): TArray<TExplorerTransactionInfo>;
begin
  Result := FBlockchain.SearchTransactionsByAddress(ATETAddress);
end;

function TAppCore.SearchTransactionsByBlockNum(
  const ABlockNum: Integer): TArray<TExplorerTransactionInfo>;
begin
  Result := FBlockchain.SearchTransactionsByBlockNum(ABlockNum);
end;

function TAppCore.SendToConfirm(AReqID, AToSend: string): string;
begin
  Result := FNodeClient.DoRequest(AReqID, AToSend);
end;

procedure TAppCore.SetLoadingStatus(const AIsDone: Boolean);
begin
  FStartLoadingDone := AIsDone;
end;

procedure TAppCore.SetSessionKey(const ASessionKey: string);
begin
  FSessionKey := ASessionKey;
end;

procedure TAppCore.SetUserID(const AID: Integer);
begin
  FUserID := AID;

  if not FBlockchain.TryGetTETAddressByUserID(FUserID, FTETAddress) then
    FTETAddress := '';
end;

function TAppCore.SignTransaction(const AToSign: string; const APrivateKey: string): string;
var
  prKeyBytes: TBytes;
begin
  prKeyBytes := HexToBytes(APrivateKey);

  ECDSASignText(AToSign,prKeyBytes,Result);
end;

procedure TAppCore.Stop;
begin
  FNodeServer.Stop;
  FHTTPServer.Stop;
  FNodeClient.Stop;
end;

function TAppCore.TryGetTokenBaseByAddress(const AAddress: string;
  var ASmartKey: TCSmartKey): Boolean;
begin
  Result := FBlockchain.TryGetSmartKey(AAddress, ASmartKey);
end;

end.
