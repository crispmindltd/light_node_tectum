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
//  Blockchain.TokenDynamic,
  Blockchain.Token.chn,
//  Blockchain.Tokens,
  Classes,
  Generics.Collections,
  IOUtils,
  Math,
  SysUtils;

type
  TBlockchain = class
  private
    FTETChain: TBlockchainTokenCHN;
    FTETDynamic: TBlockchainTETDynamic;
    FTokenICO: TBlockchainICODat;
    FSmartKey: TBlockchainSmartKey;

//      FSmartcontracts: TDictionary<String,TChainFileWorker>;
//      FDynamicBlocks: TDictionary<String,TChainFileWorker>;

//      function SmartNameByID(AID: Integer): String;
//      function SmartIDByName(AName: String): Integer;
//      function SmartNameByTicker(ATicker: String): String;
//      function SmartIDByTicker(ATicker: String): Integer;
//      function DynamicNameByID(AID: Integer): String;
  public
    constructor Create;
    destructor Destroy; override;

//      function TryGetTETAddressByOwnerID(const AOwnerID: Int64;
//        out ATETAddress: String): Boolean;
//      function TryGetCTokenBase(ATokenID: Integer; const AOwnerID: Integer;
//        out AID: Integer; var tb:TCTokensBase): Boolean;

//      function TryGetSmartKey(ATicker: String; var sk: TCSmartKey): Boolean;
//      function TryGetSmartKeyByAddress(const AAddress: String; var sk: TCSmartKey): Boolean;
//
    function GetTETChainBlockSize: Integer;
    function GetTETChainBlocksCount: Int64;
    function GetTETChainBlock(ASkip: Int64): Tbc2;
    function GetTETChainBlocks(ASkip: Int64): TBytes;
//      function GetChainBlocks(var AAmount: Integer): TBytesBlocks; overload;
    procedure SetTETChainBlocks(ASkip: Int64; ABytes: TBytes);
//      function GetChainTransactions(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
//      function GetLastChainTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
//      function GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
//        var ARows: Integer): TArray<THistoryTransactionInfo>;
    function GetTETUserLastTransactions(AUserID: Int64;
      var ANumber: Integer): TArray<THistoryTransactionInfo>;
    function TryGetTETDynamic(const AUserID: Int64; out ABlockID: Int64;
      var ATETDynamic: TTokenBase): Boolean; overload;
    function TryGetTETDynamic(const ATETAddress: String; out ABlockID: Int64;
      var ATETDynamic: TTokenBase): Boolean; overload;

    function GetICOBlocksCount: Int64;
    function GetICOBlockSize: Integer;
    function GetICOBlocks(ASkip: Int64): TBytes;
    procedure SetTokenICOBlocks(ASkip: Int64; ABytes: TBytes);
//      function GetICOsInfo(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
    function TryGetICOBlock(ASkip: Int64; var ICOBlock: TTokenICODat): Boolean; overload;
//    function TryGetICOBlock(ATicker: string; var ICOBlock: TTokenICODat): Boolean; overload;

    function GetSmartKeyBlocksCount: Int64;
    function GetSmartKeyBlockSize: Integer;
    function GetSmartKeyBlocks(ASkip: Int64): TBytes;
    procedure SetSmartKeyBlocks(ASkip: Int64; ABytes: TBytes);

