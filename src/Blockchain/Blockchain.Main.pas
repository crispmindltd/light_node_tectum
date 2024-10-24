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
  public
    constructor Create;
    destructor Destroy; override;

    function GetTETChainBlockSize: Integer;
    function GetTETChainBlocksCount: Integer;
    function GetTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetTETChainBlocks(ASkip: Integer; ABytes: TBytes);
    function GetTETUserLastTransactions(AUserID: Integer; ASkip,
      ARows: Integer): TArray<THistoryTransactionInfo>;
    function GetTETTransactions(ASkip: Integer;
      ARows: Integer; AFromTheEnd: Boolean): TArray<TExplorerTransactionInfo>;
    function TryGetTETChainBlock(ASkip: Integer; var ATETBlock: Tbc2): Boolean;

    function GetDynTETChainBlockSize: Integer;
    function GetDynTETChainBlocksCount: Integer;
    function GetDynTETChainBlocks(ASkip: Integer): TBytes;
    procedure SetDynTETBlocks(ASkip: Integer; ABytes: TBytes);
    function TryGetDynTETBlock(ATETAddress: string; var ABlockID: Integer;
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

    function GetSmartKeyBlockSize: Integer;
    function GetSmartKeyBlocksCount: Integer;
    function GetSmartKeyBlocks(ASkip: Integer): TBytes;
    procedure SetSmartKeyBlocks(ASkip: Integer; ABytes: TBytes);
    function GetSmartKeys(ASkip, ARows: Integer): TArray<TCSmartKey>;
    function TryGetSmartKey(ATickerOrAddress: string;
      var ASmartKey: TCSmartKey): Boolean; overload;
    function TryGetSmartKey(ATokenID: Integer;
      var ASmartKey: TCSmartKey): Boolean; overload;

    procedure UpdateTokensList;
    function GetTokenChainBlockSize: Integer;
    function GetTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetTokenChainBlocks(ATokenID: Integer; ASkip: Integer;
      ABytes: TBytes);
    function TryGetTokenChainBlock(ATokenID: Integer; ASkip: Integer;
      var ATokenBlock: TCbc4): Boolean;
    function GetTokenUserLastTransactions(ATokenID: Integer; AUserID: Integer;
      ANumber: Integer): TArray<THistoryTransactionInfo>;
    function GetTokenTransactions(ATokenID: Integer; ASkip: Integer;
      ARows: Integer; AFromTheEnd: Boolean): TArray<TExplorerTransactionInfo>;

    function GetDynTokenChainBlockSize: Integer;
    function GetDynTokenChainBlocksCount(ATokenID: Integer): Integer;
    function GetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer): TBytes;
    procedure SetDynTokenChainBlocks(ATokenID: Integer; ASkip: Integer;
      ABytes: TBytes);
    function TryGetDynTokenBlock(ATokenID: Integer; ADynTET: TTokenBase;
      var ABlockNum: Integer; out ADynToken: TCTokensBase): Boolean;

    function TryGetTETAddressByUserID(const AUserID: Integer;
      out ATETAddress: string): Boolean;
    function TryGetUserIDByTETAddress(const ATETAddress: string;
      out AUserID: Integer): Boolean;
    function SearchTransactionsByBlockNum(const ABlockNum: Integer):
      TArray<TExplorerTransactionInfo>;
    function SearchTransactionByHash(const AHash: string;
      out ATransaction: TExplorerTransactionInfo): Boolean;
    function SearchTransactionsByAddress(
      const ATETAddress: string): TArray<TExplorerTransactionInfo>;
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

function TBlockchain.TryGetUserIDByTETAddress(const ATETAddress: string;
  out AUserID: Integer): Boolean;
var
  BlockNum: Integer;
  TETDyn: TTokenBase;
begin
  Result := FTETChains.DynBlocks.TryGet(ATETAddress, BlockNum, TETDyn);
  if Result then
    AUserID := TETDyn.OwnerID;
end;

