unit Blockchain.Main;

interface

uses
  App.Constants,
  App.Exceptions,
  App.Intf,
  Blockchain.BaseTypes,
  Blockchain.ICODat,
  Blockchain.Intf,
  Blockchain.SmartKey,
  Blockchain.TETDynamic,
  Blockchain.TokenDynamic,
  Blockchain.TET,
  Blockchain.Token,
  Classes,
  Generics.Collections,
  IOUtils,
  Math,
  SysUtils;

type
  TTETChainsPair = record
    Trans: TBlockchainTET;
    DynBlocks: TBlockchainTETDynamic;
  end;
  TTokenChainsPair = record
    Trans: TBlockchainToken;
    DynBlocks: TBlockchainTokenDynamic;
  end;

  TBlockchain = class
  private
    FTETChains: TTETChainsPair;
    FTokenICO: TBlockchainICODat;
    FSmartKey: TBlockchainSmartKey;
    FTokensChains: TDictionary<Integer, TTokenChainsPair>;

//      function SmartNameByID(AID: Integer): string;
//      function SmartIDByName(AName: string): Integer;
//      function SmartNameByTicker(ATicker: string): string;
//      function SmartIDByTicker(ATicker: string): Integer;
//      function DynamicNameByID(AID: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;

//      function TryGetCTokenBase(ATokenID: Integer; const AOwnerID: Integer;
//        out AID: Integer; var tb:TCTokensBase): Boolean;
//      function TryGetSmartKeyByAddress(const AAddress: string; var sk: TCSmartKey): Boolean;

    function GetTETChainBlockSize: Integer;
    function GetTETChainBlocksCount: Integer;
    function GetTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetTETChainBlocks(ASkip: Integer; ABytes: TBytes);
    function GetTETUserLastTransactions(AUserID: Integer;
      ANumber: Integer): TArray<THistoryTransactionInfo>;
    function TryGetTETChainBlock(ASkip: Integer; var ATETBlock: Tbc2): Boolean;

    function GetDynTETChainBlockSize: Integer;
    function GetDynTETChainBlocksCount: Integer;
    function GetDynTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetDynTETBlocks(ASkip: Integer; ABytes: TBytes);
//      function GetOneChainDynBlock(AFrom: Integer; var AValue: TTokenBase): Boolean;
//      function GetOneSmartDynBlock(ASmartID: Integer; AFrom: Integer;
//        var AValue: TCTokensBase): Boolean;
//      procedure SetDynBlock(ADynID: Integer; APos: Int64; ABytes: TOneBlockBytes);
//      procedure SetDynBlocks(ADynID: Integer; APos: Int64; ABytes: TBytesBlocks;
//        AAmount: Integer);
    function TryGetDynTETBlock(const ATETAddress: string; out ABlockID: Integer;
      out ADynTET: TTokenBase): Boolean;

    function GetICOBlockSize: Integer;
    function GetICOBlocksCount: Integer;
    function GetICOBlocks(ASkip: Integer): TBytes;
    procedure SetICOBlocks(ASkip: Integer; ABytes: TBytes);
    function GetTokenICOs(ASkip, ARows: Integer): TArray<TTokenICODat>;
    function TryGetICOBlock(ASkip: Integer;
      var AICOBlock: TTokenICODat): Boolean; overload;
    function TryGetICOBlock(ATicker: string;
      var AICOBlock: TTokenICODat): Boolean; overload;

//      function GetChainTransactions(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
//      function GetLastChainTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
//      function GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
//        var ARows: Integer): TArray<THistoryTransactionInfo>;

    function GetSmartKeyBlockSize: Integer;
    function GetSmartKeyBlocksCount: Integer;
    function GetSmartKeyBlocks(ASkip: Integer): TBytes;
    procedure SetSmartKeyBlocks(ASkip: Integer; ABytes: TBytes);
    function GetSmartKeys(ASkip, ARows: Integer): TArray<TCSmartKey>;
    function TryGetSmartKey(ATicker: string; var ASmartKey: TCSmartKey): Boolean;

    procedure UpdateTokensList;
    function GetTokenChainBlockSize: Integer;
    function GetTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetTokenChainBlocks(ATokenID: Integer; ASkip: Integer;
      ABytes: TBytes);
    function TryGetTokenChainBlock(ATokenID: Integer; ASkip: Integer;
      var ATokenBlock: TCbc4): Boolean;

    function GetDynTokenChainBlockSize: Integer;
    function GetDynTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer;
      ABytes: TBytes);
    function TryGetDynTokenBlock(ATokenID: Integer; const ATETAddress: string;
      out ABlockID: Integer; out ADynToken: TCTokensBase): Boolean;
//      function GetSmartTickerByID(ASmartID: Integer): string;
////      function SmartIdNameToTicker(AIDName: string): string;
//      function SmartTickerToID(ATicker: string): Integer;
//      function SmartTickerToIDName(ATicker: string): string;

//      function GetSmartBlocks(ASmartID: Integer;
//        out AAmount: Integer): TBytesBlocks; overload;
//      function GetSmartBlocks(ATicker: string;
//        out AAmount: Integer): TBytesBlocks; overload;
//      function GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
//      function GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
//      function GetSmartTransactions(ATicker: string; ASkip: Integer;
//        var ARows: Integer): TArray<TExplorerTransactionInfo>;
//      function GetLastSmartTransactions(ATicker: string;
//        var Amount: Integer): TArray<TExplorerTransactionInfo>;
//      function GetSmartAddress(ATicker: string): string; overload;
//      function GetSmartAddress(AID: Integer): string; overload;
//      function GetLastSmartUserTransactions(AUserID: Integer; ATicker: string;
//        var AAmount: Integer): TArray<THistoryTransactionInfo>;

    function TryGetTETAddressByOwnerID(const AUserID: Integer;
      out ATETAddress: string): Boolean;
  end;