//      function GetSmartsAmount: Integer;
//      function IsSmartExists(ANameAddressOrTicker: String): Boolean;
//      function GetSmartTickerByID(ASmartID: Integer): String;
////      function SmartIdNameToTicker(AIDName: String): String;
//      function SmartTickerToID(ATicker: String): Integer;
//      function SmartTickerToIDName(ATicker: String): String;
//      function GetSmartBlockSize(ASmartID: Integer): Integer;
//      function GetSmartBlocksCount(ASmartID: Integer): Integer;
//      function GetSmartBlocks(ASmartID: Integer; AFrom: Int64;
//        out AAmount: Integer): TBytesBlocks; overload;
//      function GetSmartBlocks(ASmartID: Integer;
//        out AAmount: Integer): TBytesBlocks; overload;
//      function GetSmartBlocks(ATicker: String;
//        out AAmount: Integer): TBytesBlocks; overload;
//      function GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
//      function GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
//      procedure SetSmartKeyBlocks(APos: Int64; ABytes: TBytesBlocks;
//        AAmount: Integer);
//      procedure SetSmartBlocks(ASmartID: Integer; APos: Int64; ABytes: TBytesBlocks;
//        AAmount: Integer);
//      function GetSmartTransactions(ATicker: String; ASkip: Integer;
//        var ARows: Integer): TArray<TExplorerTransactionInfo>;
//      function GetLastSmartTransactions(ATicker: String;
//        var Amount: Integer): TArray<TExplorerTransactionInfo>;
//      function GetSmartAddress(ATicker: String): String; overload;
//      function GetSmartAddress(AID: Integer): String; overload;
//      function GetLastSmartUserTransactions(AUserID: Integer; ATicker: String;
//        var AAmount: Integer): TArray<THistoryTransactionInfo>;
//
//      function GetDynBlocksCount(ADynID: Integer): Integer;
//      function GetDynBlockSize(ADynID: Integer): Integer;
//      function GetDynBlocks(ADynID: Integer; AFrom: Int64;
//        out AAmount: Integer): TBytesBlocks;
//      function GetOneChainDynBlock(AFrom: Integer; var AValue: TTokenBase): Boolean;
//      function GetOneSmartDynBlock(ASmartID: Integer; AFrom: Integer;
//        var AValue: TCTokensBase): Boolean;
//      procedure SetDynBlock(ADynID: Integer; APos: Int64; ABytes: TOneBlockBytes);
//      procedure SetDynBlocks(ADynID: Integer; APos: Int64; ABytes: TBytesBlocks;
//        AAmount: Integer);
//
//     procedure UpdateLists;
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
//var
//  ChainFileWorker: TChainFileWorker;
begin
  FTETChain := TBlockchainTokenCHN.Create;
  FTETDynamic := TBlockchainTETDynamic.Create;
  FTokenICO := TBlockchainICODat.Create;
  FSmartKey := TBlockchainSmartKey.Create;
//  FSmartcontracts := TDictionary<String,TChainFileWorker>.Create;
//  FSmartcontracts.Capacity := 100;
//
//  FDynamicBlocks := TDictionary<String,TChainFileWorker>.Create;
//  FDynamicBlocks.Capacity := 100;
//  ChainFileWorker := TBlockchainTETDynamic.Create(ConstStr.Token64FileName);
//  FDynamicBlocks.Add(ChainFileWorker.Name,ChainFileWorker);
//
//  UpdateLists;
end;

destructor TBlockchain.Destroy;
//var
//  ChainFileWorker: TChainFileWorker;
begin
  FSmartKey.Free;
  FTokenICO.Free;
  FTETDynamic.Free;
  FTETChain.Free;

//  for ChainFileWorker in FSmartcontracts.Values do
//    ChainFileWorker.Free;
//  FSmartcontracts.Free;
//
//  for ChainFileWorker in FDynamicBlocks.Values do
//    ChainFileWorker.Free;
//  FDynamicBlocks.Free;

  inherited;
end;

//function TBlockchain.DynamicNameByID(AID: Integer): String;
//begin
//  if AID <> -1 then
//    Result := Format('%d.tkn',[AID])
//  else
//    Result := ConstStr.Token64FileName;
//end;
//
//procedure TBlockchain.UpdateLists;
//var
//  smartKey: TCSmartKey;
//  fileName: String;
//  i: Integer;
//  ChainFileWorker: TChainFileWorker;
//begin
//  for i := FSmartcontracts.Count to GetSmartsAmount-1 do
//  begin
//    smartKey := GetOneSmartKeyBlock(i);
//    fileName := SmartNameByID(smartKey.SmartID);
//    if not FSmartcontracts.TryGetValue(fileName,ChainFileWorker) then
//    begin
//      ChainFileWorker := TBlockchainSmart.Create(fileName);
//      FSmartcontracts.Add(fileName,ChainFileWorker);
//    end;
//
//    fileName := DynamicNameByID(smartKey.SmartID);
//    if not FDynamicBlocks.TryGetValue(filename,ChainFileWorker) then
//    begin
//      ChainFileWorker := TBlockchainTokenDynamic.Create(fileName);
//      FDynamicBlocks.Add(fileName,ChainFileWorker);
//    end;
//  end;
//end;
//
//function TBlockchain.GetChainBlocks(var AAmount: Integer): TBytesBlocks;
//begin
//  Result := FTokenCHN.ReadBlocks(AAmount);
//end;

function TBlockchain.GetTETChainBlocksCount: Int64;
begin
  Result := FTETChain.GetBlocksCount;
