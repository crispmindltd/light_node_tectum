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
    FDownloadRemain: Int64;
    FSessionKey: String;
    FUserID: Int64;
    FTETAddress: String;
  private
    FSettings: TSettingsFile;
    FBlockchain: TBlockchain;
    FNodeServer: TNodeServer;
    FNodeClient: TNodeClient;
    FHTTPServer: THTTPServer;

    function GenPass(x1:LongInt = 100000000; x2:LongInt = 999999999): String;
    function CheckTickerName(const ATicker: String): Boolean;
    function CheckShortName(const AShortName: String): Boolean;
    function Remove0x(AAddress: String): String;
    function SignTransaction(const AToSign: String; const APrivateKey: String): String;
    function IsURKError(const ATest:string):Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function GetVersion: String;
    procedure Run;
    procedure Stop;
    function GetDownloadRemain: Int64;
    function GetSessionKey: String;
    function GetTETAddress: String;
    function GetUserID: Int64;
    procedure SetDownloadRemain(const AIncValue: Int64);
    procedure SetSessionKey(const ASessionKey: String);
    procedure SetUserID(const AID: Int64);
//    procedure BeginSync(AChainName: String; AIsSystemChain: Boolean);
//    procedure StopSync(AChainName: String; AIsSystemChain: Boolean);

    //Chain sync methods
    function GetChainBlocksCount: Integer;
    function GetChainBlockSize: Integer;
    function GetOneChainBlock(AFrom: Int64): TOneBlockBytes;
    function GetChainBlocks(AFrom: Int64; out AAmount: Integer): TBytesBlocks; overload;
    function GetChainBlocks(var AAmount: Integer): TBytesBlocks; overload;
    procedure SetChainBlocks(APos: Int64; ABytes: TBytesBlocks; AAmount: Integer);
    function GetChainTransations(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
    function GetChainLastTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
    function GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
      var ARows: Integer): TArray<THistoryTransactionInfo>;
    function GetChainLastUserTransactions(AUserID: Integer;
      var Amount: Integer): TArray<THistoryTransactionInfo>;

    //Smartcontracts sync methods
    function GetSmartBlocksCount(ASmartID: Integer): Integer;
    function GetSmartBlockSize(ASmartID: Integer): Integer;
    function GetSmartBlocks(ASmartID: Integer; AFrom: Int64;
      out AAmount: Integer): TBytesBlocks; overload;
    function GetSmartBlocks(ASmartID: Integer;
      var AAmount: Integer): TBytesBlocks; overload;
    function GetSmartBlocks(ATicker: String;
      out AAmount: Integer): TBytesBlocks; overload;