implementation

function SortCompare(AList: TStringList; Index1,
  Index2: Integer): Integer;
begin
  Result := Length(AList[Index1]) - Length(AList[Index2]);
  if Result = 0 then
    Result := AnsiCompareText(AList[Index1],AList[Index2]);
end;

{ TBlockchain }

constructor TBlockchain.Create;
begin
  FTETChains.Trans := TBlockchainTET.Create;
  FTetChains.DynBlocks := TBlockchainTETDynamic.Create;
  FTokenICO := TBlockchainICODat.Create;
  FSmartKey := TBlockchainSmartKey.Create;
  FTokensChains := TDictionary<Integer, TTokenChainsPair>.Create(30);
  UpdateTokensList;
end;

destructor TBlockchain.Destroy;
var
  TokenChainsPair: TTokenChainsPair;
begin
  for TokenChainsPair in FTokensChains.Values do
  begin
    TokenChainsPair.DynBlocks.Free;
    TokenChainsPair.Trans.Free;
  end;
  FTokensChains.Free;
  FSmartKey.Free;
  FTokenICO.Free;
  FTetChains.DynBlocks.Free;
  FTETChains.Trans.Free;

  inherited;
end;

function TBlockchain.TryGetTETAddressByOwnerID(const AUserID: Integer;
  out ATETAddress: string): Boolean;
var
  BlockNum: Integer;
  TETDyn: TTokenBase;
begin
  Result := FTETChains.DynBlocks.TryGet(AUserID, BlockNum, TETDyn);
  if Result then
    ATETAddress := TETDyn.Token;
end;

function TBlockchain.GetTETChainBlockSize: Integer;
begin
  Result := FTETChains.Trans.GetBlockSize;
end;

function TBlockchain.GetTETChainBlocksCount: Integer;
begin
  Result := FTETChains.Trans.GetBlocksCount;
end;

function TBlockchain.TryGetTETChainBlock(ASkip: Integer;
  var ATETBlock: Tbc2): Boolean;
begin
  Result := FTETChains.Trans.TryGet(ASkip, ATETBlock);
end;

function TBlockchain.GetTETChainBlocks(ASkip: Integer): TBytes;
begin
  Result := FTETChains.Trans.ReadBlocksAsBytes(ASkip);
end;

procedure TBlockchain.SetTETChainBlocks(ASkip: Integer; ABytes: TBytes);
var
  NeedClose: Boolean;
  NewBlockBytes: array[0..SizeOf(Tbc2) - 1] of Byte;
  NewBlock: Tbc2 absolute NewBlockBytes;
  TotalBlocks, NewBlocksNumber, i: Integer;
  TETDynBlock: TTokenBase;
  CurrentUserNewTransaction: Boolean;
begin
  FTETChains.Trans.WriteBlocksAsBytes(ASkip, ABytes);

  CurrentUserNewTransaction := False;
  TotalBlocks := FTETChains.Trans.GetBlocksCount;
  NewBlocksNumber := Length(ABytes) div GetTETChainBlockSize;
  NeedClose := FTETChains.DynBlocks.DoOpen;
  try
    for i := 0 to NewBlocksNumber - 1 do
    begin
      Move(ABytes[i * GetTETChainBlockSize], NewBlockBytes[0],
        GetTETChainBlockSize);

      if FTETChains.DynBlocks.TryReadBlock(NewBlock.Smart.tkn[1].TokenID, TETDynBlock) then
      begin
        TETDynBlock.LastBlock := TotalBlocks - NewBlocksNumber + i;
        FTETChains.DynBlocks.WriteBlock(NewBlock.Smart.tkn[1].TokenID, TETDynBlock);
        if not CurrentUserNewTransaction then
          CurrentUserNewTransaction := TETDynBlock.OwnerID = AppCore.UserID;
      end;
      if FTETChains.DynBlocks.TryReadBlock(NewBlock.Smart.tkn[2].TokenID, TETDynBlock) then
      begin
        TETDynBlock.LastBlock := TotalBlocks - NewBlocksNumber + i;
        FTETChains.DynBlocks.WriteBlock(NewBlock.Smart.tkn[2].TokenID, TETDynBlock);
        if not CurrentUserNewTransaction then
          CurrentUserNewTransaction := TETDynBlock.OwnerID = AppCore.UserID;
      end;
    end;
  finally
    if NeedClose then
      FTETChains.DynBlocks.DoClose;
    UI.NotifyNewTETBlocks(CurrentUserNewTransaction);
  end;
end;

function TBlockchain.GetTETUserLastTransactions(AUserID: Integer;
  ANumber: Integer): TArray<THistoryTransactionInfo>;
var
  TETBlock: Tbc2;
  ICODat: TTokenICODat;
  TETDyn: TTokenBase;
  HashHex: string;
  TokenID,StartBlockNum,i,j: Integer;
  Transaction: THistoryTransactionInfo;
