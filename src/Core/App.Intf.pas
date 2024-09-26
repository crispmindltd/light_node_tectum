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
    procedure DoMessage(const AMessage: String);
    procedure NullForm(var Form);
    procedure ShowMainForm;
    procedure ShowEnterPrivateKeyForm;
    function IsChainNeedSync(const AName: String): Boolean;
    procedure ShowTotalBlocksToDownload(const ATotalTETBlocksToDownload: Int64);
    procedure ShowDownloadProgress;
    procedure NotifyNewTETBlocks(const ANeedRefreshBalance: Boolean);
    procedure NotifyNewSmartBlocks;
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
    function GetTETChainBlocksCount: Int64;
//    function GetTETChainBlock(ASkip: Int64): Tbc2;
    function GetTETChainBlocks(ASkip: Int64): TBytes;
//    function GetChainBlocks(var AAmount: Integer): TBytesBlocks; overload;
    procedure SetTETChainBlocks(ASkip: Int64; ABytes: TBytes);
//    function GetChainTransations(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
//    function GetChainLastTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
//    function GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
//      var ARows: Integer): TArray<THistoryTransactionInfo>;
    function GetTETUserLastTransactions(AUserID: Int64;
      var ANumber: Integer): TArray<THistoryTransactionInfo>;
    function GetTETLocalBalance: Double; overload;
    function GetTETLocalBalance(ATETAddress: String): Double; overload;

    //IcoDat blocks sync methods
    function GetTokenICOBlocksCount: Int64;
    function GetTokenICOBlockSize: Integer;
    function GetTokenICOBlocks(ASkip: Int64): TBytes;
    procedure SetTokenICOBlocks(ASkip: Int64; ABytes: TBytes);

    //SmartKey blocks sync methods
    function GetSmartKeyBlocksCount: Int64;
    function GetSmartKeyBlockSize: Integer;
    function GetSmartKeyBlocks(ASkip: Int64): TBytes;
    procedure SetSmartKeyBlocks(ASkip: Int64; ABytes: TBytes);

    //Smartcontracts sync methods
//    function GetSmartBlocksCount(ASmartID: Integer): Integer;
//    function GetSmartBlockSize(ASmartID: Integer): Integer;
//    function GetSmartBlocks(ASmartID: Integer; AFrom: Int64;
//      out AAmount: Integer): TBytesBlocks; overload;
//    function GetSmartBlocks(ASmartID: Integer;
//      var AAmount: Integer): TBytesBlocks; overload;
//    function GetSmartBlocks(ATicker: String;
//      out AAmount: Integer): TBytesBlocks; overload;
////    function GetSmartBlocks(ASmartName: String;
////      var AAmount: Integer): TBytesBlocks; overload;
//    function GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
//    function GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
//    procedure SetSmartBlocks(ASmartID: Integer; APos: Int64; ABytes: TBytesBlocks;
//      AAmount: Integer);
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

//    procedure UpdateLists;
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
//
//    function TryGetTokenICO(ATicker: string; var tICO: TTokenICODat): Boolean;
//    function GetTokensICOs(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
//    function TryGetTokenBase(ATicker: string; var sk: TCSmartKey): Boolean;
//    function TryGetTokenBaseByAddress(const AAddress: string; var sk: TCSmartKey): Boolean;

    property SessionKey: string read GetSessionKey write SetSessionKey;
    property TETAddress: string read GetTETAddress;
    property UserID: Int64 read GetUserID write SetUserID;
    property TETChainSyncDone: Boolean read GetLoadingStatus write SetLoadingStatus;
  end;

var
  AppCore: IAppCore = nil;
  UI: IUI = nil;

implementation

end.