//    function GetSmartBlocks(ASmartName: String; var AAmount: Integer): TBytesBlocks; overload;
    function GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
    function GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
    procedure SetSmartBlocks(ASmartID: Integer; APos: Int64;
      ABytes: TBytesBlocks; AAmount: Integer);
    function GetSmartTransactions(ATicker: String; ASkip: Integer;
      var ARows: Integer): TArray<TExplorerTransactionInfo>;
    function GetSmartLastTransactions(ATicker: String;
      var Amount: Integer): TArray<TExplorerTransactionInfo>;
    function GetSmartLastUserTransactions(AUserID: Integer; ATicker: String;
      var Amount: Integer): TArray<THistoryTransactionInfo>;

    //Dynamic blocks sync methods
    function GetDynBlocksCount(ADynID: Integer): Integer;
    function GetDynBlockSize(ADynID: Integer): Integer;
    function GetDynBlocks(ADynID: Integer; AFrom: Int64;
      out AAmount: Integer): TBytesBlocks;
    procedure SetDynBlocks(ADynID: Integer; APos: Int64; ABytes: TBytesBlocks;
      AAmount: Integer);
    procedure SetDynBlock(ADynID: Integer; APos: Int64; ABytes: TOneBlockBytes);

    //IcoDat blocks sync methods
    function GetICOBlocksCount: Integer;
    function GetICOBlockSize: Integer;
    function GetICOBlocks(AFrom: Int64; out AAmount: Integer): TBytesBlocks;
    procedure SetICOBlocks(APos: Int64; ABytes: TBytesBlocks; AAmount: Integer);

    procedure UpdateLists;

    function GetBlocksCount(AReqID: String): String;
    function DoReg(AReqID: String; ASeed: String; out PubKey: String;
      out PrKey: String; out Login: String; out Password: String;
      out Address: String; out sPath: String): String;
    function DoAuth(AReqID,ALogin,APassword: String): String;
    function DoRecoverKeys(ASeed: String; out PubKey: String;
      out PrKey: String): String;
    function DoCoinsTransfer(AReqID,ASessionKey,ATo: String; AAmount: Extended): String;
    function GetLocalTETBalance: Extended; overload;
    function GetLocalTETBalance(ATETAddress: String): Extended; overload;
    function DoNewToken(AReqID,ASessionKey,AFullName,AShortName,ATicker: String;
      AAmount: Int64; ADecimals: Integer): String;
    function GetNewTokenFee(AAmount: Int64; ADecimals: Integer): Integer;
    function DoTokenTransfer(AReqID,AAddrTETFrom,AAddrTETTo,ASmartAddr: String;
      AAmount: Extended; APrKey,APubKey: String): String;
    function SendToConfirm(AReqID,AToSend: String): String;
    function GetLocalTokensBalances: TArray<String>;
    function GetLocalTokenBalance(ATokenID: Integer; AOwnerID: Int64): Extended;
    function DoGetTokenBalanceWithSmartAddress(AReqID,AAddressTET,ASmartAddress: String): String;
    function DoGetTokenBalanceWithTicker(AReqID,AAddressTET,ATicker: String): String;

    function GetSmartAddressByID(AID: Int64): String;
    function GetSmartAddressByTicker(ATicker: String): String;
    function GetPubKeyByID(AReqID: String; AID: Int64): String;
    function GetPubKeyBySessionKey(AReqID,ASessionKey: String): String;
    function TrySaveKeysToFile(APrivateKey: String): Boolean;
    function TryExtractPrivateKeyFromFile(out PrKey: String;
      out PubKey: String): Boolean;

    function TryGetTokenICO(ATicker: String; var tICO: TTokenICODat): Boolean;
    function GetTokensICOs(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
    function TryGetTokenBase(ATicker: string; var sk: TCSmartKey): Boolean;

    property DownloadRemain: Int64 read GetDownloadRemain write SetDownloadRemain;
    property SessionKey: String read GetSessionKey write SetSessionKey;
    property TETAddress: String read GetTETAddress;
    property UserID: Int64 read GetUserID write SetUserID;
  end;

implementation

{ TAppCore }

function TAppCore.IsURKError(const ATest:string):Boolean;
begin
  Result := ATest.StartsWith(ConstStr.URKError);
end;

function TAppCore.CheckShortName(const AShortName: String): Boolean;
const
  Acceptable = 'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm0123456789-., ';
var
  i: Integer;
begin
  Result := False;
  if (Length(AShortName) < 3) or (Length(AShortName) > 32) then exit;
  for i := 1 to Length(AShortName) do
    if Acceptable.IndexOf(AShortName[i]) = -1 then exit;
  Result := True;
end;

//procedure TAppCore.BeginSync(AChainName: String; AIsSystemChain: Boolean);
//begin
//  FNodeClient.BeginSync(AChainName,AIsSystemChain);
//end;

function TAppCore.CheckTickerName(const ATicker: String): Boolean;
const
  Acceptable = 'QWERTYUIOPASDFGHJKLZXCVBNM1234567890';
var
  i: Integer;
begin
  Result := False;
  if (Length(ATicker) < 3) or (Length(ATicker) > 8) then exit;
  if TryStrToInt(ATicker[1],i) then exit;
  for i := 1 to Length(ATicker) do
    if Acceptable.IndexOf(ATicker[i]) = -1 then exit;
  Result := True;
end;

constructor TAppCore.Create;
begin
  Logs := TLogs.Create;
  FSettings := TSettingsFile.Create;
  FNodeServer := TNodeServer.Create;
  FNodeClient := TNodeClient.Create;
  FHTTPServer := THTTPServer.Create;

  FDownloadRemain := 0;
  FSessionKey := '';
  FTETAddress := '';
  FUserID := -1;
end;

destructor TAppCore.Destroy;
begin
  FNodeServer.Free;
  FHTTPServer.Free;
  FNodeClient.Free;
  FSettings.Free;
  if Assigned(FBlockchain) then FBlockchain.Free;
  Logs.Free;

  inherited;
end;

function TAppCore.DoAuth(AReqID,ALogin,APassword: String): String;
var
  splt: TArray<String>;
begin
  if not (ALogin.Contains('@') and ALogin.Contains('.')) then
    raise EValidError.Create('incorrect login');
  if APassword.IsEmpty then
    raise EValidError.Create('incorrect password');

  Result := FNodeClient.DoRequest(AReqID,Format('CheckPW * %s %s ipa',[ALogin,APassword]));
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      93: raise EAuthError.Create('');
      816: raise EAuthError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;
end;

function TAppCore.GetLocalTETBalance: Extended;
var
  oneBlock1: TOneBlockBytes;
  bc2: Tbc2 absolute oneBlock1;
  tICO: TTokenICODat;
  tb: TTokenBase;
  ID: Integer;
begin
  if not FBlockchain.TryGetTETTokenBase(FUserID,ID,tb) then
    raise EAddressNotExistsError.Create('');

  oneBlock1 := GetOneChainBlock(tb.LastBlock);
  if not FBlockchain.TryGetOneICOBlock(tb.TokenDatID,tICO) then exit;
  if ID = bc2.Smart.tkn[1].TokenID then
		Result := bc2.Smart.tkn[1].Amount / Power(10,tICO.FloatSize)
	else if ID = bc2.Smart.tkn[2].TokenID then
		Result := bc2.Smart.tkn[2].Amount / Power(10,tICO.FloatSize)
	else
    raise EUnknownError.Create('');
end;

function TAppCore.GetLocalTETBalance(ATETAddress: String): Extended;
var
  oneBlock1: TOneBlockBytes;
  bc2: Tbc2 absolute oneBlock1;
  tICO: TTokenICODat;
  tb: TTokenBase;
  ID: Integer;
begin
  if not FBlockchain.TryGetTETTokenBase(ATETAddress,ID,tb) then
    raise EAddressNotExistsError.Create('');

  oneBlock1 := GetOneChainBlock(tb.LastBlock);
  if not FBlockchain.TryGetOneICOBlock(tb.TokenDatID,tICO) then exit;
  if ID = bc2.Smart.tkn[1].TokenID then
		Result := bc2.Smart.tkn[1].Amount / Power(10,tICO.FloatSize)
	else if ID = bc2.Smart.tkn[2].TokenID then
		Result := bc2.Smart.tkn[2].Amount / Power(10,tICO.FloatSize)
	else
    raise ENoInfoForThisAccountError.Create('');
end;

function TAppCore.GetLocalTokenBalance(ATokenID: Integer; AOwnerID: Int64): Extended;
var
  bc4: TCbc4;
  tICO: TTokenICODat;
  tcb: TCTokensBase;
  ID: Integer;
begin
  if not FBlockchain.TryGetCTokenBase(ATokenID,AOwnerID,ID,tcb) then
    Exit(0);

  bc4 := FBlockchain.GetOneSmartBlock(ATokenID,tcb.LastBlock);
  if not FBlockchain.TryGetOneICOBlock(ATokenID,tICO) then exit;
  if ID = bc4.Smart.tkn[1].TokenID then
		Result := bc4.Smart.tkn[1].Amount / Power(10,tICO.FloatSize)
	else if ID = bc4.Smart.tkn[2].TokenID then
		Result := bc4.Smart.tkn[2].Amount / Power(10,tICO.FloatSize)
	else
    raise ENoInfoForThisAccountError.Create('');
end;

function TAppCore.GetLocalTokensBalances: TArray<String>;
var
  sk: TCSmartKey;
  bValue: String;
  i: Integer;
begin
  Result := [];
  for i := 0 to GetSmartBlocksCount(-1)-1 do
  begin
    sk := GetOneSmartKeyBlock(i);
    bValue := Format('%s:%f',[sk.Abreviature,GetLocalTokenBalance(sk.SmartID,FUserID)]);
    Result := Result + [bValue];
  end;
end;

function TAppCore.GetNewTokenFee(AAmount: Int64; ADecimals: Integer): Integer;
begin
  if (AAmount < 1000) or (AAmount > 9999999999999999) then
    raise EValidError.Create('invalid amount value');
  if (ADecimals < 2) or (ADecimals > 8) then
    raise EValidError.Create('invalid decimals value');
  if Length(AAmount.ToString) + ADecimals > 18 then
    raise EValidError.Create('invalid decimals value');

  Result := Min((AAmount div (ADecimals * 10)) + 1,10);
end;

function TAppCore.DoGetTokenBalanceWithSmartAddress(AReqID, AAddressTET,
  ASmartAddress: String): String;
var
  splt: TArray<String>;
begin
  AAddressTET := Remove0x(AAddressTET);
//  if Length(AAddressTET) <> 40 then
//    raise EValidError.Create('invalid address');
  if not FBlockchain.IsSmartExists(ASmartAddress) then
    raise ESmartNotExistsError.Create('');
  ASmartAddress := Remove0x(ASmartAddress);
  if Length(ASmartAddress) <> 40 then
    raise EValidError.Create('invalid smartcontract address');

  Result := FNodeCLient.DoRequest(AReqID,Format('GetSmrtAmount %s IPAZ0vO7lO32 %s %s',
    [AReqID,AAddressTET,ASmartAddress]));
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      31203: raise EAddressNotExistsError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;
end;

function TAppCore.DoGetTokenBalanceWithTicker(AReqID,AAddressTET,
  ATicker: String): String;
var
  smartAddr: String;
begin
  if (Length(ATicker) = 0) or not CheckTickerName(Trim(ATicker).ToUpper) then
    raise EValidError.Create('invalid ticker');
  AAddressTET := Remove0x(AAddressTET);

  smartAddr := GetSmartAddressByTicker(ATicker.ToUpper);
  Result := DoGetTokenBalanceWithSmartAddress(AReqID,AAddressTET,smartAddr);
end;

function TAppCore.DoNewToken(AReqID, ASessionKey, AFullName, AShortName, ATicker: String;
  AAmount: Int64; ADecimals: Integer): String;
var
  splt: TArray<String>;
  dateTime: String;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');

  AFullName := Trim(AFullName.Replace('<','',[rfReplaceAll]).Replace('>','',[rfReplaceAll]));
  if (Length(AFullName) < 10) or (Length(AFullName) > 255) then
    raise EValidError.Create('invalid token information');
  AShortName := Trim(AShortName.Replace('<','',[rfReplaceAll]).Replace('>','',[rfReplaceAll]));
  if not CheckShortName(AShortName) then
    raise EValidError.Create('invalid token name');

  ATicker := Trim(ATicker).ToUpper;
  if not CheckTickerName(ATicker) then
      raise EValidError.Create('invalid ticker');
  if FBlockchain.IsSmartExists(ATicker) then
    raise ETokenAlreadyExists.Create('');

  if (AAmount < 1000) or (AAmount > 9999999999999999) then
    raise EValidError.Create('invalid amount value');
  if (ADecimals < 2) or (ADecimals > 8) then
    raise EValidError.Create('invalid decimals value');
  if Length(AAmount.ToString) + ADecimals > 18 then
    raise EValidError.Create('invalid decimals value');

  dateTime := FormatDateTime('dd.mm.yyyy hh:mm:ss',Now);
  Result := FNodeCLient.DoRequest(AReqID,Format('AddNewIcoToken %s <%s> <0> <%s> <%s> <%s> <%d> <%d> <6> <2> <%s> <%s> <3>',
    [AReqID,ASessionKey,AFullName,AShortName,ATicker.ToUpper,AAmount,ADecimals,dateTime,dateTime]));
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      20: raise EKeyExpiredError.Create('');
      44: raise ETokenAlreadyExists.Create('');
      3203: raise EInsufficientFundsError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;
end;

function TAppCore.DoRecoverKeys(ASeed: String; out PubKey: String;
  out PrKey: String): String;
var
  FKeys: IAsymmetricCipherKeyPair;
  arr: TCryptoLibByteArray;
begin
  if (Length(ASeed.Split([' '])) <> 12) then
    raise EValidError.Create('incorrect seed phrase');

  GenECDSAKeysOnPhrase(ASeed,FKeys);
  arr := (FKeys.Public as IECPublicKeyParameters).Q.GetEncoded;
  SetLength(PubKey,Length(arr) * 2);
  BinToHex(arr,pchar(PubKey),Length(arr));
  PubKey := PubKey.ToLower;

  SetLength(arr,0);
  PrKey := '';
  arr := (FKeys.Private as IECPrivateKeyParameters).D.ToByteArray;
  SetLength(PrKey,Length(arr) * 2);
  BinToHex(arr,pchar(PrKey),Length(arr));
  PrKey := PrKey.ToLower;
end;

function TAppCore.DoReg(AReqID: String; ASeed: String; out PubKey: String;
  out PrKey: String; out Login: String; out Password: String;
  out Address: String; out sPath: String): String;
var
  FKeys: IAsymmetricCipherKeyPair;
  arr: TCryptoLibByteArray;
  splt: TArray<String>;
begin
  if (Length(ASeed.Split([' '])) <> 12) then
    raise EValidError.Create('incorrect seed phrase');

  GenECDSAKeysOnPhrase(ASeed,FKeys);
  SetLength(arr,0);
  arr := (FKeys.Public as IECPublicKeyParameters).Q.GetEncoded;
  PubKey := BytesToHex(arr).ToLower;

  Address := '0x' + PubKey.Substring(Length(PubKey)-40,40).ToLower;
  Login := Address + LOGIN_POSTFIX;
  Password := GenPass;

  Result := FNodeClient.DoRequest(AReqID,Format('RegLight * %s %s 1 %s %s',
    [Login,Password,Password,PubKey]));
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      829: raise EAccAlreadyExistsError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;

  SetLength(arr,0);
  arr := (FKeys.Private as IECPrivateKeyParameters).D.ToByteArray;
  PrKey := BytesToHex(arr).ToLower;

  sPath := TPath.Combine(ExtractFilePath(ParamStr(0)),'keys');
  if not DirectoryExists(sPath) then TDirectory.CreateDirectory(sPath);
  sPath := TPath.Combine(sPath,'keys');
  sPath := Format('%s_%s.txt',[sPath,Result.Split([' '])[2]]);
  TFile.AppendAllText(sPath,'public key:' + PubKey + #13#10);
  TFile.AppendAllText(sPath,'private key:' + PrKey + #13#10);
  TFile.AppendAllText(sPath,Format('seed phrase:"%s"',[ASeed]) + #13#10, TEncoding.ANSI);
  TFile.AppendAllText(sPath,'login:' + Login + #13#10);
  TFile.AppendAllText(sPath,'password:' + Password + #13#10);
  TFile.AppendAllText(sPath,'address:' + Address);
end;

function TAppCore.DoTokenTransfer(AReqID,AAddrTETFrom,AAddrTETTo,ASmartAddr: String;
  AAmount: Extended; APrKey,APubKey: String): String;
var
  AmountStr,sign,signLine,res: String;
  splt: TArray<String>;
  requestDone: TEvent;
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
  if (Length(AmountStr.Replace(',','')) > 18) or
     (Length(Copy(AmountStr,AmountStr.IndexOf(',')+2,10)) > 8) then
    raise EValidError.Create('incorrect amount');

  if Length(APrKey) <> 64 then
    raise EValidError.Create('invalid private key');
  if Length(APubKey) <> 130 then
    raise EValidError.Create('invalid public key');

  signLine := Format('%s %s %s %s',[AAddrTETFrom,AAddrTETTo,ASmartAddr,AmountStr]);
  sign := SignTransaction(signLine,APrKey).ToLower;
  if sign.IsEmpty then
    raise EValidError.Create('invalid private key');

  requestDone := TEvent.Create;
  requestDone.ResetEvent;
  try
    TThread.CreateAnonymousThread(
    procedure
    begin
      res := FNodeClient.DoRequestToValidator(
        Format('TknCTransfer %s %s %s %s <%s> %s %s %s',
        [AReqID,AAddrTETFrom,AAddrTETTo,AmountStr,signLine,sign,APubKey,ASmartAddr]));
      requestDone.SetEvent;
    end).Start;
    if requestDone.WaitFor(600000) = wrTimeout then
      raise ESocketError.Create('');
  finally
    requestDone.Free;
  end;

  Result := res;
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      41502: raise EInvalidSignError.Create('');
      41500: raise ESocketError.Create('');
      41501: raise EUnknownError.Create('41501');
      41505: raise ERequestInProgressError.Create('');
      110: raise EInsufficientFundsError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;
end;

function TAppCore.TryExtractPrivateKeyFromFile(out PrKey: String;
  out PubKey: String): Boolean;
var
  sPath: String;
  lines: TArray<String>;
  i: Integer;
begin
  sPath := TPath.Combine(ExtractFilePath(ParamStr(0)),'keys');
  sPath := TPath.Combine(sPath,'keys');
  sPath := Format('%s_%d.txt',[sPath,AppCore.UserID]);
  if not FileExists(sPath) then raise EFileNotExistsError.Create('');
  lines := TFile.ReadAllLines(sPath);

  for i := 0 to Length(lines)-1 do
  begin
    if lines[i].StartsWith('private key') then
      PrKey := lines[i].Split([':'])[1]
    else if lines[i].StartsWith('public key') then
      PubKey := lines[i].Split([':'])[1];

    if not(PrKey.IsEmpty or PubKey.IsEmpty) then break;
  end;
end;

function TAppCore.DoCoinsTransfer(AReqID, ASessionKey, ATo: String;
  AAmount: Extended): String;
var
  splt: TArray<String>;
  AmountStr: String;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');
  if (AAmount <= 0) or (AAmount > 999999999999999999) then
    raise EValidError.Create('incorrect amount');

  AmountStr := FormatFloat('0.########', AAmount);
  if (Length(AmountStr.Replace(',','')) > 18) or
     (Length(Copy(AmountStr,AmountStr.IndexOf(',')+2,10)) > 8) then
    raise EValidError.Create('incorrect amount');

  Result := FNodeClient.DoRequest(AReqID,Format('TokenTransfer * %s * %s %s %s',
    [ASessionKey,ATo,AmountStr,AmountStr]));
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      20: raise EKeyExpiredError.Create('');
      55: raise EAddressNotExistsError.Create('');
      110: raise EInsufficientFundsError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;
end;

function TAppCore.GenPass(x1, x2: longint): String;
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

function TAppCore.GetChainBlocks(AFrom: Int64; out AAmount: Integer): TBytesBlocks;
begin
  Result := FBlockchain.GetChainBlocks(AFrom,AAmount);
end;

function TAppCore.GetChainBlocks(var AAmount: Integer): TBytesBlocks;
begin
  Result := FBlockchain.GetChainBlocks(AAmount);
end;

function TAppCore.GetBlocksCount(AReqID: String): String;
begin
  Result := FNodeClient.DoRequest(AReqID,'GetBlockCount1 * *');
end;

function TAppCore.GetChainBlocksCount: Integer;
begin
  Result := FBlockchain.GetChainBlocksCount;
end;

function TAppCore.GetChainBlockSize: Integer;
begin
  Result := FBlockchain.GetChainBlockSize;
end;

function TAppCore.GetDownloadRemain: Int64;
begin
  Result := FDownloadRemain;
end;

function TAppCore.GetDynBlocks(ADynID: Integer; AFrom: Int64;
  out AAmount: Integer): TBytesBlocks;
begin
  Result := FBlockchain.GetDynBlocks(ADynID,AFrom,AAmount);
end;

function TAppCore.GetDynBlocksCount(ADynID: Integer): Integer;
begin
  Result := FBlockchain.GetDynBlocksCount(ADynID);
end;

function TAppCore.GetDynBlockSize(ADynID: Integer): Integer;
begin
  Result := FBlockchain.GetDynBlockSize(ADynID);
end;

function TAppCore.GetICOBlocks(AFrom: Int64; out AAmount: Integer): TBytesBlocks;
begin
  Result := FBlockchain.GetICOBlocks(AFrom,AAmount);
end;

function TAppCore.GetICOBlocksCount: Integer;
begin
  Result := FBlockchain.GetICOBlocksCount;
end;

function TAppCore.GetICOBlockSize: Integer;
begin
  Result := FBlockchain.GetICOBlockSize;
end;

function TAppCore.GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
begin
  Result := FBlockchain.GetOneSmartKeyBlock(AFrom);
end;

function TAppCore.GetOneChainBlock(AFrom: Int64): TOneBlockBytes;
begin
  Result := FBlockchain.GetOneChainBlock(AFrom);
end;

function TAppCore.GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
begin
  Result := FBlockchain.GetOneSmartBlock(ASmartID,AFrom);
end;

function TAppCore.GetPubKeyByID(AReqID: String; AID: Int64): String;
var
  splt: TArray<String>;
begin
  if AID < 0 then
    raise EValidError.Create('invalid account ID');

  Result := FNodeClient.DoRequest(AReqID,Format('GetUPubliKey * IPAZovO7l32 %d',[AID]));
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      20: raise EKeyExpiredError.Create('');
      31201: raise EAddressNotExistsError.Create('');
      31202: raise ENoInfoForThisAccountError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;
end;

function TAppCore.GetPubKeyBySessionKey(AReqID, ASessionKey: String): String;
var
  splt: TArray<String>;
begin
  if not(ASessionKey.StartsWith('ipa') and (Length(ASessionKey) = 34)) then
    raise EValidError.Create('incorrect session key');

  Result := FNodeClient.DoRequest(AReqID,'GetMyPubliKey * ' + ASessionKey);
  if IsURKError(Result) then
  begin;
    splt := Result.Split([' ']);
    case splt[3].ToInteger of
      20: raise EKeyExpiredError.Create('');
      31202: raise ENoInfoForThisAccountError.Create('');
      else raise EUnknownError.Create(splt[3]);
    end;
  end;
end;

function TAppCore.GetSmartBlocks(ASmartID: Integer; AFrom: Int64;
  out AAmount: Integer): TBytesBlocks;
begin
  Result := FBlockchain.GetSmartBlocks(ASmartID,AFrom,AAmount);
end;

function TAppCore.GetSmartBlocks(ASmartID: Integer;
  var AAmount: Integer): TBytesBlocks;
begin
  Result := FBlockchain.GetSmartBlocks(ASmartID,AAmount);
end;

function TAppCore.GetSmartBlocks(ATicker: String; out AAmount: Integer): TBytesBlocks;
begin
  Result := FBlockchain.GetSmartBlocks(ATicker,AAmount);
end;

//function TAppCore.GetSmartBlocks(ASmartName: String; AFrom: Int64;
//  out AAmount: Integer): TBytesBlocks;
//begin
//  Result := FBlockchain.GetSmartBlocks(ASmartName,AFrom,AAmount);
//end;

function TAppCore.GetSmartBlocksCount(ASmartID: Integer): Integer;
begin
  if ASmartID = -1 then
    Result := FBlockchain.GetSmartsAmount
  else
    Result := FBlockchain.GetSmartBlocksCount(ASmartID);
end;

function TAppCore.GetSmartBlockSize(ASmartID: Integer): Integer;
begin
  Result := FBlockchain.GetSmartBlockSize(ASmartID);
end;

function TAppCore.GetSmartLastTransactions(ATicker: String;
  var Amount: Integer): TArray<TExplorerTransactionInfo>;
begin
  Result := FBlockchain.GetLastSmartTransactions(ATicker,Amount);
end;

function TAppCore.GetSmartLastUserTransactions(AUserID: Integer;
  ATicker: String; var Amount: Integer): TArray<THistoryTransactionInfo>;
begin
  Result := FBlockchain.GetLastSmartUserTransactions(AUserID,ATicker,Amount);
end;

function TAppCore.GetSmartTransactions(ATicker: String; ASkip: Integer;
  var ARows: Integer): TArray<TExplorerTransactionInfo>;
begin
  if not CheckTickerName(ATicker) then
    raise EValidError.Create('invalid ticker');
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  Result := FBlockchain.GetSmartTransactions(ATicker,ASkip,ARows);
end;

function TAppCore.GetChainLastTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
begin
  Result := FBlockchain.GetLastChainTransactions(Amount);
end;

function TAppCore.GetChainLastUserTransactions(AUserID: Integer;
  var Amount: Integer): TArray<THistoryTransactionInfo>;
begin
  Result := FBlockchain.GetLastChainUserTransactions(AUserID,Amount);
end;

function TAppCore.GetChainTransations(ASkip: Integer;
  var ARows: Integer): TArray<TExplorerTransactionInfo>;
begin
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  Result := FBlockchain.GetChainTransactions(ASkip,ARows);
end;

function TAppCore.GetChainUserTransactions(AUserID, ASkip: Integer;
  var ARows: Integer): TArray<THistoryTransactionInfo>;
begin
  if AUserID < 0 then
    raise EValidError.Create('invalid "user id" value');
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  Result := FBlockchain.GetChainUserTransactions(AUserID,ASkip,ARows);
end;

function TAppCore.GetSessionKey: String;
begin
  Result := FSessionKey;
end;

function TAppCore.GetSmartAddressByID(AID: Int64): String;
begin
  if AID < 0 then
    raise EValidError.Create('invalid smart ID');

  Result := FBlockchain.GetSmartAddress(AID);
  if Result = '' then raise ESmartNotExistsError.Create('');
end;

function TAppCore.GetSmartAddressByTicker(ATicker: String): String;
begin
  if (Length(ATicker) = 0) or not CheckTickerName(Trim(ATicker).ToUpper) then
    raise EValidError.Create('invalid ticker');

  Result := FBlockchain.GetSmartAddress(ATicker);
  if Result = '' then raise ESmartNotExistsError.Create('');
end;

function TAppCore.GetTETAddress: String;
begin
  Result := FTETAddress;
end;

function TAppCore.GetTokensICOs(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
begin
  if ASkip < 0 then
    raise EValidError.Create('invalid "skip" value');
  if ARows <= 0 then
    raise EValidError.Create('invalid "rows" value');
  if ARows > 50 then
    raise EValidError.Create('"rows" value can''t be more than 50');

  Result := FBlockchain.GetICOsInfo(ASkip, ARows);
end;

function TAppCore.GetUserID: Int64;
begin
  Result := FUserID;
end;

function TAppCore.GetVersion: String;
begin
  Result := NODE_VERSION;
end;

function TAppCore.Remove0x(AAddress: String): String;
begin
  if (Length(AAddress) > 40) and AAddress.StartsWith('0x') then
    Result := AAddress.Substring(2,Length(AAddress))
  else
    Result := AAddress;
end;

procedure TAppCore.Run;
var
  splt: TArray<String>;
  errStr: String;
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

function TAppCore.TrySaveKeysToFile(APrivateKey: String): Boolean;
var
  sPath,PubKey: String;
begin
  Result := RestorePublicKey(APrivateKey,PubKey);
  if not Result then exit;

  sPath := TPath.Combine(ExtractFilePath(ParamStr(0)),'keys');
  if not DirectoryExists(sPath) then TDirectory.CreateDirectory(sPath);
  sPath := TPath.Combine(sPath,'keys');
  sPath := Format('%s_%d.txt',[sPath,FUserID]);
  TFile.AppendAllText(sPath,'public key:' + PubKey + #13#10);
  TFile.AppendAllText(sPath,'private key:' + APrivateKey + #13#10);
end;

function TAppCore.SendToConfirm(AReqID, AToSend: String): String;
begin
  Result := FNodeClient.DoRequest(AReqID,AToSend);
end;

procedure TAppCore.SetChainBlocks(APos: Int64; ABytes: TBytesBlocks; AAmount: Integer);
begin
  FBlockchain.SetChainBlocks(APos,ABytes,AAmount);
end;

procedure TAppCore.SetDynBlocks(ADynID: Integer; APos: Int64;
  ABytes: TBytesBlocks; AAmount: Integer);
begin
  FBlockchain.SetDynBlocks(ADynID,APos,ABytes,AAmount);
end;

procedure TAppCore.SetDownloadRemain(const AIncValue: Int64);
begin
  FDownloadRemain := Max(FDownloadRemain + AIncValue,0);
end;

procedure TAppCore.SetDynBlock(ADynID: Integer; APos: Int64; ABytes: TOneBlockBytes);
begin
  FBlockchain.SetDynBlock(ADynID,APos,ABytes);
end;

procedure TAppCore.SetICOBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
begin
  FBlockchain.SetICOBlocks(APos,ABytes,AAmount);
end;

procedure TAppCore.SetSessionKey(const ASessionKey: String);
begin
  FSessionKey := ASessionKey;
end;

procedure TAppCore.SetSmartBlocks(ASmartID: Integer; APos: Int64;
  ABytes: TBytesBlocks; AAmount: Integer);
begin
  if ASmartID = -1 then
    FBlockchain.SetSmartKeyBlocks(APos,ABytes,AAmount)
  else
    FBlockchain.SetSmartBlocks(ASmartID,APos,ABytes,AAmount);
end;

procedure TAppCore.SetUserID(const AID: Int64);
begin
  FUserID := AID;

  if not FBlockchain.TryGetTETAddressByOwnerID(FUserID,FTETAddress) then
    FTETAddress := '<address did not found>';
end;

function TAppCore.SignTransaction(const AToSign: String; const APrivateKey: String): String;
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

function TAppCore.TryGetTokenBase(ATicker: string; var sk: TCSmartKey): Boolean;
begin
  Result := FBlockchain.TryGetSmartKey(ATicker,sk);
end;

function TAppCore.TryGetTokenICO(ATicker: String;
  var tICO: TTokenICODat): Boolean;
begin
  Result := FBlockchain.TryGetOneICOBlock(ATicker,tICO);
end;

//procedure TAppCore.StopSync(AChainName: String; AIsSystemChain: Boolean);
//begin
//  FNodeClient.StopSync(AChainName, AIsSystemChain);
//end;

procedure TAppCore.UpdateLists;
begin
  FBlockchain.UpdateLists;
end;

end.