begin
  Result := [];
  if not (FTETChains.DynBlocks.TryGet(AUserID, TokenID, TETDyn) and
          FTETChains.Trans.TryGet(TETDyn.LastBlock, TETBlock) and
          FTokenICO.TryGet(TETDyn.TokenDatID,ICODat)) then
    exit;

  StartBlockNum := TETDyn.StartBlock;
  i := TETDyn.LastBlock;
  while (i > 0) and (i > StartBlockNum) and (Length(Result) <= ANumber) do
  begin
    FTETChains.Trans.TryGet(i, TETBlock);
    if TETBlock.Smart.tkn[1].TokenID = TokenID then
		begin
      Transaction.DateTime := TETBlock.Smart.TimeEvent;
      Transaction.BlockNum := i;
      Transaction.Value := TETBlock.Smart.Delta / Power(10, ICODat.FloatSize);
      HashHex := '';
      for j := 1 to CHashLength do
        HashHex := HashHex + IntToHex(TETBlock.Hash[j], 2);
      Transaction.Hash := HashHex.ToLower;
      FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[2].TokenID, TETDyn);
      Transaction.Address := TETDyn.Token;
      Transaction.Incom := False;
      Result := Result + [Transaction];
			i := TETBlock.Smart.tkn[1].FromBlock;
		end else
    if TETBlock.Smart.tkn[2].TokenID = TokenID then
		begin
      Transaction.DateTime := TETBlock.Smart.TimeEvent;
      Transaction.BlockNum := i;
      Transaction.Value := TETBlock.Smart.Delta / Power(10, ICODat.FloatSize);
      HashHex := '';
      for j := 1 to CHashLength do
        HashHex := HashHex + IntToHex(TETBlock.Hash[j],2);
      Transaction.Hash := HashHex.ToLower;
      FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[1].TokenID, TETDyn);
      Transaction.Address := TETDyn.Token;
      Transaction.Incom := True;
      Result := Result + [Transaction];
			i := TETBlock.Smart.tkn[2].FromBlock;
		end;
  end;
end;

function TBlockchain.GetDynTETChainBlockSize: Integer;
begin
  Result := FTETChains.DynBlocks.GetBlockSize;
end;

function TBlockchain.GetDynTETChainBlocksCount: Integer;
begin
  Result := FTETChains.DynBlocks.GetBlocksCount;
end;

function TBlockchain.GetDynTETChainBlocks(ASkip: Integer): TBytes;
begin
  Result := FTETChains.DynBlocks.ReadBlocksAsBytes(ASkip);
end;

procedure TBlockchain.SetDynTETBlocks(ASkip: Integer; ABytes: TBytes);
begin
  FTETChains.DynBlocks.WriteBlocksAsBytes(ASkip, ABytes);
end;

function TBlockchain.TryGetDynTETBlock(const ATETAddress: string;
  out ABlockID: Integer; out ADynTET: TTokenBase): Boolean;
begin
  Result := FTETChains.DynBlocks.TryGet(ATETAddress, ABlockID, ADynTET);
end;

function TBlockchain.GetICOBlockSize: Integer;
begin
  Result := FTokenICO.GetBlockSize;
end;

function TBlockchain.GetICOBlocksCount: Integer;
begin
  Result := FTokenICO.GetBlocksCount;
end;

function TBlockchain.GetICOBlocks(ASkip: Integer): TBytes;
begin
  Result := FTokenICO.ReadBlocksAsBytes(ASkip);
end;

procedure TBlockchain.SetICOBlocks(ASkip: Integer; ABytes: TBytes);
begin
  FTokenICO.WriteBlocksAsBytes(ASkip, ABytes);
end;

function TBlockchain.GetTokenICOs(ASkip, ARows: Integer): TArray<TTokenICODat>;
begin
  Result := FTokenICO.ReadBlocks(ASkip, ARows);
end;

function TBlockchain.TryGetICOBlock(ASkip: Integer;
  var AICOBlock: TTokenICODat): Boolean;
begin
  Result := FTokenICO.TryGet(ASkip, AICOBlock);
end;

function TBlockchain.TryGetICOBlock(ATicker: string;
  var AICOBlock: TTokenICODat): Boolean;
begin
  Result := FTokenICO.TryGet(ATicker, AICOBlock);
end;

function TBlockchain.GetSmartKeyBlockSize: Integer;
begin
  Result := FSmartKey.GetBlockSize;
end;

function TBlockchain.GetSmartKeyBlocksCount: Integer;
begin
  Result := FSmartKey.GetBlocksCount;
end;

function TBlockchain.GetSmartKeyBlocks(ASkip: Integer): TBytes;
begin
  Result := FSmartKey.ReadBlocksAsBytes(ASkip);
end;

procedure TBlockchain.SetSmartKeyBlocks(ASkip: Integer; ABytes: TBytes);
var
  CSmartKeyBytes: array[0..SizeOf(TCSmartKey) - 1] of Byte;
  CSmartKey: TCSmartKey absolute CSmartKeyBytes;
  i: Integer;
begin
  FSmartKey.WriteBlocksAsBytes(ASkip, ABytes);

  UpdateTokensList;
  for i := 0 to (Length(ABytes) div SizeOf(TCSmartKey)) - 1 do
  begin
    Move(ABytes[i * SizeOf(TCSmartKey)], CSmartKeyBytes[0], SizeOf(TCSmartKey));
    AppCore.AddTokenToSynchronize(CSmartKey.SmartID);
    UI.NotifyNewToken(CSmartKey.Abreviature, CSmartKey.SmartID);
  end;
end;

function TBlockchain.GetSmartKeys(ASkip, ARows: Integer): TArray<TCSmartKey>;
begin
  Result := FSmartKey.ReadBlocks(ASkip, ARows);
end;

function TBlockchain.TryGetSmartKey(ATicker: string;
  var ASmartKey: TCSmartKey): Boolean;
begin
  Result := FSmartKey.TryGetSmartKey(ATicker, ASmartKey);
end;

procedure TBlockchain.UpdateTokensList;
var
  SmartKeyBlock: TCSmartKey;
  TokenChainsPair: TTokenChainsPair;
begin
  for SmartKeyBlock in FSmartKey.ReadBlocks(FTokensChains.Count) do
  begin
    TokenChainsPair.Trans := TBlockchainToken.Create(SmartKeyBlock.SmartID);
    TokenChainsPair.DynBlocks := TBlockchainTokenDynamic.Create(SmartKeyBlock.SmartID);

    FTokensChains.Add(SmartKeyBlock.SmartID, TokenChainsPair);
  end;
end;

function TBlockchain.GetTokenChainBlockSize: Integer;
begin
  Result := SizeOf(TCbc4);
