unit App.Intf;

interface

uses
  App.Logs,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Classes,
  SyncObjs,
  SysUtils;

type
  IUI = interface
    procedure Run;
    procedure NullForm(var Form);
    procedure ShowMainForm;
    procedure ShowEnterPrivateKeyForm;
    function IsChainNeedSync(const AName: String): Boolean;
    procedure ShowTotalBlocksToDownload(const ABlocksNumberToLoad: Integer);
    procedure ShowDownloadProgress;
    procedure NotifyNewTETBlocks(const ANeedRefreshBalance: Boolean);
    procedure NotifyNewTokenBlocks(const ANeedRefreshBalance: Boolean);
  end;

  IAppCore = interface
    function GetVersion: String;
    procedure Run;
    procedure Stop;
    function GetSessionKey: String;
    function GetTETAddress: String;
    function GetUserID: Int64;
    function GetLoadingStatus: Boolean;
    procedure SetSessionKey(const ASessionKey: String);
    procedure SetUserID(const AID: Int64);
    procedure SetLoadingStatus(const AIsDone: Boolean);
//    procedure BeginSync(AChainName: String; AIsSystemChain: Boolean);
//    procedure StopSync(AChainName: String; AIsSystemChain: Boolean);

    //TET chain methods
    function GetTETChainBlockSize: Integer;
    function GetTETChainBlocksCount: Integer;
    function GetTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetTETChainBlocks(ASkip: Integer; ABytes: TBytes);
//    function GetChainTransations(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
//    function GetChainLastTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
//    function GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
//      var ARows: Integer): TArray<THistoryTransactionInfo>;
//    function GetTETUserLastTransactions(AUserID: Int64;
//      var ANumber: Integer): TArray<THistoryTransactionInfo>;
//    function GetTETLocalBalance: Double; overload;
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

    //SmartKey blocks sync methods
//    function GetSmartKeyBlocksCount: Int64;
//    function GetSmartKeyBlockSize: Integer;
//    function GetSmartKeyBlocks(ASkip: Int64): TBytes;
//    procedure SetSmartKeyBlocks(ASkip: Int64; ABytes: TBytes);

    //Tokens chains methods
//    procedure UpdateTokensList;
//    function GetTokensToSynchronize: TArray<Integer>;
//    procedure AddTokenToSynchronize(ATokenID: Integer);
//    procedure RemoveTokenToSynchronize(ATokenID: Integer);
//    function GetTokenChainBlocksCount(ATokenID: Integer): Int64;
//    function GetTokenBlockSize: Integer;
//    function GetTokenChainBlocks(ATokenID: Integer; ASkip: Int64): TBytes;
//    procedure SetTokenBlocks(ATokenID: Integer; ASkip: Int64; ABytes: TBytes);
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
    procedure DoReg(AReqID,ASeed: string; ACallBackProc: TGetStrProc); overload;
    function DoReg(AReqID: string; ASeed: string; out APubKey: string;
      out APrKey: string; out ALogin: string; out APassword: string;
      out AAddress: string; out ASavingPath: string): string; overload;
    procedure DoAuth(AReqID,ALogin,APassword: string;
      ACallBackProc: TGetStrProc); overload;
    function DoAuth(AReqID,ALogin,APassword: string): string; overload;
//    function DoCoinsTransfer(AReqID,ASessionKey,ATo: string; AAmount: Extended): string;
//    function DoRecoverKeys(ASeed: string; out PubKey: string;
//      out PrKey: string): string;
//
//    function DoNewToken(AReqID,ASessionKey,AFullName,AShortName,ATicker: string;
//      AAmount: Int64; ADecimals: Integer): string;
//    function GetNewTokenFee(AAmount: Int64; ADecimals: Integer): Integer;
//    function DoTokenTransfer(AReqID,AAddrTETFrom,AAddrTETTo,ASmartAddr: string;
//      AAmount: Extended; APrKey,APubKey: string): string;
//    function SendToConfirm(AReqID,AToSend: string): string;
//    function GetLocalTokensBalances: TArray<string>;
//    function GetLocalTokenBalance(ATokenID: Integer; AOwnerID: Int64): Extended;
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

//    function GetTokensICOs(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
//    function TryGetTokenBase(ATicker: string; var sk: TCSmartKey): Boolean;
//    function TryGetTokenBaseByAddress(const AAddress: string; var sk: TCSmartKey): Boolean;

    property SessionKey: string read GetSessionKey write SetSessionKey;
    property TETAddress: string read GetTETAddress;
    property UserID: Int64 read GetUserID write SetUserID;
    property BlocksSyncDone: Boolean read GetLoadingStatus write SetLoadingStatus;
  end;

var
  AppCore: IAppCore = nil;
  UI: IUI = nil;

implementation

end.