end;

function TBlockchain.GetTETChainBlock(ASkip: Int64): Tbc2;
begin
  FTETChain.TryReadBlock(ASkip,Result);
end;

function TBlockchain.GetTETChainBlocks(ASkip: Int64): TBytes;
begin
  Result := FTETChain.ReadBlocksAsBytes(ASkip);
end;

function TBlockchain.GetTETChainBlockSize: Integer;
begin
  Result := FTETChain.GetBlockSize;
end;

function TBlockchain.GetTETUserLastTransactions(AUserID: Int64;
  var ANumber: Integer): TArray<THistoryTransactionInfo>;
var
  TokenID: Int64;
  TETBlock: Tbc2;
  ICODat: TTokenICODat;
  TETDynamic: TTokenBase;
  HashHex: string;
  StartBlock,i,j: Integer;
  Transaction: THistoryTransactionInfo;
begin
  Result := [];
  if not TryGetTETDynamic(AUserID,TokenID,TETDynamic) then
    exit;
  TETBlock := GetTETChainBlock(TETDynamic.LastBlock);
  if not TryGetICOBlock(TETDynamic.TokenDatID,ICODat) then
    exit;

  StartBlock := TETDynamic.StartBlock;
  i := TETDynamic.LastBlock;
  while (i > 0) and (i > StartBlock) and (Length(Result) <= ANumber) do
  begin
    TETBlock := GetTETChainBlock(i);

    if TETBlock.Smart.tkn[1].TokenID = TokenID then
		begin
      HashHex := '';
      for j := 1 to CHashLength do
        HashHex := HashHex + IntToHex(TETBlock.Hash[j],2);

      if not FTETDynamic.TryReadBlock(TETBlock.Smart.tkn[2].TokenID,TETDynamic) then
        break;
      Transaction.DateTime := TETBlock.Smart.TimeEvent;
      Transaction.BlockNum := i;
      Transaction.Value := TETBlock.Smart.Delta / Power(10,ICODat.FloatSize);
      Transaction.Hash := hashHex.ToLower;
      Transaction.Address := TETDynamic.Token;
      Transaction.Incom := False;
      Result := Result + [Transaction];
			i := TETBlock.Smart.tkn[1].FromBlock;
		end;

    if TETBlock.Smart.tkn[2].TokenID = TokenID then
		begin
      HashHex := '';
      for j := 1 to CHashLength do
        HashHex := HashHex + IntToHex(TETBlock.Hash[j],2);

      if not FTETDynamic.TryReadBlock(TETBlock.Smart.tkn[1].TokenID,TETDynamic) then
        break;
      Transaction.DateTime := TETBlock.Smart.TimeEvent;
      Transaction.BlockNum := i;
      Transaction.Value := TETBlock.Smart.Delta / Power(10,ICODat.FloatSize);
      Transaction.Hash := hashHex.ToLower;
      Transaction.Address := TETDynamic.Token;
      Transaction.Incom := False;
      Result := Result + [Transaction];
			i := TETBlock.Smart.tkn[2].FromBlock;
		end;
  end;
  ANumber := Length(Result);
end;

function TBlockchain.GetICOBlocks(ASkip: Int64): TBytes;
begin
  Result := FTokenICO.ReadBlocksAsBytes(ASkip);
end;

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
//
//function TBlockchain.GetDynBlocks(ADynID: Integer; AFrom: Int64;
//  out AAmount: Integer): TBytesBlocks;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if FDynamicBlocks.TryGetValue(DynamicNameByID(ADynID),ChainFileWorker) then
//    Result := ChainFileWorker.ReadBlocks(AFrom,AAmount);
//end;
//
//function TBlockchain.GetDynBlocksCount(ADynID: Integer): Integer;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if FDynamicBlocks.TryGetValue(DynamicNameByID(ADynID),ChainFileWorker) then
//    Result := ChainFileWorker.GetBlocksCount
//  else
//    Result := 0;
//end;
//
//function TBlockchain.GetDynBlockSize(ADynID: Integer): Integer;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if FDynamicBlocks.TryGetValue(DynamicNameByID(ADynID),ChainFileWorker) then
//    Result := ChainFileWorker.GetBlockSize
//  else
//    Result := DYNAMIC_BLOCK_SIZE_DEFAULT;
//end;

function TBlockchain.GetICOBlocksCount: Int64;
begin
  Result := FTokenICO.GetBlocksCount;
