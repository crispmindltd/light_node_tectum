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
    procedure AddNewChain(const AName: String; AIsSystemChain: Boolean);
    function IsChainNeedSync(const AName: String): Boolean;
    procedure ShowTotalCountBlocksDownloadRemain;
    procedure ShowDownloadProgress;
    procedure NotifyNewChainBlocks;
    procedure NotifyNewSmartBlocks;
  end;

  IAppCore = interface
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
    function GetChainLastTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
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
//    function GetSmartBlocks(ASmartName: String;
//      var AAmount: Integer): TBytesBlocks; overload;
    function GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
    function GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
    procedure SetSmartBlocks(ASmartID: Integer; APos: Int64; ABytes: TBytesBlocks;
      AAmount: Integer);
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
    function DoCoinsTransfer(AReqID,ASessionKey,ATo: String; AAmount: Extended): String;
    function GetLocalTETBalance: Extended; overload;
    function GetLocalTETBalance(ATETAddress: String): Extended; overload;
    function DoRecoverKeys(ASeed: String; out PubKey: String;
      out PrKey: String): String;

    function DoGetCoinsTransfersHistory(ASessionKey: String;
      ALastAmount: Integer): String;
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

    property DownloadRemain: Int64 read GetDownloadRemain write SetDownloadRemain;
    property SessionKey: String read GetSessionKey write SetSessionKey;
    property TETAddress: String read GetTETAddress;
    property UserID: Int64 read GetUserID write SetUserID;
  end;

var
  AppCore: IAppCore = nil;
  UI: IUI = nil;

implementation

end.