end;

function TBlockchain.GetTokenChainBlocksCount(ATokenID: Integer): Integer;
var
  TokenChainsPair: TTokenChainsPair;
begin
  if FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    Result := TokenChainsPair.Trans.GetBlocksCount
  else
    Result := 0;
end;

function TBlockchain.GetTokenChainBlocks(ATokenID: Integer;
  ASkip: Integer): TBytes;
var
  TokenChainsPair: TTokenChainsPair;
begin
  Result := [];
  if FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    Result := TokenChainsPair.Trans.ReadBlocksAsBytes(ASkip);
end;

procedure TBlockchain.SetTokenChainBlocks(ATokenID: Integer; ASkip: Integer;
  ABytes: TBytes);
var
  TokenChainsPair: TTokenChainsPair;
  NeedClose: Boolean;
  NewBlockBytes: array[0..SizeOf(TCbc4) - 1] of Byte;
  NewBlock: TCbc4 absolute NewBlockBytes;
  TotalBlocks, NewBlocksNumber, i: Integer;
  TokenDynBlock: TCTokensBase;
  CurrentUserNewTransaction: Boolean;
begin
  if not FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    exit;
  TokenChainsPair.Trans.WriteBlocksAsBytes(ASkip, ABytes);

  CurrentUserNewTransaction := False;
  TotalBlocks := TokenChainsPair.Trans.GetBlocksCount;
  NewBlocksNumber := Length(ABytes) div GetTokenChainBlockSize;
  NeedClose := TokenChainsPair.DynBlocks.DoOpen;
  try
    for i := 0 to NewBlocksNumber - 1 do
    begin
      Move(ABytes[i * GetTokenChainBlockSize], NewBlockBytes[0],
        GetTokenChainBlockSize);

      if TokenChainsPair.DynBlocks.TryReadBlock(NewBlock.Smart.tkn[1].TokenID,
        TokenDynBlock) then
      begin
        TokenDynBlock.LastBlock := TotalBlocks - NewBlocksNumber + i;
        TokenChainsPair.DynBlocks.WriteBlock(NewBlock.Smart.tkn[1].TokenID,
          TokenDynBlock);
        if not CurrentUserNewTransaction then
          CurrentUserNewTransaction := TokenDynBlock.OwnerID = AppCore.UserID;
      end;
      if TokenChainsPair.DynBlocks.TryReadBlock(NewBlock.Smart.tkn[2].TokenID,
        TokenDynBlock) then
      begin
        TokenDynBlock.LastBlock := TotalBlocks - NewBlocksNumber + i;
        TokenChainsPair.DynBlocks.WriteBlock(NewBlock.Smart.tkn[2].TokenID,
          TokenDynBlock);
        if not CurrentUserNewTransaction then
          CurrentUserNewTransaction := TokenDynBlock.OwnerID = AppCore.UserID;
      end;
    end;
  finally
    if NeedClose then
      TokenChainsPair.DynBlocks.DoClose;
//    UI.NotifyNewTETBlocks(CurrentUserNewTransaction);
  end;
end;

function TBlockchain.TryGetTokenChainBlock(ATokenID: Integer; ASkip: Integer;
  var ATokenBlock: TCbc4): Boolean;
var
  TokenChainsPair: TTokenChainsPair;
begin
  Result := False;
  if FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    Result := TokenChainsPair.Trans.TryGet(ASkip, ATokenBlock);
end;

function TBlockchain.GetDynTokenChainBlockSize: Integer;
begin
  Result := SizeOf(TCTokensBase);
end;

function TBlockchain.GetDynTokenChainBlocksCount(ATokenID: Integer): Integer;
var
  TokenChainsPair: TTokenChainsPair;
begin
  if FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    Result := TokenChainsPair.DynBlocks.GetBlocksCount
  else
    Result := 0;
end;

function TBlockchain.GetDynTokenChainBlocks(ATokenID: Integer;
  ASkip: Integer): TBytes;
var
  TokenChainsPair: TTokenChainsPair;
begin
  Result := [];
  if FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    Result := TokenChainsPair.DynBlocks.ReadBlocksAsBytes(ASkip);
end;

procedure TBlockchain.SetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer;
  ABytes: TBytes);
var
  TokenChainsPair: TTokenChainsPair;
begin
  if FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    TokenChainsPair.DynBlocks.WriteBlocksAsBytes(ASkip, ABytes);
end;

function TBlockchain.TryGetDynTokenBlock(ATokenID: Integer;
  const ATETAddress: string; out ABlockID: Integer;
  out ADynToken: TCTokensBase): Boolean;
var
  TokenChainsPair: TTokenChainsPair;
  DynTET: TTokenBase;
begin
  Result := False;
  if TryGetDynTETBlock(ATETAddress, ABlockID, DynTET) and
     FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    Result := TokenChainsPair.DynBlocks.TryGet(DynTET.OwnerID-1, ABlockID, ADynToken);
end;

//function TBlockchain.DynamicNameByID(AID: Integer): string;
//begin
//  if AID <> -1 then
//    Result := Format('%d.tkn',[AID])
//  else
//    Result := ConstStr.Token64FileName;
//end;