end;

function TBlockchain.GetICOBlockSize: Integer;
begin
  Result := FTokenICO.GetBlockSize;
end;

function TBlockchain.GetSmartKeyBlocks(ASkip: Int64): TBytes;
begin
  Result := FSmartKey.ReadBlocksAsBytes(ASkip);
end;

function TBlockchain.GetSmartKeyBlocksCount: Int64;
begin
  Result := FSmartKey.GetBlocksCount;
end;

function TBlockchain.GetSmartKeyBlockSize: Integer;
begin
  Result := FSmartKey.GetBlockSize;
end;

procedure TBlockchain.SetSmartKeyBlocks(ASkip: Int64; ABytes: TBytes);
begin
  FSmartKey.WriteBlocksAsBytes(ASkip,ABytes);
end;

//function TBlockchain.GetICOsInfo(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
//var
//  Blocks: TBytesBlocks;
//  ICOBytesArr: array[0..SizeOf(TTokenICODat)-1] of Byte;
//  TokenICO: TTokenICODat absolute ICOBytesArr;
//  i,count: Integer;
//begin
//  count := ARows;
//  Blocks := FTokenICO.ReadBlocks(ASkip + 2,ARows); // skip TET and TEC
//  ARows := Min(Min(ARows,count),50);
//
//  SetLength(Result,ARows);
//  for i := 0 to ARows-1 do
//  begin
//    Move(Blocks[i * SizeOf(TTokenICODat)], ICOBytesArr[0], SizeOf(TTokenICODat));
//    Result[i] := TokenICO;
//  end;
//end;
//
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
//
//function TBlockchain.GetSmartsAmount: Integer;
//begin
//  Result := FSmartKey.GetBlocksCount;
//end;
//
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
//
//function TBlockchain.IsSmartExists(ANameAddressOrTicker: string): Boolean;
//var
//  blockBytes: TOneBlockBytes;
//  TCSmartBlock: TCSmartKey absolute blockBytes;
//  i: Integer;
//begin
//  Result := False;
//  for i := 0 to FSmartKey.GetBlocksCount-1 do
//  begin
//    blockBytes := FSmartKey.GetOneBlock(i);
//    if (Trim(TCSmartBlock.Abreviature).ToUpper = ANameAddressOrTicker.ToUpper) or
//       (Trim(TCSmartBlock.key1) = ANameAddressOrTicker) then
//      Exit(True);
//  end;
//end;
//
//function TBlockchain.GetSmartBlocks(ASmartID: Integer; AFrom: Int64;
//  out AAmount: Integer): TBytesBlocks;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if ASmartID <> -1 then
//  begin
//    if not FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
//    begin
//      AAmount := -1;           //smartcontract with specified ID does not exists
//      exit;
//    end;
//
//    Result := ChainFileWorker.ReadBlocks(AFrom,AAmount);
//  end else
//    Result := FSmartKey.ReadBlocks(AFrom,AAmount);
//end;
//
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
//
//function TBlockchain.GetSmartBlocksCount(ASmartID: Integer): Integer;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
//    Result := ChainFileWorker.GetBlocksCount
//  else
//    Result := 0;
//end;
//
//function TBlockchain.GetSmartBlockSize(ASmartID: Integer): Integer;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  if ASmartID <> -1 then
//  begin
//    if FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
//      Result := ChainFileWorker.GetBlockSize
//    else
//      Result := SMART_BLOCK_SIZE_DEFAULT;
//  end else
//    Result := FSmartKey.GetBlockSize;
//end;

procedure TBlockchain.SetTETChainBlocks(ASkip: Int64; ABytes: TBytes);
var
  TETBlocks: TArray<Tbc2>;
  TotalBlocks: Int64;
  i,IncomBlocksNumber: Integer;
  TETDynamic: TTokenBase;
  NeedRefreshBalance: Boolean;
