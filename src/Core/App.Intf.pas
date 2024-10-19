unit App.Intf;

interface

uses
  Blockchain.BaseTypes,
  Classes,
  SysUtils;

type
  IUI = interface
    procedure Run;
    procedure NullForm(var Form);
    procedure ShowMainForm;
    procedure ShowEnterPrivateKeyForm;
    procedure ShowTotalBlocksToDownload(const ABlocksNumberToLoad: UInt64);
    procedure ShowDownloadProgress;
    procedure NotifyNewTETBlocks(const ANeedRefreshBalance: Boolean);
    procedure NotifyNewToken(const ATicker: string; ATokenID: Integer);
    procedure NotifyNewTokenBlocks(const ANeedRefreshBalance: Boolean);
  end;

  IAppCore = interface
    function GetVersion: String;
    procedure Run;
    procedure Stop;
    function GetSessionKey: String;
    function GetTETAddress: String;
    function GetUserID: Integer;
    function GetLoadingStatus: Boolean;
    procedure SetSessionKey(const ASessionKey: String);
    procedure SetUserID(const AID: Integer);
    procedure SetLoadingStatus(const AIsDone: Boolean);

    //TET chain methods
    function GetTETChainBlockSize: Integer;
    function GetTETChainBlocksCount: Integer;
    function GetTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetTETChainBlocks(ASkip: Integer; ABytes: TBytes);
    function GetTETUserTransactions(AUserID: Integer; ASkip: Integer;
      ARows: Integer; ALast: Boolean = False): TArray<THistoryTransactionInfo>;
//    function GetChainTransations(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
//    function GetChainLastTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;

//    function GetTETUserLastTransactions(AUserID: Int64;
//      var ANumber: Integer): TArray<THistoryTransactionInfo>;
    function GetTETBalance(ATETAddress: string): Double; overload;
//    function GetTETLocalBalance(ATETAddress: String): Double; overload;

    //TET dynamic blocks sync methods
    function GetDynTETChainBlockSize: Integer;
    function GetDynTETChainBlocksCount: Integer;
    function GetDynTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetDynTETChainBlocks(ASkip: Integer; ABytes: TBytes);

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
    function TryGetSmartKey(ATicker: string; out ASmartKey: TCSmartKey): Boolean; overload;
    function TryGetSmartKey(ATokenID: Integer; out ASmartKey: TCSmartKey): Boolean; overload;

    //Tokens chains methods
    procedure UpdateTokensList;
    function GetTokensToSynchronize: TArray<Integer>;
    procedure AddTokenToSynchronize(ATokenID: Integer);
    procedure RemoveTokenFromSynchronize(ATokenID: Integer);
    function GetTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetTokenChainBlockSize: Integer;
    function GetTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetTokenChainBlocks(ATokenID: Integer; ASkip: Integer; ABytes: TBytes);
    function GetTokenBalance(ATokenID: Integer; ATETAddress: string): Double;

    //Tokens dynamic blocks sync methods
    function GetDynTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetDynTokenChainBlockSize: Integer;
    function GetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer; ABytes: TBytes);
//    function GetSmartBlocks(ASmartID: Integer;
//      var AAmount: Integer): TBytesBlocks; overload;
//    function GetSmartBlocks(ATicker: String;
//      out AAmount: Integer): TBytesBlocks; overload;
////    function GetSmartBlocks(ASmartName: String;
////      var AAmount: Integer): TBytesBlocks; overload;
//    function GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
//    function GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
//    function GetSmartTransactions(ATicker: String; ASkip: Integer;
//      var ARows: Integer): TArray<TExplorerTransactionInfo>;
//    function GetSmartLastTransactions(ATicker: String;
//      var Amount: Integer): TArray<TExplorerTransactionInfo>;
//    function GetSmartLastUserTransactions(AUserID: Integer; ATicker: String;
//      var Amount: Integer): TArray<THistoryTransactionInfo>;
//
//    //Dynamic blocks sync methods
//    function GetDynBlocksCount(ADynID: Integer): Integer;
//    function GetDynBlockSize(ADynID: Integer): Integer;
//    function GetDynBlocks(ADynID: Integer; AFrom: Int64;
//      out AAmount: Integer): TBytesBlocks;
//    procedure SetDynBlocks(ADynID: Integer; APos: Int64; ABytes: TBytesBlocks;
//      AAmount: Integer);
//    procedure SetDynBlock(ADynID: Integer; APos: Int64; ABytes: TOneBlockBytes);
//
//    function GetBlocksCount(AReqID: String): String;
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
//    function DoRecoverKeys(ASeed: string; out PubKey: string;
//      out PrKey: string): string;
    procedure DoNewToken(AReqID, ASessionKey, AFullName, AShortName,
      ATicker: string; AAmount: Int64; ADecimals: Integer;
      ACallBackProc: TGetStrProc); overload;
    function DoNewToken(AReqID, ASessionKey, AFullName, AShortName,
      ATicker: string; AAmount: Int64; ADecimals: Integer): string; overload;
//    function GetNewTokenFee(AAmount: Int64; ADecimals: Integer): Integer;
//    function DoTokenTransfer(AReqID,AAddrTETFrom,AAddrTETTo,ASmartAddr: string;
//      AAmount: Extended; APrKey,APubKey: string): string;
//    function SendToConfirm(AReqID,AToSend: string): string;
//    function GetLocalTokensBalances: TArray<string>;

//    function DoGetTokenBalanceWithSmartAddress(AReqID,AAddressTET,ASmartAddress: string): string;
//    function DoGetTokenBalanceWithTicker(AReqID,AAddressTET,ATicker: string): string;
//
//    function GetSmartAddressByID(AID: Int64): string;
//    function GetSmartAddressByTicker(ATicker: string): string;
//    function GetPubKeyByID(AReqID: string; AID: Int64): string;
//    function GetPubKeyBySessionKey(AReqID,ASessionKey: string): string;
    function TrySaveKeysToFile(APrivateKey: string): Boolean;
    function TryExtractPrivateKeyFromFile(out PrKey: string;
      out PubKey: string): Boolean;

//    function TryGetTokenBase(ATicker: string; var sk: TCSmartKey): Boolean;
//    function TryGetTokenBaseByAddress(const AAddress: string; var sk: TCSmartKey): Boolean;

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