function TBlockchain.TryGetTETAddressByUserID(const AUserID: Integer;
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

function TBlockchain.GetTETUserLastTransactions(AUserID: Integer; ASkip,
  ARows: Integer): TArray<THistoryTransactionInfo>;
var
  TETBlock: Tbc2;
  ICODat: TTokenICODat;
  TETDyn: TTokenBase;
  HashHex: string;
  TokenID,StartBlockNum,i,j: Integer;
  Transaction: THistoryTransactionInfo;
begin
  Result := [];
  if not FTETChains.DynBlocks.TryGet(AUserID, TokenID, TETDyn) then
    raise EAddressNotExistsError.Create('Error Message');

  if not (FTETChains.Trans.TryGet(TETDyn.LastBlock, TETBlock) and
          FTokenICO.TryGet(TETDyn.TokenDatID, ICODat)) then
    exit;

  StartBlockNum := TETDyn.StartBlock;
  i := TETDyn.LastBlock;
  while (ASkip > 0) and (i > 0) and (i > StartBlockNum) do
  begin
    FTETChains.Trans.TryGet(i, TETBlock);  // do skipping
    if TETBlock.Smart.tkn[1].TokenID = TokenID then
		begin
      i := TETBlock.Smart.tkn[1].FromBlock;
      Dec(ASkip);
    end else
    if TETBlock.Smart.tkn[2].TokenID = TokenID then
		begin
      i := TETBlock.Smart.tkn[2].FromBlock;
      Dec(ASkip);
    end;
  end;

  while (i > 0) and (i > StartBlockNum) and (Length(Result) < ARows) do
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

function TBlockchain.GetTETTransactions(ASkip, ARows: Integer;
  AFromTheEnd: Boolean): TArray<TExplorerTransactionInfo>;
var
  TETBlocks: TArray<Tbc2>;
  TotalBlocksNum, i, j: Integer;
  HashHex: string;
  TETDyn: TTokenBase;
begin
  TETBlocks := FTETChains.Trans.ReadBlocks(ASkip, ARows, AFromTheEnd);
  TotalBlocksNum := FTETChains.Trans.GetBlocksCount;
  SetLength(Result, Length(TETBlocks));
  for i := 0 to Length(TETBlocks) - 1 do
  begin
    Result[i].DateTime := TETBlocks[i].Smart.TimeEvent;
    if AFromTheEnd then
      Result[i].BlockNum := TotalBlocksNum - ASkip - i - 1
    else
      Result[i].BlockNum := ASkip + i;

    if FTETChains.DynBlocks.TryReadBlock(
      TETBlocks[i].Smart.tkn[1].TokenID, TETDyn) then
      Result[i].TransFrom := TETDyn.Token;
    if FTETChains.DynBlocks.TryReadBlock(
      TETBlocks[i].Smart.tkn[2].TokenID, TETDyn) then
      Result[i].TransTo := TETDyn.Token;

    HashHex := '';
    for j := 1 to CHashLength do
      HashHex := HashHex + IntToHex(TETBlocks[i].Hash[j], 2);
    Result[i].Hash := HashHex.ToLower;
    Result[i].Ticker := 'TET';
    Result[i].FloatSize := 8;
    Result[i].Amount := TETBlocks[i].Smart.Delta / 100000000;
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

function TBlockchain.SearchTransactionByHash(const AHash: string;
  out ATransaction: TExplorerTransactionInfo): Boolean;
var
  TETBlock: Tbc2;
  TokenBlock: TCbc4;
  BlockNum, TokenID: Integer;
  TokenBase: TTokenBase;
  CTokensBase: TCTokensBase;
  TokenChainsPair: TTokenChainsPair;
  TokenICO: TTokenICODat;
  AddressesDict: TDictionary<Integer, string>;
begin
  Result := FTETChains.Trans.TryGet(AHash, BlockNum, TETBlock);
  if Result then
  begin
    ATransaction.DateTime := TETBlock.Smart.TimeEvent;
    ATransaction.BlockNum := BlockNum;
    ATransaction.Hash := AHash;
    if FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[1].TokenID, TokenBase) then
      ATransaction.TransFrom := TokenBase.Token
    else
      ATransaction.TransFrom := '';
    if FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[2].TokenID, TokenBase) then
      ATransaction.TransTo := TokenBase.Token
    else
      ATransaction.TransTo := '';
    ATransaction.FloatSize := 8;
    ATransaction.Amount := TETBlock.Smart.Delta / Power(10, ATransaction.FloatSize);
    ATransaction.Ticker := 'TET';
  end else
  begin
    AddressesDict := TDictionary<Integer, string>.Create(2);
    try
      for TokenID in FTokensChains.Keys do
      begin
        TokenChainsPair := FTokensChains[TokenID];
        Result := TokenChainsPair.Trans.TryGet(AHash, BlockNum, TokenBlock);
        if Result then
        begin
          AddressesDict.Clear;
          TokenChainsPair.DynBlocks.TryReadBlock(
            TokenBlock.Smart.tkn[1].TokenID, CTokensBase);
          AddressesDict.AddOrSetValue(CTokensBase.OwnerID, '');
          TokenChainsPair.DynBlocks.TryReadBlock(
            TokenBlock.Smart.tkn[2].TokenID, CTokensBase);
          AddressesDict.AddOrSetValue(CTokensBase.OwnerID, '');
          FTETChains.DynBlocks.GetTETAddresses(AddressesDict);

          ATransaction.DateTime := TokenBlock.Smart.TimeEvent;
          ATransaction.BlockNum := BlockNum;
          ATransaction.Hash := AHash;
          if TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[1].TokenID,
            CTokensBase) then
            ATransaction.TransFrom := AddressesDict[CTokensBase.OwnerID];
          if TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[2].TokenID,
            CTokensBase) then
            ATransaction.TransTo := AddressesDict[CTokensBase.OwnerID];
          FTokenICO.TryGet(TokenID, TokenICO);
          ATransaction.Amount := TokenBlock.Smart.Delta / Power(10, TokenICO.FloatSize);
          ATransaction.FloatSize := TokenICO.FloatSize;
          ATransaction.Ticker := TokenICO.Abreviature;
          break;
        end
      end;
    finally
      AddressesDict.Free;
    end;
  end;