begin
  FTETChain.WriteBlocksAsBytes(ASkip,ABytes);
  IncomBlocksNumber := Length(ABytes) div FTETChain.GetBlockSize;
  TETBlocks := FTETChain.ReadBlocks(ASkip,IncomBlocksNumber);
  NeedRefreshBalance := False;

  TotalBlocks := FTETChain.GetBlocksCount;
  FTETDynamic.DoOpen(fmOpenRead or fmOpenWrite);
  for i := 0 to IncomBlocksNumber - 1 do
  begin
    FTETDynamic.TryReadBlock(TETBlocks[i].Smart.tkn[1].TokenID,TETDynamic);
    TETDynamic.LastBlock := TotalBlocks - IncomBlocksNumber + i;
    FTETDynamic.WriteBlock(TETBlocks[i].Smart.tkn[1].TokenID,TETDynamic);
    if not NeedRefreshBalance then
      NeedRefreshBalance := (AppCore.UserID = TETDynamic.OwnerID);

    FTETDynamic.TryReadBlock(TETBlocks[i].Smart.tkn[2].TokenID,TETDynamic);
    TETDynamic.LastBlock := TotalBlocks - IncomBlocksNumber + i;
    FTETDynamic.WriteBlock(TETBlocks[i].Smart.tkn[2].TokenID,TETDynamic);
    if not NeedRefreshBalance then
      NeedRefreshBalance := (AppCore.UserID = TETDynamic.OwnerID);
  end;
  FTETDynamic.DoClose;

  UI.NotifyNewTETBlocks(NeedRefreshBalance);
end;

procedure TBlockchain.SetTokenICOBlocks(ASkip: Int64; ABytes: TBytes);
var
  NewTokens: TArray<TTokenICODat>;
  i,IncomBlocksNumber: Integer;
begin
  FTokenICO.WriteBlocksAsBytes(ASkip,ABytes);
  IncomBlocksNumber := Length(ABytes) div FTokenICO.GetBlockSize;
  NewTokens := FTokenICO.ReadBlocks(ASkip,IncomBlocksNumber);
  for i := 0 to IncomBlocksNumber - 1 do
  begin
//    if NewTokens[i].OwnerID =  then

  end;
end;

function TBlockchain.TryGetICOBlock(ASkip: Int64;
  var ICOBlock: TTokenICODat): Boolean;
begin
  Result := FTokenICO.TryReadBlock(ASkip,ICOBlock);
end;

function TBlockchain.TryGetTETDynamic(const ATETAddress: string;
  out ABlockID: Int64; var ATETDynamic: TTokenBase): Boolean;
begin
  Result := FTETDynamic.TryGetByTETAddress(ATETAddress,ABlockID,ATETDynamic);
end;

function TBlockchain.TryGetTETDynamic(const AUserID: Int64;
  out ABlockID: Int64; var ATETDynamic: TTokenBase): Boolean;
begin
  Result := FTETDynamic.TryGetByUserID(AUserID,ABlockID,ATETDynamic);
end;

//procedure TBlockchain.SetDynBlock(ADynID: Integer; APos: Int64;
//  ABytes: TOneBlockBytes);
//var
//  dynName: string;
//  ChainFileWorker: TChainFileWorker;
//begin
//  dynName := DynamicNameByID(ADynID);
//  if not FDynamicBlocks.TryGetValue(dynName,ChainFileWorker) then
//  begin
//    ChainFileWorker := TBlockchainTokenDynamic.Create(dynName);
//    FDynamicBlocks.Add(dynName,ChainFileWorker);
//  end;
//
//  ChainFileWorker.WriteOneBlock(APos,ABytes);
//end;
//
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
//
//procedure TBlockchain.SetSmartKeyBlocks(APos: Int64; ABytes: TBytesBlocks;
//  AAmount: Integer);
//begin
//  FSmartKey.WriteBlocks(APos,ABytes,AAmount);
//  UpdateLists;
//end;
//
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

//function TBlockchain.TryGetSmartKey(ATicker: string;
//  var sk: TCSmartKey): Boolean;
//begin
//  Result := TBlockchainSmartKey(FSmartKey).TryGetSmartKey(ATicker, sk);
//end;
//
//function TBlockchain.TryGetSmartKeyByAddress(const AAddress: string; var sk: TCSmartKey): Boolean;
//begin
//  Result := TBlockchainSmartKey(FSmartKey).TryGetSmartKeyByAddress(AAddress, sk);
//end;
//
//function TBlockchain.TryGetTETAddressByOwnerID(const AOwnerID: Int64;
//  out ATETAddress: string): Boolean;
//var
//  ChainFileWorker: TChainFileWorker;
//begin
//  FDynamicBlocks.TryGetValue(ConstStr.Token64FileName, ChainFileWorker);
//
//  Result := TBlockchainTETDynamic(ChainFileWorker).TryGetTETAddress(AOwnerID,ATETAddress);
//end;

end.