//function TBlockchain.GetChainTransactions(ASkip: Integer;
//  var ARows: Integer): TArray<TExplorerTransactionInfo>;
//var
//  Bytes: TBytesBlocks;
//  TCbc2Arr: array[0..SizeOf(Tbc2)-1] of Byte;
//  bc2: Tbc2 absolute TCbc2Arr;
//  i,j,count: Integer;
//  hashHex: string;
//  tb: TTokenBase;
//begin
//  count := ARows;
//  Bytes := FTokenCHN.ReadBlocks(ASkip,ARows);
//  ARows := Min(Min(ARows,count),50);
//
//  SetLength(Result,ARows);
//  for i := 0 to ARows-1 do
//  begin
//    Move(Bytes[i*SizeOf(bc2)],TCbc2Arr[0],SizeOf(bc2));
//
//    Result[i].DateTime := bc2.Smart.TimeEvent;
//    Result[i].BlockNum := ASkip + i;
//
//    if GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) then
//      Result[i].TransFrom := tb.Token;
//    if GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) then
//      Result[i].TransTo := tb.Token;
//
//    hashHex := '';
//    for j := 1 to CHashLength do
//      hashHex := hashHex + IntToHex(bc2.Hash[j],2);
//    Result[i].Hash := hashHex.ToLower;
//
//    Result[i].Amount := bc2.Smart.Delta / 100000000;
//  end;
//end;
//
//function TBlockchain.GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
//  var ARows: Integer): TArray<THistoryTransactionInfo>;
//var
//  oneBlock1: TOneBlockBytes;
//  bc2: Tbc2 absolute oneBlock1;
//  tICO: TTokenICODat;
//  tb: TTokenBase;
//  hashHex: string;
//  TokenID,startBlock,i,j: Integer;
//  transaction: THistoryTransactionInfo;
//begin
//  Result := [];
//  if not TryGetTETTokenBase(AUserID,TokenID,tb) then exit;
//  oneBlock1 := GetOneChainBlock(tb.LastBlock);
//  if not TryGetOneICOBlock(tb.TokenDatID,tICO) then exit;
//
//  startBlock := tb.StartBlock;
//  i := tb.LastBlock;
//  while (ASkip > 0) and (i > 0) and (i > StartBlock) do
//  begin
//    oneBlock1 := GetOneChainBlock(i);  // do skipping
//    if bc2.Smart.tkn[1].TokenID = TokenID then
//    begin
//      i := bc2.Smart.tkn[1].FromBlock;
//      Dec(ASkip);
//    end else
//    if bc2.Smart.tkn[2].TokenID = TokenID then
//    begin
//      i := bc2.Smart.tkn[2].FromBlock;
//      Dec(ASkip);
//    end;
//  end;
//
//  while (i > 0) and (i > StartBlock) and (Length(Result) < ARows) do
//  begin
//    oneBlock1 := GetOneChainBlock(i);
//    if bc2.Smart.tkn[1].TokenID = TokenID then
//    begin
//      hashHex := '';
//      for j := 1 to CHashLength do
//        hashHex := hashHex + IntToHex(bc2.Hash[j],2);
//
//      if not GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) then break;
//      transaction.DateTime := bc2.Smart.TimeEvent;
//      transaction.BlockNum := i;
//      transaction.Amount := bc2.Smart.Delta/Power(10,tICO.FloatSize);
//      transaction.Hash := hashHex.ToLower;
//      transaction.Address := tb.Token;
//      transaction.Incom := False;
//      Result := Result + [transaction];
//      i := bc2.Smart.tkn[1].FromBlock;
//    end;
//
//    if bc2.Smart.tkn[2].TokenID = TokenID then
//    begin
//      hashHex := '';
//      for j := 1 to CHashLength do
//      hashHex := hashHex + IntToHex(bc2.Hash[j],2);
//
//      if not GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) then break;
//      transaction.DateTime := bc2.Smart.TimeEvent;
//      transaction.BlockNum := i;
//      transaction.Amount := bc2.Smart.Delta/Power(10,tICO.FloatSize);
//      transaction.Hash := hashHex.ToLower;
//      transaction.Address := tb.Token;
//      transaction.Incom := True;
//      Result := Result + [transaction];
//      i := bc2.Smart.tkn[2].FromBlock;
//    end;
//  end;
//  ARows := Length(Result);
//end;