end;

function TBlockchain.SearchTransactionsByAddress(
  const ATETAddress: string): TArray<TExplorerTransactionInfo>;
var
  i, j, TransCount, TokenID, UserID: Integer;
  TokenChainsPair: TTokenChainsPair;
  TETBlock: Tbc2;
  TokenBlock: TCbc4;
  TETBaseFrom, TETBaseTo: TTokenBase;
  TokenBaseFrom, TokenBaseTo: TCTokensBase;
  TokenICO: TTokenICODat;
  Transaction: TExplorerTransactionInfo;
  UserIDStr: string;
  AddressesDict: TDictionary<Integer, string>;
begin
  Result := [];
  FTETChains.Trans.DoOpen;
  FTETChains.DynBlocks.DoOpen;
  TryGetUserIDByTETAddress(ATETAddress, UserID);
  try
    for i := 0 to FTETChains.Trans.GetBlocksCount - 1 do
    begin
      FTETChains.Trans.TryGet(i, TETBlock);
      if (FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[1].TokenID,
        TETBaseFrom) and (ATETAddress = TETBaseFrom.Token)) or
        (FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[2].TokenID,
        TETBaseTo) and (ATETAddress = TETBaseTo.Token)) then
      begin
        Transaction.DateTime := TETBlock.Smart.TimeEvent;
        Transaction.BlockNum := i;
        Transaction.Hash := '';
        for j := 1 to TokenLength do
          Transaction.Hash := Transaction.Hash + IntToHex(TETBlock.Hash[j], 2).ToLower;
        Transaction.TransFrom := TETBaseFrom.Token;
        Transaction.TransTo := TETBaseTo.Token;
        Transaction.Amount := TETBlock.Smart.Delta / Power(10, 8);
        Transaction.FloatSize := 8;
        Transaction.Ticker := 'TET';
        Result := Result + [Transaction];
      end;
    end;
    TransCount := Length(Result);
  finally
    FTETChains.DynBlocks.DoClose;
    FTETChains.Trans.DoClose;
  end;
  AddressesDict := TDictionary<Integer, string>.Create(300);
  AddressesDict.AddOrSetValue(UserID, ATETAddress);
  try
    for TokenID in FTokensChains.Keys do
    begin
      TokenChainsPair := FTokensChains[TokenID];
      TokenChainsPair.Trans.DoOpen;
      TokenChainsPair.DynBlocks.DoOpen;
      try
        for i := 0 to TokenChainsPair.Trans.GetBlocksCount - 1 do
        begin
          TokenChainsPair.Trans.TryGet(i, TokenBlock);
          if (TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[1].TokenID,
            TokenBaseFrom) and (UserID = TokenBaseFrom.OwnerID)) or
            (TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[2].TokenID,
            TokenBaseTo) and (UserID = TokenBaseTo.OwnerID)) then
          begin
            if not AddressesDict.ContainsKey(TokenBaseFrom.OwnerID) then
              AddressesDict.AddOrSetValue(TokenBaseFrom.OwnerID, '');
            if not AddressesDict.ContainsKey(TokenBaseTo.OwnerID) then
              AddressesDict.AddOrSetValue(TokenBaseTo.OwnerID, '');
            Transaction.TransFrom := TokenBaseFrom.OwnerID.ToString;
            Transaction.TransTo := TokenBaseTo.OwnerID.ToString;

            Transaction.DateTime := TokenBlock.Smart.TimeEvent;
            Transaction.BlockNum := i;

            Transaction.Hash := '';
            for j := 1 to CHashLength do
              Transaction.Hash := Transaction.Hash + IntToHex(TokenBlock.Hash[j], 2).ToLower;

            Transaction.TransFrom := TokenBaseFrom.OwnerID.ToString;
            Transaction.TransTo := TokenBaseTo.OwnerID.ToString;
            FTokenICO.TryGet(TokenID, TokenICO);
            Transaction.FloatSize := TokenICO.FloatSize;
            Transaction.Amount := TokenBlock.Smart.Delta / Power(10, TokenICO.FloatSize);
            Transaction.Ticker := TokenICO.Abreviature;
            Result := Result + [Transaction];
          end
        end;
        if AddressesDict.ContainsValue('') then
          FTETChains.DynBlocks.GetTETAddresses(AddressesDict);
        for i := TransCount to Length(Result) - 1 do
        begin
          UserIDStr := Result[i].TransFrom;
          Result[i].TransFrom := AddressesDict[UserIDStr.ToInteger];
          UserIDStr := Result[i].TransTo;
          Result[i].TransTo := AddressesDict[UserIDStr.ToInteger];
        end;
        TransCount := Length(Result);
      finally
        TokenChainsPair.DynBlocks.DoClose;
        TokenChainsPair.Trans.DoClose;
      end;
    end;
  finally
    AddressesDict.Free;
  end;
