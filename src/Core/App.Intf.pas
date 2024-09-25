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
//    function GetDownloadRemain: Int64;
    function GetSessionKey: String;
    function GetTETAddress: String;
    function GetUserID: Int64;
//    procedure SetDownloadRemain(const AIncValue: Int64);
    procedure SetSessionKey(const ASessionKey: String);
    procedure SetUserID(const AID: Int64);
//    procedure BeginSync(AChainName: String; AIsSystemChain: Boolean);
//    procedure StopSync(AChainName: String; AIsSystemChain: Boolean);

    //TET chain sync methods
    function GetTETChainBlockSize: Integer;
    function GetTETChainBlocksCount: Int64;
//    function GetOneChainBlock(AFrom: Int64): TOneBlockBytes;
    function GetTETChainBlocks(ASkip: Int64): TBytes;
//    function GetChainBlocks(var AAmount: Integer): TBytesBlocks; overload;
    procedure SetTETChainBlocks(ASkip: Int64; ABytes: TBytes);
//    function GetChainTransations(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
//    function GetChainLastTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
//    function GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
//      var ARows: Integer): TArray<THistoryTransactionInfo>;
//    function GetChainLastUserTransactions(AUserID: Integer;
//      var Amount: Integer): TArray<THistoryTransactionInfo>;

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


//
//    procedure UpdateLists;
//
//    function GetBlocksCount(AReqID: String): String;
//    function DoReg(AReqID: String; ASeed: String; out PubKey: String;
//      out PrKey: String; out Login: String; out Password: String;
//      out Address: String; out sPath: String): String;
//    function DoAuth(AReqID,ALogin,APassword: String): String;
//    function DoCoinsTransfer(AReqID,ASessionKey,ATo: String; AAmount: Extended): String;
//    function GetLocalTETBalance: Extended; overload;
//    function GetLocalTETBalance(ATETAddress: String): Extended; overload;
//    function DoRecoverKeys(ASeed: String; out PubKey: String;
//      out PrKey: String): String;
//
//    function DoNewToken(AReqID,ASessionKey,AFullName,AShortName,ATicker: String;
//      AAmount: Int64; ADecimals: Integer): String;
//    function GetNewTokenFee(AAmount: Int64; ADecimals: Integer): Integer;
//    function DoTokenTransfer(AReqID,AAddrTETFrom,AAddrTETTo,ASmartAddr: String;
//      AAmount: Extended; APrKey,APubKey: String): String;
//    function SendToConfirm(AReqID,AToSend: String): String;
//    function GetLocalTokensBalances: TArray<String>;
//    function GetLocalTokenBalance(ATokenID: Integer; AOwnerID: Int64): Extended;
//    function DoGetTokenBalanceWithSmartAddress(AReqID,AAddressTET,ASmartAddress: String): String;
//    function DoGetTokenBalanceWithTicker(AReqID,AAddressTET,ATicker: String): String;
//
//    function GetSmartAddressByID(AID: Int64): String;
//    function GetSmartAddressByTicker(ATicker: String): String;
//    function GetPubKeyByID(AReqID: String; AID: Int64): String;
//    function GetPubKeyBySessionKey(AReqID,ASessionKey: String): String;
    function TrySaveKeysToFile(APrivateKey: String): Boolean;
    function TryExtractPrivateKeyFromFile(out PrKey: String;
      out PubKey: String): Boolean;
//
//    function TryGetTokenICO(ATicker: String; var tICO: TTokenICODat): Boolean;
//    function GetTokensICOs(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
//    function TryGetTokenBase(ATicker: string; var sk: TCSmartKey): Boolean;
//    function TryGetTokenBaseByAddress(const AAddress: string; var sk: TCSmartKey): Boolean;

//    property DownloadRemain: Int64 read GetDownloadRemain write SetDownloadRemain;
    property SessionKey: String read GetSessionKey write SetSessionKey;
    property TETAddress: String read GetTETAddress;
    property UserID: Int64 read GetUserID write SetUserID;
  end;

var
  AppCore: IAppCore = nil;
  UI: IUI = nil;

implementation

end.