//function TBlockchain.GetLastChainTransactions(
//  var Amount: Integer): TArray<TExplorerTransactionInfo>;
//var
//  Bytes: TOneBlockBytes;
//  bc2: Tbc2 absolute Bytes;
//  i,j: Integer;
//  hashHex: string;
//  tb: TTokenBase;
//  transaction: TExplorerTransactionInfo;
//begin
//  Result := [];
//  i := GetChainBlocksCount-1;
//  while (i > 0) and (Length(Result) < Amount) do
//  begin
//    try
//      Bytes := FTokenCHN.GetOneBlock(i);
//
//      transaction.DateTime := bc2.Smart.TimeEvent;
//      transaction.BlockNum := GetChainBlocksCount-Amount+i;
//
//      if GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) and (tb.TokenDatID = 1) then
//        transaction.TransFrom := tb.Token
//      else
//        continue;
//
//      if GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) and (tb.TokenDatID = 1) then
//        transaction.TransTo := tb.Token
//      else
//        continue;
//
//      hashHex := '';
//      for j := 1 to CHashLength do
//        hashHex := hashHex + IntToHex(bc2.Hash[j],2);
//      transaction.Hash := hashHex.ToLower;
//
//      transaction.Amount := bc2.Smart.Delta / 100000000;
//
//      Result := Result + [transaction];
//    finally
//      Dec(i);
//    end;
//  end;
//  Amount := Length(Result);
//end;
//
//function TBlockchain.GetLastSmartTransactions(ATicker: string;
//  var Amount: Integer): TArray<TExplorerTransactionInfo>;
//var
//  ChainFileWorker: TChainFileWorker;
//  Bytes: TBytesBlocks;
//  i,j,dynID: Integer;
//  hashHex: string;
//  TCbc4Arr: array[0..SizeOf(TCbc4)-1] of Byte;
//  bc4: TCbc4 absolute TCbc4Arr;
//  tcb: TCTokensBase;
//  tICO: TTokenICODat;
//begin
//  if not FSmartcontracts.TryGetValue(SmartNameByTicker(ATicker),ChainFileWorker)
//    then exit;
//
//  Bytes := ChainFileWorker.ReadBlocks(Amount);
//  SetLength(Result,Amount);
//  for i := Amount-1 downto 0 do
//  begin
//    Move(Bytes[i*SizeOf(bc4)],TCbc4Arr[0],SizeOf(bc4));
//
//    Result[Amount-i-1].DateTime := bc4.Smart.TimeEvent;
//    dynID := SmartIDByTicker(ATicker);
//    Result[Amount-i-1].BlockNum := GetSmartBlocksCount(dynID)-Amount+i;
//
//    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[1].TokenID,tcb) then
//      Result[Amount-i-1].TransFrom := tcb.Token;
//    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[2].TokenID,tcb) then
//      Result[Amount-i-1].TransTo := tcb.Token;
//
//    hashHex := '';
//    for j := 1 to CHashLength do
//      hashHex := hashHex + IntToHex(bc4.Hash[j],2);
//    Result[Amount-i-1].Hash := hashHex.ToLower;
//
//    if TryGetOneICOBlock(ATicker,tICO) then
//      Result[Amount-i-1].Amount := bc4.Smart.Delta/Power(10,tICO.FloatSize);
//  end;
//end;
//
//function TBlockchain.GetLastSmartUserTransactions(AUserID: Integer;
//  ATicker: string; var AAmount: Integer): TArray<THistoryTransactionInfo>;
//var
//  sk: TCSmartKey;
//  bc4: TCbc4;
//  tICO: TTokenICODat;
//  tcb: TCTokensBase;
//  hashHex: string;
//  TokenID,startBlock,i,j: Integer;
//  transaction: THistoryTransactionInfo;
//begin
//  Result := [];
//  try
//    if not TryGetSmartKey(ATicker,sk) then exit;
//    if not TryGetCTokenBase(sk.SmartID,AUserID,TokenID,tcb) then exit;
//    bc4 := GetOneSmartBlock(sk.SmartID,tcb.LastBlock);
//    if not TryGetOneICOBlock(ATicker,tICO) then exit;
//
//    startBlock := tcb.StartBlock;
//    i := tcb.LastBlock;
//    while (i > 0) and (i > StartBlock) and (Length(Result) <= AAmount) do
//    begin
//      bc4 := GetOneSmartBlock(sk.SmartID,i);
//
//      if bc4.Smart.tkn[1].TokenID = TokenID then
//      begin
//        hashHex := '';
//        for j := 1 to CHashLength do
//          hashHex := hashHex + IntToHex(bc4.Hash[j],2);
//
//        if not GetOneSmartDynBlock(sk.SmartID,bc4.Smart.tkn[2].TokenID,tcb) then break;
//        transaction.DateTime := bc4.Smart.TimeEvent;
//        transaction.BlockNum := i;
//        transaction.Amount := bc4.Smart.Delta/Power(10,tICO.FloatSize);
//        transaction.Hash := hashHex.ToLower;
//        transaction.Address := tcb.Token;
//        transaction.Incom := False;
//        Result := Result + [transaction];
//        i := bc4.Smart.tkn[1].FromBlock;
//      end;
//
//      if bc4.Smart.tkn[2].TokenID = TokenID then
//      begin
//        hashHex := '';
//        for j := 1 to CHashLength do
//          hashHex := hashHex + IntToHex(bc4.Hash[j],2);
//
//        if not GetOneSmartDynBlock(sk.SmartID,bc4.Smart.tkn[1].TokenID,tcb) then break;
//        transaction.DateTime := bc4.Smart.TimeEvent;
//        transaction.BlockNum := i;
//        transaction.Amount := bc4.Smart.Delta/Power(10,tICO.FloatSize);
//        transaction.Hash := hashHex.ToLower;
//        transaction.Address := tcb.Token;
//        transaction.Incom := True;
//        Result := Result + [transaction];
//        i := bc4.Smart.tkn[2].FromBlock;
//      end;
//    end;
//  finally
//    AAmount := Length(Result);
//  end;
//end;

//function TBlockchain.GetOneChainDynBlock(AFrom: Integer; var AValue: TTokenBase): Boolean;
//var
//  ChainFileWorker: TChainFileWorker;
//  OneBlock: TOneBlockBytes;
//  tb: TTokenBase absolute OneBlock;
//begin
//  FDynamicBlocks.TryGetValue(ConstStr.Token64FileName, ChainFileWorker);
//  if (ChainFileWorker.GetBlocksCount <= AFrom) or (AFrom < 0) then
//    Exit(False)
//  else
//    Result := True;
//
//  OneBlock := ChainFileWorker.GetOneBlock(AFrom);
//  AValue := tb;
//end;

//function TBlockchain.GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
//var
//  ChainFileWorker: TChainFileWorker;
//  blockBytes: TOneBlockBytes;
//  TCbc4Block: TCbc4 absolute blockBytes;
//begin
//  if not FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
//    exit;
//
//  blockBytes := ChainFileWorker.GetOneBlock(AFrom);
//  Result := TCbc4Block;
//end;
//
//function TBlockchain.GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
//var
//  blockBytes: TOneBlockBytes;
//  TCSmartBlock: TCSmartKey absolute blockBytes;
//begin
//  blockBytes := FSmartKey.GetOneBlock(AFrom);
//  Result := TCSmartBlock;
//end;
//
//function TBlockchain.GetOneSmartDynBlock(ASmartID: Integer; AFrom: Integer;
//  var AValue: TCTokensBase): Boolean;
//var
//  ChainFileWorker: TChainFileWorker;
//  OneBlock: TOneBlockBytes;
//  tcb: TCTokensBase absolute OneBlock;
//begin
//  Result := False;
//  if not FDynamicBlocks.TryGetValue(DynamicNameByID(ASmartID),ChainFileWorker) then exit;
//  if (ChainFileWorker.GetBlocksCount <= AFrom) or (AFrom < 0) then exit;
//
//  OneBlock := ChainFileWorker.GetOneBlock(AFrom);
//  AValue := tcb;
//  Result := True;
//end;