end;

function TBlockchain.SearchTransactionsByBlockNum(
  const ABlockNum: Integer): TArray<TExplorerTransactionInfo>;
var
  Transaction: TExplorerTransactionInfo;
  TETBlock: Tbc2;
  TokenBlock: TCbc4;
  i: Integer;
  TokenID: Integer;
  TokenBase: TTokenBase;
  CTokensBase: TCTokensBase;
  TokenChainsPair: TTokenChainsPair;
  TokenICO: TTokenICODat;
  AddressesDict: TDictionary<Integer, string>;
begin
  Result := [];
  if FTETChains.Trans.TryGet(ABlockNum, TETBlock) then
  begin
    Transaction.DateTime := TETBlock.Smart.TimeEvent;
    Transaction.BlockNum := ABlockNum;
    Transaction.Hash := '';
    for i := 1 to TokenLength do
      Transaction.Hash := Transaction.Hash + IntToHex(TETBlock.Hash[i], 2).ToLower;
    if FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[1].TokenID, TokenBase) then
      Transaction.TransFrom := TokenBase.Token
    else
      Transaction.TransFrom := '';
    if FTETChains.DynBlocks.TryReadBlock(TETBlock.Smart.tkn[2].TokenID, TokenBase) then
      Transaction.TransTo := TokenBase.Token
    else
      Transaction.TransTo := '';
    Transaction.FloatSize := 8;
    Transaction.Amount := TETBlock.Smart.Delta / Power(10, Transaction.FloatSize);
    Transaction.Ticker := 'TET';
    Result := Result + [Transaction];
  end;
  AddressesDict := TDictionary<Integer, string>.Create((FTokensChains.Count + 1) * 2);
  try
    for TokenID in FTokensChains.Keys do
    begin
      TokenChainsPair := FTokensChains[TokenID];
      if TokenChainsPair.Trans.TryGet(ABlockNum, TokenBlock) then
      begin
        AddressesDict.Clear;
        TokenChainsPair.DynBlocks.TryReadBlock(
          TokenBlock.Smart.tkn[1].TokenID, CTokensBase);
        AddressesDict.AddOrSetValue(CTokensBase.OwnerID, '');
        TokenChainsPair.DynBlocks.TryReadBlock(
          TokenBlock.Smart.tkn[2].TokenID, CTokensBase);
        AddressesDict.AddOrSetValue(CTokensBase.OwnerID, '');
        FTETChains.DynBlocks.GetTETAddresses(AddressesDict);

        Transaction.DateTime := TokenBlock.Smart.TimeEvent;
        Transaction.BlockNum := ABlockNum;
        Transaction.Hash := '';
        for i := 1 to CHashLength do
          Transaction.Hash := Transaction.Hash + IntToHex(TokenBlock.Hash[i], 2).ToLower;
        if TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[1].TokenID,
          CTokensBase) then
          Transaction.TransFrom := AddressesDict[CTokensBase.OwnerID];
        if TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[2].TokenID,
          CTokensBase) then
          Transaction.TransTo := AddressesDict[CTokensBase.OwnerID];
        FTokenICO.TryGet(TokenID, TokenICO);
        Transaction.Amount := TokenBlock.Smart.Delta / Power(10, TokenICO.FloatSize);
        Transaction.FloatSize := TokenICO.FloatSize;
        Transaction.Ticker := TokenICO.Abreviature;
        Result := Result + [Transaction];
      end
    end;
  finally
    AddressesDict.Free;
  end;
