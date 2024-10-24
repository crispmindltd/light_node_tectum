unit App.Intf;

interface

uses
  Blockchain.BaseTypes,
  Classes,
  SysUtils;

type
  IUI = interface
    procedure Run;
    procedure ShowMainForm;
    procedure ShowEnterPrivateKeyForm;
    procedure ShowTotalBlocksToDownload(const ABlocksNumberToLoad: UInt64);
    procedure ShowDownloadProgress;
    procedure ShowDownloadingDone;
    procedure NotifyNewTETBlocks(const ANeedRefreshBalance: Boolean);
    procedure NotifyNewToken(const ASmartKey: TCSmartKey);
    procedure NotifyNewTokenBlocks(const ASmartKey: TCSmartKey;
      ANeedRefreshBalance: Boolean);
  end;

  IAppCore = interface
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
    //Tokens dynamic blocks methods
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
    function TrySaveKeysToFile(APrivateKey: string): Boolean;
    procedure TryExtractPrivateKeyFromFile(out PrKey: string;
      out PubKey: string);

    property SessionKey: string read GetSessionKey write SetSessionKey;
    property TETAddress: string read GetTETAddress;
    property UserID: Integer read GetUserID write SetUserID;
    property BlocksSyncDone: Boolean read GetLoadingStatus write SetLoadingStatus;
  end;

var
  AppCore: IAppCore = nil;
  UI: IUI = nil;

implementation

end.