//function TBlockchain.GetSmartTickerByID(ASmartID: Integer): string;
//var
//  blockBytes: TOneBlockBytes;
//  TCSmartBlock: TCSmartKey absolute blockBytes;
//  i: Integer;
//begin
//  for i := 0 to FSmartKey.GetBlocksCount-1 do
//  begin
//    blockBytes := FSmartKey.GetOneBlock(i);
//    if TCSmartBlock.SmartID = ASmartID then
//      Exit(Trim(TCSmartBlock.Abreviature).ToUpper);
//  end;
//end;
//
//function TBlockchain.GetSmartTransactions(ATicker: string; ASkip: Integer;
//  var ARows: Integer): TArray<TExplorerTransactionInfo>;
//var
//  ChainFileWorker: TChainFileWorker;
//  Bytes: TBytesBlocks;
//  i,j,dynID,count: Integer;
//  hashHex: string;
//  TCbc4Arr: array[0..SizeOf(TCbc4)-1] of Byte;
//  bc4: TCbc4 absolute TCbc4Arr;
//  tcb: TCTokensBase;
//  tICO: TTokenICODat;
//begin
//  if not FSmartcontracts.TryGetValue(SmartNameByTicker(ATicker),ChainFileWorker)
//    then raise ESmartNotExistsError.Create('');
//
//  count := ARows;
//  Bytes := ChainFileWorker.ReadBlocks(ASkip,ARows);
//  ARows := Min(Min(ARows,count),50);
//
//  SetLength(Result,ARows);
//  for i := 0 to ARows-1 do
//  begin
//    Move(Bytes[i*SizeOf(bc4)],TCbc4Arr[0],SizeOf(bc4));
//
//    Result[i].DateTime := bc4.Smart.TimeEvent;
//    dynID := SmartIDByTicker(ATicker);
//    Result[i].BlockNum := ASkip + i;
//
//    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[1].TokenID,tcb) then
//      Result[i].TransFrom := tcb.Token;
//    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[2].TokenID,tcb) then
//      Result[i].TransTo := tcb.Token;
//
//    hashHex := '';
//    for j := 1 to CHashLength do
//      hashHex := hashHex + IntToHex(bc4.Hash[j],2);
//    Result[i].Hash := hashHex.ToLower;
//
//    if TryGetOneICOBlock(ATicker,tICO) then
//      Result[i].Amount := bc4.Smart.Delta/Power(10,tICO.FloatSize);
//  end;
//end;

//function TBlockchain.GetSmartBlocks(ASmartID: Integer;
//  out AAmount: Integer): TBytesBlocks;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if ASmartID <> -1 then
//  begin
//    if not FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
//    begin
//      AAmount := -1;
//      exit;
//    end;
//
//    Result := ChainFileWorker.ReadBlocks(AAmount);
//  end else
//    Result := FSmartKey.ReadBlocks(AAmount);
//end;
//
//function TBlockchain.GetSmartBlocks(ATicker: string; out AAmount: Integer): TBytesBlocks;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if not FSmartcontracts.TryGetValue(SmartNameByTicker(ATicker),ChainFileWorker) then
//  begin
//    AAmount := -1;           //smartcontract with specified ID does not exists
//    exit;
//  end;
//
//   Result := ChainFileWorker.ReadBlocks(AAmount);
//end;
//
//function TBlockchain.GetSmartAddress(AID: Integer): string;
//var
//  TCSmartBlock: TCSmartKey;
//  i: Integer;
//begin
//  Result := '';
//  for i := 0 to FSmartKey.GetBlocksCount-1 do
//  begin
//    TCSmartBlock := GetOneSmartKeyBlock(i);
//    if TCSmartBlock.SmartID = AID then
//      Exit(Trim(TCSmartBlock.key1));
//  end;
//end;
//
//function TBlockchain.GetSmartAddress(ATicker: string): string;
//var
//  TCSmartBlock: TCSmartKey;
//  i: Integer;
//begin
//  Result := '';
//  for i := 0 to FSmartKey.GetBlocksCount-1 do
//  begin
//    TCSmartBlock := GetOneSmartKeyBlock(i);
//    if Trim(TCSmartBlock.Abreviature).Equals(ATicker.ToUpper) then
//      Exit(Trim(TCSmartBlock.key1));
//  end;
//end;

//procedure TBlockchain.SetTETChainBlocks(ASkip: Int64; ABytes: TBytes);
//var
//  TETBlocks: TArray<Tbc2>;
//  TotalBlocks: Int64;
//  i,IncomBlocksNumber: Integer;
//  TETDynamic: TTokenBase;
//  NeedRefreshBalance: Boolean;
//begin
//  FTETChain.WriteBlocksAsBytes(ASkip,ABytes);
//  IncomBlocksNumber := Length(ABytes) div FTETChain.GetBlockSize;
//  TETBlocks := FTETChain.ReadBlocks(ASkip,IncomBlocksNumber);
//  NeedRefreshBalance := False;
//
//  TotalBlocks := FTETChain.GetBlocksCount;
//  FTETDynamic.DoOpen;
//  for i := 0 to IncomBlocksNumber - 1 do
//  begin
//    FTETDynamic.TryReadBlock(TETBlocks[i].Smart.tkn[1].TokenID,TETDynamic);
//    TETDynamic.LastBlock := TotalBlocks - IncomBlocksNumber + i;
//    FTETDynamic.WriteBlock(TETBlocks[i].Smart.tkn[1].TokenID,TETDynamic);
//    if not NeedRefreshBalance then
//      NeedRefreshBalance := (AppCore.UserID = TETDynamic.OwnerID);
//
//    FTETDynamic.TryReadBlock(TETBlocks[i].Smart.tkn[2].TokenID,TETDynamic);
//    TETDynamic.LastBlock := TotalBlocks - IncomBlocksNumber + i;
//    FTETDynamic.WriteBlock(TETBlocks[i].Smart.tkn[2].TokenID,TETDynamic);
//    if not NeedRefreshBalance then
//      NeedRefreshBalance := (AppCore.UserID = TETDynamic.OwnerID);
//  end;
//  FTETDynamic.DoClose;
//
//  UI.NotifyNewTETBlocks(NeedRefreshBalance);
//end;