end;

procedure TBlockchain.SetDynTETBlocks(ASkip: Integer; ABytes: TBytes);
begin
  FTETChains.DynBlocks.WriteBlocksAsBytes(ASkip, ABytes);
end;

function TBlockchain.TryGetDynTETBlock(ATETAddress: string; var ABlockID: Integer;
  out ADynTET: TTokenBase): Boolean;
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
    UI.NotifyNewToken(CSmartKey);
  end;
end;

function TBlockchain.GetSmartKeys(ASkip, ARows: Integer): TArray<TCSmartKey>;
begin
  Result := FSmartKey.ReadBlocks(ASkip, ARows);
end;

function TBlockchain.TryGetSmartKey(ATickerOrAddress: string;
  var ASmartKey: TCSmartKey): Boolean;
begin
  Result := FSmartKey.TryGet(ATickerOrAddress, ASmartKey);
end;

function TBlockchain.TryGetSmartKey(ATokenID: Integer;
  var ASmartKey: TCSmartKey): Boolean;
begin
  Result := FSmartKey.TryGet(ATokenID, ASmartKey);
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
  SmartKey: TCSmartKey;
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
    TryGetSmartKey(ATokenID, SmartKey);
    UI.NotifyNewTokenBlocks(SmartKey, CurrentUserNewTransaction);
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

function TBlockchain.GetTokenUserLastTransactions(ATokenID: Integer;
  AUserID: Integer; ANumber: Integer): TArray<THistoryTransactionInfo>;
var
  TokenChainsPair: TTokenChainsPair;
  TokenBlock: TCbc4;
  ICODat: TTokenICODat;
  TokenDyn: TCTokensBase;
  TETAddr, HashHex: string;
  BlockID, StartBlockNum, i, j: Integer;
  Transaction: THistoryTransactionInfo;
begin
  Result := [];
  if not (FTokensChains.TryGetValue(ATokenID, TokenChainsPair) and
          TokenChainsPair.DynBlocks.TryGet(AUserID, BlockID, TokenDyn) and
          TokenChainsPair.Trans.TryGet(TokenDyn.LastBlock, TokenBlock) and
          FTokenICO.TryGet(ATokenID, ICODat)) then
    exit;

  StartBlockNum := TokenDyn.StartBlock;
  i := TokenDyn.LastBlock;
  while (i > 0) and (i > StartBlockNum) and (Length(Result) <= ANumber) do
  begin
    TokenChainsPair.Trans.TryGet(i, TokenBlock);
    if TokenBlock.Smart.tkn[1].TokenID = BlockID then
		begin
      Transaction.DateTime := TokenBlock.Smart.TimeEvent;
      Transaction.BlockNum := i;
      Transaction.Value := TokenBlock.Smart.Delta / Power(10, ICODat.FloatSize);
      HashHex := '';
      for j := 1 to CHashLength do
        HashHex := HashHex + IntToHex(TokenBlock.Hash[j], 2);
      Transaction.Hash := HashHex.ToLower;
      TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[2].TokenID, TokenDyn);
      if TryGetTETAddressByUserID(TokenDyn.OwnerID, TETAddr) then
        Transaction.Address := TETAddr;
      Transaction.Incom := False;
      Result := Result + [Transaction];
			i := TokenBlock.Smart.tkn[1].FromBlock;
		end else
    if TokenBlock.Smart.tkn[2].TokenID = BlockID then
		begin
      Transaction.DateTime := TokenBlock.Smart.TimeEvent;
      Transaction.BlockNum := i;
      Transaction.Value := TokenBlock.Smart.Delta / Power(10, ICODat.FloatSize);
      HashHex := '';
      for j := 1 to CHashLength do
        HashHex := HashHex + IntToHex(TokenBlock.Hash[j],2);
      Transaction.Hash := HashHex.ToLower;
      TokenChainsPair.DynBlocks.TryReadBlock(TokenBlock.Smart.tkn[1].TokenID, TokenDyn);
      if TryGetTETAddressByUserID(TokenDyn.OwnerID, TETAddr) then
        Transaction.Address := TETAddr;
      Transaction.Incom := True;
      Result := Result + [Transaction];
			i := TokenBlock.Smart.tkn[2].FromBlock;
		end;
  end;
end;

function TBlockchain.GetTokenTransactions(ATokenID, ASkip, ARows: Integer;
  AFromTheEnd: Boolean): TArray<TExplorerTransactionInfo>;
var
  TokenChainsPair: TTokenChainsPair;
  TokenBlocks: TArray<TCbc4>;
  TotalBlocksNum, i, j: Integer;
  AddressesDict: TDictionary<Integer, string>;
  HashHex: string;
  CTokensBase: TCTokensBase;
  TokenICO: TTokenICODat;
begin
  Result := [];
  if not (FTokensChains.TryGetValue(ATokenID, TokenChainsPair) and
          FTokenICO.TryGet(ATokenID, TokenICO)) then
    exit;

  TokenBlocks := TokenChainsPair.Trans.ReadBlocks(ASkip, ARows, AFromTheEnd);
  TotalBlocksNum := TokenChainsPair.Trans.GetBlocksCount;
  SetLength(Result, Length(TokenBlocks));
  AddressesDict := TDictionary<Integer, string>.Create(Length(TokenBlocks) * 2);
  try
    for i := 0 to Length(Result) - 1 do
    begin
      TokenChainsPair.DynBlocks.TryReadBlock(
        TokenBlocks[i].Smart.tkn[1].TokenID, CTokensBase);
      AddressesDict.AddOrSetValue(CTokensBase.OwnerID, '');
      TokenChainsPair.DynBlocks.TryReadBlock(
        TokenBlocks[i].Smart.tkn[2].TokenID, CTokensBase);
      AddressesDict.AddOrSetValue(CTokensBase.OwnerID, '');
    end;
    FTETChains.DynBlocks.GetTETAddresses(AddressesDict);
    for i := 0 to Length(Result) - 1 do
    begin
      Result[i].DateTime := TokenBlocks[i].Smart.TimeEvent;
      if AFromTheEnd then
        Result[i].BlockNum := TotalBlocksNum - ASkip - i - 1
      else
        Result[i].BlockNum := ASkip + i;

      TokenChainsPair.DynBlocks.TryReadBlock(
        TokenBlocks[i].Smart.tkn[1].TokenID, CTokensBase);
      Result[i].TransFrom := AddressesDict[CTokensBase.OwnerID];
      TokenChainsPair.DynBlocks.TryReadBlock(
        TokenBlocks[i].Smart.tkn[2].TokenID, CTokensBase);
      Result[i].TransTo := AddressesDict[CTokensBase.OwnerID];

      HashHex := '';
      for j := 1 to CHashLength do
        HashHex := HashHex + IntToHex(TokenBlocks[i].Hash[j], 2);
      Result[i].Hash := HashHex.ToLower;

      Result[i].FloatSize := TokenICO.FloatSize;
      Result[i].Amount := TokenBlocks[i].Smart.Delta / Power(10, Result[i].FloatSize);
      Result[i].Ticker := TokenICO.Abreviature;
    end;
  finally
    AddressesDict.Free;
  end;
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
  ADynTET: TTokenBase; var ABlockNum: Integer; out ADynToken: TCTokensBase): Boolean;
var
  TokenChainsPair: TTokenChainsPair;
begin
  Result := False;
  if FTokensChains.TryGetValue(ATokenID, TokenChainsPair) then
    Result := TokenChainsPair.DynBlocks.TryGet(ADynTET.OwnerID, ABlockNum, ADynToken);
end;

end.