//procedure TBlockchain.SetDynBlocks(ADynID: Integer; APos: Int64;
//  ABytes: TBytesBlocks; AAmount: Integer);
//var
//  dynName: string;
//  ChainFileWorker: TChainFileWorker;
//begin
//  dynName := DynamicNameByID(ADynID);
//  if FDynamicBlocks.TryGetValue(dynName,ChainFileWorker) then
//    ChainFileWorker.WriteBlocks(APos,ABytes,AAMount);
//
//  if (ADynID = -1) and (AppCore.DownloadRemain > 0) then
//  begin
//    AppCore.DownloadRemain := -AAmount;
//    UI.ShowDownloadProgress;
//  end;
//end;

//procedure TBlockchain.SetSmartBlocks(ASmartID: Integer; APos: Int64;
//  ABytes: TBytesBlocks; AAmount: Integer);
//var
//  name: string;
//  ChainFileWorker: TChainFileWorker;
//
//  i,bAmount: Integer;
//  bc4Arr: TOneBlockBytes;
//  bc4: TCbc4 absolute bc4Arr;
//  tbArr: TOneBlockBytes;
//  tcb: TCTokensBase absolute tbArr;
//begin
//  name := SmartNameByID(ASmartID);
//  if not FSmartcontracts.TryGetValue(name,ChainFileWorker) then exit;
//
//  ChainFileWorker.WriteBlocks(APos,ABytes,AAmount);
//  bAmount := ChainFileWorker.GetBlocksCount;
//  for i := 0 to AAmount-1 do
//  begin
//    Move(ABytes[i*SizeOf(bc4)],bc4Arr[0],SizeOf(bc4));
//
//    if GetOneSmartDynBlock(ASmartID,bc4.Smart.tkn[1].TokenID,tcb) then
//    begin
//      tcb.LastBlock := bAmount-AAmount+i;
//      SetDynBlock(ASmartID,bc4.Smart.tkn[1].TokenID,tbArr);
//    end;
//
//    if GetOneSmartDynBlock(ASmartID,bc4.Smart.tkn[2].TokenID,tcb) then
//    begin
//      tcb.LastBlock := bAmount-AAmount+i;
//      SetDynBlock(ASmartID,bc4.Smart.tkn[2].TokenID,tbArr);
//    end;
//  end;
//  UI.NotifyNewSmartBlocks;
//end;

//function TBlockchain.SmartIDByName(AName: string): Integer;
//begin
//  Result := AName.Replace('.chn','').ToInteger;
//end;
//
//function TBlockchain.SmartIDByTicker(ATicker: string): Integer;
//begin
//  Result := SmartIDByName(SmartNameByTicker(ATicker));
//end;
//
////function TBlockchain.SmartIdNameToTicker(AIDName: string): string;
////var
////  blockBytes: TOneBlockBytes;
////  TCSmartBlock: TCSmartKey absolute blockBytes;
////  i: Integer;
////begin
////  for i := 0 to GetSmartBlocksCount(-1)-1 do
////  begin
////    blockBytes := GetOneSmartBlock(-1,i);
////    if TCSmartBlock.SmartID = SmartIDByName(AIDName) then
////      Exit(Trim(TCSmartBlock.Abreviature).ToUpper);
////  end;
////end;
//
//function TBlockchain.SmartNameByID(AID: Integer): string;
//begin
//  Result := Format('%d.chn',[AID]);
//end;
//
//function TBlockchain.SmartNameByTicker(ATicker: string): string;
//var
//  block: TCSmartKey;
//  i: Integer;
//begin
//  Result := '';
//  for i := 0 to GetSmartsAmount-1 do
//  begin
//    block := GetOneSmartKeyBlock(i);
//    if Trim(block.Abreviature) = ATicker then
//      Exit(SmartNameByID(block.SmartID));
//  end;
//end;
//
//function TBlockchain.SmartTickerToID(ATicker: string): Integer;
//var
//  block: TCSmartKey;
//  i: Integer;
//begin
//  Result := -1;
//  for i := 0 to GetSmartBlocksCount(-1)-1 do
//  begin
//    block := GetOneSmartKeyBlock(i);
//    if Trim(block.Abreviature) = ATicker then
//      Exit(block.SmartID);
//  end;
//end;
//
//function TBlockchain.SmartTickerToIDName(ATicker: string): string;
//begin
//  Result := SmartNameByID(SmartTickerToID(ATicker));
//end;
//
//function TBlockchain.TryGetCTokenBase(ATokenID: Integer; const AOwnerID: Integer;
//  out AID: Integer; var tb: TCTokensBase): Boolean;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  Result := False;
//  if not FDynamicBlocks.TryGetValue(DynamicNameByID(ATokenID),ChainFileWorker) then
//    exit;
//
//  Result := TBlockchainTokenDynamic(ChainFileWorker).TryGetTokenBase(AOwnerID,AID,tb);
//end;


//function TBlockchain.TryGetSmartKeyByAddress(const AAddress: string; var sk: TCSmartKey): Boolean;
//begin
//  Result := TBlockchainSmartKey(FSmartKey).TryGetSmartKeyByAddress(AAddress, sk);
//end;

end.

