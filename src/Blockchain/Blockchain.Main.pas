unit Blockchain.Main;

interface

uses
  App.Constants,
  App.Exceptions,
  App.Intf,
  Blockchain.BaseTypes,
  Blockchain.ICODat,
  Blockchain.Intf,
  Blockchain.Smartcontracts,
  Blockchain.SmartKey,
  Blockchain.TETDynamic,
  Blockchain.TokenDynamic,
  Blockchain.Token.chn,
  Classes,
  Generics.Collections,
  IOUtils,
  Math,
  SysUtils;

type
  TBlockchain = class
    private
      FTokenCHN: TChainFileWorker;
      FSmartKey: TChainFileWorker;
      FTokenICO: TChainFileWorker;
      FSmartcontracts: TDictionary<String,TChainFileWorker>;
      FDynamicBlocks: TDictionary<String,TChainFileWorker>;

      function SmartNameByID(AID: Integer): String;
      function SmartIDByName(AName: String): Integer;
      function SmartNameByTicker(ATicker: String): String;
      function SmartIDByTicker(ATicker: String): Integer;
      function DynamicNameByID(AID: Integer): String;
    public
      constructor Create;
      destructor Destroy; override;

      function TryGetTETAddressByOwnerID(const AOwnerID: Int64;
        out ATETAddress: String): Boolean;
      function TryGetTETTokenBase(const AOwnerID: Int64; out AID: Integer;
        var tb:TTokenBase): Boolean; overload;
      function TryGetTETTokenBase(const ATETAddress: String; out AID: Integer;
        var tb:TTokenBase): Boolean; overload;
      function TryGetCTokenBase(ATokenID: Integer; const AOwnerID: Integer;
        out AID: Integer; var tb:TCTokensBase): Boolean; overload;
      function TryGetCTokenBase(ATokenID: Integer; const ATETAddress: String;
        out AID: Integer; var tb:TCTokensBase): Boolean; overload;
      function TryGetOneICOBlock(AFrom: Int64; var ICOBlock: TTokenICODat): Boolean; overload;
      function TryGetOneICOBlock(ATicker: String; var ICOBlock: TTokenICODat): Boolean; overload;
      function TryGetSmartKey(ATicker: String; var sk: TCSmartKey): Boolean;
      function TryGetSmartKeyByAddress(const AAddress: String; var sk: TCSmartKey): Boolean;
      function SearchTransactionByHash(const AHash: string;
        out ATransaction: TExplorerTransactionInfo): Boolean;
      function SearchTransactionsByBlockNum(const ABlockNum: Integer):
        TArray<TExplorerTransactionInfo>;
      function SearchTransactionsByAddress(const AAddress: string):
        TArray<TExplorerTransactionInfo>;

      function GetChainBlockSize: Integer;
      function GetChainBlocksCount: Integer;
      function GetOneChainBlock(AFrom: Int64): TOneBlockBytes;
      function GetChainBlocks(AFrom: Int64; out AAmount: Integer): TBytesBlocks; overload;
      function GetChainBlocks(var AAmount: Integer): TBytesBlocks; overload;
      procedure SetChainBlocks(APos: Int64; ABytes: TBytesBlocks;
        AAmount: Integer);
      function GetChainTransactions(ASkip: Integer; var ARows: Integer): TArray<TExplorerTransactionInfo>;
      function GetLastChainTransactions(var Amount: Integer): TArray<TExplorerTransactionInfo>;
      function GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
        var ARows: Integer): TArray<THistoryTransactionInfo>;
      function GetLastChainUserTransactions(AUserID: Integer;
        var AAmount: Integer): TArray<THistoryTransactionInfo>;

      function GetSmartsAmount: Integer;
      function IsSmartExists(ANameAddressOrTicker: String): Boolean;
      function GetSmartTickerByID(ASmartID: Integer): String;
//      function SmartIdNameToTicker(AIDName: String): String;
      function SmartTickerToID(ATicker: String): Integer;
      function SmartTickerToIDName(ATicker: String): String;
      function GetSmartBlockSize(ASmartID: Integer): Integer;
      function GetSmartBlocksCount(ASmartID: Integer): Integer;
      function GetSmartBlocks(ASmartID: Integer; AFrom: Int64;
        out AAmount: Integer): TBytesBlocks; overload;
      function GetSmartBlocks(ASmartID: Integer;
        out AAmount: Integer): TBytesBlocks; overload;
      function GetSmartBlocks(ATicker: String;
        out AAmount: Integer): TBytesBlocks; overload;
      function GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
      function GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
      procedure SetSmartKeyBlocks(APos: Int64; ABytes: TBytesBlocks;
        AAmount: Integer);
      procedure SetSmartBlocks(ASmartID: Integer; APos: Int64; ABytes: TBytesBlocks;
        AAmount: Integer);
      function GetSmartTransactions(ATicker: String; ASkip: Integer;
        var ARows: Integer): TArray<TExplorerTransactionInfo>;
      function GetLastSmartTransactions(ATicker: String;
        var Amount: Integer): TArray<TExplorerTransactionInfo>;
      function GetSmartAddress(ATicker: String): String; overload;
      function GetSmartAddress(AID: Integer): String; overload;
      function TryGetSmartID(ATickerOrAddr: String; out ASmartID: Integer): Boolean;
      function GetLastSmartUserTransactions(AUserID: Integer; ATicker: String;
        var AAmount: Integer): TArray<THistoryTransactionInfo>;

      function GetDynBlocksCount(ADynID: Integer): Integer;
      function GetDynBlockSize(ADynID: Integer): Integer;
      function GetDynBlocks(ADynID: Integer; AFrom: Int64;
        out AAmount: Integer): TBytesBlocks;
      function GetOneChainDynBlock(AFrom: Integer; var AValue: TTokenBase): Boolean;
      function GetOneSmartDynBlock(ASmartID: Integer; AFrom: Integer;
        var AValue: TCTokensBase): Boolean;
      procedure SetDynBlock(ADynID: Integer; APos: Int64; ABytes: TOneBlockBytes);
      procedure SetDynBlocks(ADynID: Integer; APos: Int64; ABytes: TBytesBlocks;
        AAmount: Integer);

      function GetICOBlocksCount: Integer;
      function GetICOBlockSize: Integer;
      function GetICOBlocks(AFrom: Int64;
        out AAmount: Integer): TBytesBlocks;
      procedure SetICOBlocks(APos: Int64; ABytes: TBytesBlocks;
        AAmount: Integer);
      function GetICOsInfo(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;

     procedure UpdateLists;
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
var
  ChainFileWorker: TChainFileWorker;
begin
  FTokenCHN := TBlockchainTokenCHN.Create(ConstStr.TokenCHNFileName);
  FSmartKey := TBlockchainSmartkey.Create(ConstStr.SmartKeyFileName);
  FTokenICO := TBlockchainICODat.Create(ConstStr.ICODatFileName);
  FSmartcontracts := TDictionary<String,TChainFileWorker>.Create;
  FSmartcontracts.Capacity := 100;

  FDynamicBlocks := TDictionary<String,TChainFileWorker>.Create;
  FDynamicBlocks.Capacity := 100;
  ChainFileWorker := TBlockchainTETDynamic.Create(ConstStr.Token64FileName);
  FDynamicBlocks.Add(ChainFileWorker.Name,ChainFileWorker);

  UpdateLists;
end;

destructor TBlockchain.Destroy;
var
  ChainFileWorker: TChainFileWorker;
begin
  FTokenCHN.Free;
  FSmartKey.Free;
  FTokenICO.Free;
  for ChainFileWorker in FSmartcontracts.Values do
    ChainFileWorker.Free;
  FSmartcontracts.Free;

  for ChainFileWorker in FDynamicBlocks.Values do
    ChainFileWorker.Free;
  FDynamicBlocks.Free;

  inherited;
end;

function TBlockchain.DynamicNameByID(AID: Integer): String;
begin
  if AID <> -1 then
    Result := Format('%d.tkn',[AID])
  else
    Result := ConstStr.Token64FileName;
end;

procedure TBlockchain.UpdateLists;
var
  smartKey: TCSmartKey;
  fileName: String;
  i: Integer;
  ChainFileWorker: TChainFileWorker;
begin
  for i := FSmartcontracts.Count to GetSmartsAmount-1 do
  begin
    smartKey := GetOneSmartKeyBlock(i);
    fileName := SmartNameByID(smartKey.SmartID);
    if not FSmartcontracts.TryGetValue(fileName,ChainFileWorker) then
    begin
      ChainFileWorker := TBlockchainSmart.Create(fileName);
      FSmartcontracts.Add(fileName,ChainFileWorker);
    end;

    fileName := DynamicNameByID(smartKey.SmartID);
    if not FDynamicBlocks.TryGetValue(filename,ChainFileWorker) then
    begin
      ChainFileWorker := TBlockchainTokenDynamic.Create(fileName);
      FDynamicBlocks.Add(fileName,ChainFileWorker);
    end;
  end;
end;

function TBlockchain.GetChainBlocks(var AAmount: Integer): TBytesBlocks;
begin
  Result := FTokenCHN.ReadBlocks(AAmount);
end;

function TBlockchain.GetChainBlocksCount: Integer;
begin
  Result := FTokenCHN.GetBlocksCount;
end;

function TBlockchain.GetChainBlocks(AFrom: Int64;
  out AAmount: Integer): TBytesBlocks;
begin
  Result := FTokenCHN.ReadBlocks(AFrom,AAmount);
end;

function TBlockchain.GetChainBlockSize: Integer;
begin
  Result := FTokenCHN.GetBlockSize;
end;

function TBlockchain.GetChainTransactions(ASkip: Integer;
  var ARows: Integer): TArray<TExplorerTransactionInfo>;
var
  Bytes: TBytesBlocks;
  TCbc2Arr: array[0..SizeOf(Tbc2)-1] of Byte;
  bc2: Tbc2 absolute TCbc2Arr;
  i,j,count: Integer;
  hashHex: String;
  tb: TTokenBase;
begin
  count := ARows;
  Bytes := FTokenCHN.ReadBlocks(ASkip,ARows);
  ARows := Min(Min(ARows,count),50);

  SetLength(Result,ARows);
  for i := 0 to ARows-1 do
  begin
    Move(Bytes[i*SizeOf(bc2)],TCbc2Arr[0],SizeOf(bc2));

    Result[i].DateTime := bc2.Smart.TimeEvent;
    Result[i].BlockNum := ASkip + i;

    if GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) then
      Result[i].TransFrom := tb.Token;
    if GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) then
      Result[i].TransTo := tb.Token;

    hashHex := '';
    for j := 1 to CHashLength do
      hashHex := hashHex + IntToHex(bc2.Hash[j],2);
    Result[i].Hash := hashHex.ToLower;

    Result[i].FloatSize := 8;
    Result[i].Amount := bc2.Smart.Delta;
    Result[i].Ticker := 'TET'
  end;
end;

function TBlockchain.GetChainUserTransactions(AUserID: Integer; ASkip: Integer;
  var ARows: Integer): TArray<THistoryTransactionInfo>;
var
  oneBlock1: TOneBlockBytes;
  bc2: Tbc2 absolute oneBlock1;
  tICO: TTokenICODat;
  tb: TTokenBase;
  hashHex: String;
  TokenID,startBlock,i,j: Integer;
  transaction: THistoryTransactionInfo;
begin
  Result := [];
  if not TryGetTETTokenBase(AUserID,TokenID,tb) then exit;
  oneBlock1 := GetOneChainBlock(tb.LastBlock);
  if not TryGetOneICOBlock(tb.TokenDatID,tICO) then exit;

  startBlock := tb.StartBlock;
  i := tb.LastBlock;
  while (ASkip > 0) and (i > 0) and (i > StartBlock) do
  begin
    oneBlock1 := GetOneChainBlock(i);  // do skipping
    if bc2.Smart.tkn[1].TokenID = TokenID then
    begin
      i := bc2.Smart.tkn[1].FromBlock;
      Dec(ASkip);
    end else
    if bc2.Smart.tkn[2].TokenID = TokenID then
    begin
      i := bc2.Smart.tkn[2].FromBlock;
      Dec(ASkip);
    end;
  end;

  while (i > 0) and (i > StartBlock) and (Length(Result) < ARows) do
  begin
    oneBlock1 := GetOneChainBlock(i);
    if bc2.Smart.tkn[1].TokenID = TokenID then
    begin
      hashHex := '';
      for j := 1 to CHashLength do
        hashHex := hashHex + IntToHex(bc2.Hash[j],2);

      if not GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) then break;
      transaction.DateTime := bc2.Smart.TimeEvent;
      transaction.BlockNum := i;
      transaction.Amount := bc2.Smart.Delta/Power(10,tICO.FloatSize);
      transaction.Hash := hashHex.ToLower;
      transaction.Address := tb.Token;
      transaction.Incom := False;
      Result := Result + [transaction];
      i := bc2.Smart.tkn[1].FromBlock;
    end;

    if bc2.Smart.tkn[2].TokenID = TokenID then
    begin
      hashHex := '';
      for j := 1 to CHashLength do
      hashHex := hashHex + IntToHex(bc2.Hash[j],2);

      if not GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) then break;
      transaction.DateTime := bc2.Smart.TimeEvent;
      transaction.BlockNum := i;
      transaction.Amount := bc2.Smart.Delta/Power(10,tICO.FloatSize);
      transaction.Hash := hashHex.ToLower;
      transaction.Address := tb.Token;
      transaction.Incom := True;
      Result := Result + [transaction];
      i := bc2.Smart.tkn[2].FromBlock;
    end;
  end;
  ARows := Length(Result);
end;

function TBlockchain.GetDynBlocks(ADynID: Integer; AFrom: Int64;
  out AAmount: Integer): TBytesBlocks;
var
  ChainFileWorker: TChainFileWorker;
begin
  if FDynamicBlocks.TryGetValue(DynamicNameByID(ADynID),ChainFileWorker) then
    Result := ChainFileWorker.ReadBlocks(AFrom,AAmount);
end;

function TBlockchain.GetDynBlocksCount(ADynID: Integer): Integer;
var
  ChainFileWorker: TChainFileWorker;
begin
  if FDynamicBlocks.TryGetValue(DynamicNameByID(ADynID),ChainFileWorker) then
    Result := ChainFileWorker.GetBlocksCount
  else
    Result := 0;
end;

function TBlockchain.GetDynBlockSize(ADynID: Integer): Integer;
var
  ChainFileWorker: TChainFileWorker;
begin
  if FDynamicBlocks.TryGetValue(DynamicNameByID(ADynID),ChainFileWorker) then
    Result := ChainFileWorker.GetBlockSize
  else
    Result := DYNAMIC_BLOCK_SIZE_DEFAULT;
end;

function TBlockchain.GetICOBlocks(AFrom: Int64;
  out AAmount: Integer): TBytesBlocks;
begin
  Result := FTokenICO.ReadBlocks(AFrom,AAmount);
end;

function TBlockchain.GetICOBlocksCount: Integer;
begin
  Result := FTokenICO.GetBlocksCount;
end;

function TBlockchain.GetICOBlockSize: Integer;
begin
  Result := FTokenICO.GetBlockSize;
end;

function TBlockchain.GetICOsInfo(ASkip: Integer; var ARows: Integer): TArray<TTokenICODat>;
var
  Blocks: TBytesBlocks;
  ICOBytesArr: array[0..SizeOf(TTokenICODat)-1] of Byte;
  TokenICO: TTokenICODat absolute ICOBytesArr;
  i,count: Integer;
begin
  count := ARows;
  Blocks := FTokenICO.ReadBlocks(ASkip + 2,ARows); // skip TET and TEC
  ARows := Min(Min(ARows,count),50);

  SetLength(Result,ARows);
  for i := 0 to ARows-1 do
  begin
    Move(Blocks[i * SizeOf(TTokenICODat)], ICOBytesArr[0], SizeOf(TTokenICODat));
    Result[i] := TokenICO;
  end;
end;

function TBlockchain.GetLastChainTransactions(
  var Amount: Integer): TArray<TExplorerTransactionInfo>;
var
  Bytes: TOneBlockBytes;
  bc2: Tbc2 absolute Bytes;
  i,j: Integer;
  hashHex: String;
  tb: TTokenBase;
  transaction: TExplorerTransactionInfo;
begin
  Result := [];
  i := GetChainBlocksCount-1;
  while (i > 0) and (Length(Result) < Amount) do
  begin
    try
      Bytes := FTokenCHN.GetOneBlock(i);

      transaction.DateTime := bc2.Smart.TimeEvent;
      transaction.BlockNum := GetChainBlocksCount-Amount+i;

      if GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) and (tb.TokenDatID = 1) then
        transaction.TransFrom := tb.Token
      else
        continue;

      if GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) and (tb.TokenDatID = 1) then
        transaction.TransTo := tb.Token
      else
        continue;

      hashHex := '';
      for j := 1 to CHashLength do
        hashHex := hashHex + IntToHex(bc2.Hash[j],2);
      transaction.Hash := hashHex.ToLower;

      transaction.FloatSize := 8;
      transaction.Amount := bc2.Smart.Delta;
      transaction.Ticker := 'TET';

      Result := Result + [transaction];
    finally
      Dec(i);
    end;
  end;
  Amount := Length(Result);
end;

function TBlockchain.GetLastChainUserTransactions(AUserID: Integer;
  var AAmount: Integer): TArray<THistoryTransactionInfo>;
var
  oneBlock1: TOneBlockBytes;
  bc2: Tbc2 absolute oneBlock1;
  tICO: TTokenICODat;
  tb: TTokenBase;
  hashHex: String;
  TokenID,startBlock,i,j: Integer;
  transaction: THistoryTransactionInfo;
begin
  Result := [];
  if not TryGetTETTokenBase(AUserID,TokenID,tb) then exit;
  oneBlock1 := GetOneChainBlock(tb.LastBlock);
  if not TryGetOneICOBlock(tb.TokenDatID,tICO) then exit;

  startBlock := tb.StartBlock;
  i := tb.LastBlock;
  while (i > 0) and (i > StartBlock) and (Length(Result) <= AAmount) do
  begin
    oneBlock1 := GetOneChainBlock(i);

    if bc2.Smart.tkn[1].TokenID = TokenID then
		begin
      hashHex := '';
      for j := 1 to CHashLength do
        hashHex := hashHex + IntToHex(bc2.Hash[j],2);

      if not GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) then break;
      transaction.DateTime := bc2.Smart.TimeEvent;
      transaction.BlockNum := i;
      transaction.Amount := bc2.Smart.Delta/Power(10,tICO.FloatSize);
      transaction.Hash := hashHex.ToLower;
      transaction.Address := tb.Token;
      transaction.Incom := False;
      Result := Result + [transaction];
			i := bc2.Smart.tkn[1].FromBlock;
		end;

		if bc2.Smart.tkn[2].TokenID = TokenID then
		begin
      hashHex := '';
      for j := 1 to CHashLength do
        hashHex := hashHex + IntToHex(bc2.Hash[j],2);

      if not GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) then break;
      transaction.DateTime := bc2.Smart.TimeEvent;
      transaction.BlockNum := i;
      transaction.Amount := bc2.Smart.Delta/Power(10,tICO.FloatSize);
      transaction.Hash := hashHex.ToLower;
      transaction.Address := tb.Token;
      transaction.Incom := True;
      Result := Result + [transaction];
			i := bc2.Smart.tkn[2].FromBlock;
		end;
  end;
  AAmount := Length(Result);
end;

function TBlockchain.GetLastSmartTransactions(ATicker: String;
  var Amount: Integer): TArray<TExplorerTransactionInfo>;
var
  ChainFileWorker: TChainFileWorker;
  Bytes: TBytesBlocks;
  i,j,dynID: Integer;
  hashHex: String;
  TCbc4Arr: array[0..SizeOf(TCbc4)-1] of Byte;
  bc4: TCbc4 absolute TCbc4Arr;
  tcb: TCTokensBase;
  tICO: TTokenICODat;
begin
  if not FSmartcontracts.TryGetValue(SmartNameByTicker(ATicker),ChainFileWorker)
    then exit;

  Bytes := ChainFileWorker.ReadBlocks(Amount);
  SetLength(Result,Amount);
  for i := Amount-1 downto 0 do
  begin
    Move(Bytes[i*SizeOf(bc4)],TCbc4Arr[0],SizeOf(bc4));

    Result[Amount-i-1].DateTime := bc4.Smart.TimeEvent;
    dynID := SmartIDByTicker(ATicker);
    Result[Amount-i-1].BlockNum := GetSmartBlocksCount(dynID)-Amount+i;

    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[1].TokenID,tcb) then
      Result[Amount-i-1].TransFrom := tcb.Token;
    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[2].TokenID,tcb) then
      Result[Amount-i-1].TransTo := tcb.Token;

    hashHex := '';
    for j := 1 to CHashLength do
      hashHex := hashHex + IntToHex(bc4.Hash[j],2);
    Result[Amount-i-1].Hash := hashHex.ToLower;

    if TryGetOneICOBlock(ATicker,tICO) then
    begin
      Result[Amount-i-1].FloatSize := tICO.FloatSize;
      Result[Amount-i-1].Amount := bc4.Smart.Delta;
      Result[Amount-i-1].Ticker := tICO.Abreviature;
    end;
  end;
end;

function TBlockchain.GetLastSmartUserTransactions(AUserID: Integer;
  ATicker: String; var AAmount: Integer): TArray<THistoryTransactionInfo>;
var
  sk: TCSmartKey;
  bc4: TCbc4;
  tICO: TTokenICODat;
  tcb: TCTokensBase;
  hashHex: String;
  TokenID,startBlock,i,j: Integer;
  transaction: THistoryTransactionInfo;
begin
  Result := [];
  try
    if not TryGetSmartKey(ATicker,sk) then exit;
    if not TryGetCTokenBase(sk.SmartID,AUserID,TokenID,tcb) then exit;
    bc4 := GetOneSmartBlock(sk.SmartID,tcb.LastBlock);
    if not TryGetOneICOBlock(ATicker,tICO) then exit;

    startBlock := tcb.StartBlock;
    i := tcb.LastBlock;
    while (i > 0) and (i > StartBlock) and (Length(Result) <= AAmount) do
    begin
      bc4 := GetOneSmartBlock(sk.SmartID,i);

      if bc4.Smart.tkn[1].TokenID = TokenID then
      begin
        hashHex := '';
        for j := 1 to CHashLength do
          hashHex := hashHex + IntToHex(bc4.Hash[j],2);

        if not GetOneSmartDynBlock(sk.SmartID,bc4.Smart.tkn[2].TokenID,tcb) then break;
        transaction.DateTime := bc4.Smart.TimeEvent;
        transaction.BlockNum := i;
        transaction.Amount := bc4.Smart.Delta/Power(10,tICO.FloatSize);
        transaction.Hash := hashHex.ToLower;
        transaction.Address := tcb.Token;
        transaction.Incom := False;
        Result := Result + [transaction];
        i := bc4.Smart.tkn[1].FromBlock;
      end;

      if bc4.Smart.tkn[2].TokenID = TokenID then
      begin
        hashHex := '';
        for j := 1 to CHashLength do
          hashHex := hashHex + IntToHex(bc4.Hash[j],2);

        if not GetOneSmartDynBlock(sk.SmartID,bc4.Smart.tkn[1].TokenID,tcb) then break;
        transaction.DateTime := bc4.Smart.TimeEvent;
        transaction.BlockNum := i;
        transaction.Amount := bc4.Smart.Delta/Power(10,tICO.FloatSize);
        transaction.Hash := hashHex.ToLower;
        transaction.Address := tcb.Token;
        transaction.Incom := True;
        Result := Result + [transaction];
        i := bc4.Smart.tkn[2].FromBlock;
      end;
    end;
  finally
    AAmount := Length(Result);
  end;
end;

function TBlockchain.GetOneChainBlock(AFrom: Int64): TOneBlockBytes;
begin
  Result := FTokenCHN.GetOneBlock(AFrom);
end;

function TBlockchain.GetOneChainDynBlock(AFrom: Integer; var AValue: TTokenBase): Boolean;
var
  ChainFileWorker: TChainFileWorker;
  OneBlock: TOneBlockBytes;
  tb: TTokenBase absolute OneBlock;
begin
  FDynamicBlocks.TryGetValue(ConstStr.Token64FileName, ChainFileWorker);
  if (ChainFileWorker.GetBlocksCount <= AFrom) or (AFrom < 0) then
    Exit(False)
  else
    Result := True;

  OneBlock := ChainFileWorker.GetOneBlock(AFrom);
  AValue := tb;
end;

function TBlockchain.TryGetOneICOBlock(AFrom: Int64; var ICOBlock: TTokenICODat): Boolean;
begin
  Result := TBlockchainICODat(FTokenICO).TryGetTokenICO(AFrom,ICOBlock);
end;

function TBlockchain.GetOneSmartBlock(ASmartID: Integer; AFrom: Int64): TCbc4;
var
  ChainFileWorker: TChainFileWorker;
  blockBytes: TOneBlockBytes;
  TCbc4Block: TCbc4 absolute blockBytes;
begin
  if not FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
    exit;

  blockBytes := ChainFileWorker.GetOneBlock(AFrom);
  Result := TCbc4Block;
end;

function TBlockchain.GetOneSmartKeyBlock(AFrom: Int64): TCSmartKey;
var
  blockBytes: TOneBlockBytes;
  TCSmartBlock: TCSmartKey absolute blockBytes;
begin
  blockBytes := FSmartKey.GetOneBlock(AFrom);
  Result := TCSmartBlock;
end;

function TBlockchain.GetOneSmartDynBlock(ASmartID: Integer; AFrom: Integer;
  var AValue: TCTokensBase): Boolean;
var
  ChainFileWorker: TChainFileWorker;
  OneBlock: TOneBlockBytes;
  tcb: TCTokensBase absolute OneBlock;
begin
  Result := False;
  if not FDynamicBlocks.TryGetValue(DynamicNameByID(ASmartID),ChainFileWorker) then exit;
  if (ChainFileWorker.GetBlocksCount <= AFrom) or (AFrom < 0) then exit;

  OneBlock := ChainFileWorker.GetOneBlock(AFrom);
  AValue := tcb;
  Result := True;
end;

function TBlockchain.GetSmartsAmount: Integer;
begin
  Result := FSmartKey.GetBlocksCount;
end;

function TBlockchain.GetSmartTickerByID(ASmartID: Integer): String;
var
  blockBytes: TOneBlockBytes;
  TCSmartBlock: TCSmartKey absolute blockBytes;
  i: Integer;
begin
  for i := 0 to FSmartKey.GetBlocksCount-1 do
  begin
    blockBytes := FSmartKey.GetOneBlock(i);
    if TCSmartBlock.SmartID = ASmartID then
      Exit(Trim(TCSmartBlock.Abreviature).ToUpper);
  end;
end;

function TBlockchain.GetSmartTransactions(ATicker: String; ASkip: Integer;
  var ARows: Integer): TArray<TExplorerTransactionInfo>;
var
  ChainFileWorker: TChainFileWorker;
  Bytes: TBytesBlocks;
  i,j,dynID,count: Integer;
  hashHex: String;
  TCbc4Arr: array[0..SizeOf(TCbc4)-1] of Byte;
  bc4: TCbc4 absolute TCbc4Arr;
  tcb: TCTokensBase;
  tICO: TTokenICODat;
begin
  if not FSmartcontracts.TryGetValue(SmartNameByTicker(ATicker),ChainFileWorker)
    then raise ESmartNotExistsError.Create('');

  count := ARows;
  Bytes := ChainFileWorker.ReadBlocks(ASkip,ARows);
  ARows := Min(Min(ARows,count),50);

  SetLength(Result,ARows);
  for i := 0 to ARows-1 do
  begin
    Move(Bytes[i*SizeOf(bc4)],TCbc4Arr[0],SizeOf(bc4));

    Result[i].DateTime := bc4.Smart.TimeEvent;
    dynID := SmartIDByTicker(ATicker);
    Result[i].BlockNum := ASkip + i;

    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[1].TokenID,tcb) then
      Result[i].TransFrom := tcb.Token;
    if GetOneSmartDynBlock(dynID,bc4.Smart.tkn[2].TokenID,tcb) then
      Result[i].TransTo := tcb.Token;

    hashHex := '';
    for j := 1 to CHashLength do
      hashHex := hashHex + IntToHex(bc4.Hash[j],2);
    Result[i].Hash := hashHex.ToLower;

    if TryGetOneICOBlock(ATicker,tICO) then
    begin
      Result[i].FloatSize := tICO.FloatSize;
      Result[i].Amount := bc4.Smart.Delta;
      Result[i].Ticker := tICO.Abreviature;
    end;
  end;
end;

function TBlockchain.IsSmartExists(ANameAddressOrTicker: String): Boolean;
var
  blockBytes: TOneBlockBytes;
  TCSmartBlock: TCSmartKey absolute blockBytes;
  i: Integer;
begin
  Result := False;
  for i := 0 to FSmartKey.GetBlocksCount-1 do
  begin
    blockBytes := FSmartKey.GetOneBlock(i);
    if (Trim(TCSmartBlock.Abreviature).ToUpper = ANameAddressOrTicker.ToUpper) or
       (Trim(TCSmartBlock.key1) = ANameAddressOrTicker) then
      Exit(True);
  end;
end;

function TBlockchain.GetSmartBlocks(ASmartID: Integer; AFrom: Int64;
  out AAmount: Integer): TBytesBlocks;
var
  ChainFileWorker: TChainFileWorker;
begin
  if ASmartID <> -1 then
  begin
    if not FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
    begin
      AAmount := -1;           //smartcontract with specified ID does not exists
      exit;
    end;

    Result := ChainFileWorker.ReadBlocks(AFrom,AAmount);
  end else
    Result := FSmartKey.ReadBlocks(AFrom,AAmount);
end;

function TBlockchain.GetSmartBlocks(ASmartID: Integer;
  out AAmount: Integer): TBytesBlocks;
var
  ChainFileWorker: TChainFileWorker;
begin
  if ASmartID <> -1 then
  begin
    if not FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
    begin
      AAmount := -1;
      exit;
    end;

    Result := ChainFileWorker.ReadBlocks(AAmount);
  end else
    Result := FSmartKey.ReadBlocks(AAmount);
end;

function TBlockchain.GetSmartBlocks(ATicker: String; out AAmount: Integer): TBytesBlocks;
var
  ChainFileWorker: TChainFileWorker;
begin
  if not FSmartcontracts.TryGetValue(SmartNameByTicker(ATicker),ChainFileWorker) then
  begin
    AAmount := -1;           //smartcontract with specified ID does not exists
    exit;
  end;

   Result := ChainFileWorker.ReadBlocks(AAmount);
end;

function TBlockchain.GetSmartAddress(AID: Integer): String;
var
  TCSmartBlock: TCSmartKey;
  i: Integer;
begin
  Result := '';
  for i := 0 to FSmartKey.GetBlocksCount-1 do
  begin
    TCSmartBlock := GetOneSmartKeyBlock(i);
    if TCSmartBlock.SmartID = AID then
      Exit(Trim(TCSmartBlock.key1));
  end;
end;

function TBlockchain.GetSmartAddress(ATicker: String): String;
var
  TCSmartBlock: TCSmartKey;
  i: Integer;
begin
  Result := '';
  for i := 0 to FSmartKey.GetBlocksCount-1 do
  begin
    TCSmartBlock := GetOneSmartKeyBlock(i);
    if Trim(TCSmartBlock.Abreviature).Equals(ATicker.ToUpper) then
      Exit(Trim(TCSmartBlock.key1));
  end;
end;

function TBlockchain.GetSmartBlocksCount(ASmartID: Integer): Integer;
var
  ChainFileWorker: TChainFileWorker;
begin
  if FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
    Result := ChainFileWorker.GetBlocksCount
  else
    Result := 0;
end;

function TBlockchain.GetSmartBlockSize(ASmartID: Integer): Integer;
var
  ChainFileWorker: TChainFileWorker;
begin
  if ASmartID <> -1 then
  begin
    if FSmartcontracts.TryGetValue(SmartNameByID(ASmartID),ChainFileWorker) then
      Result := ChainFileWorker.GetBlockSize
    else
      Result := SMART_BLOCK_SIZE_DEFAULT;
  end else
    Result := FSmartKey.GetBlockSize;
end;

function TBlockchain.TryGetSmartID(ATickerOrAddr: String; out ASmartID: Integer): Boolean;
var
  TCSmartBlock: TCSmartKey;
  i: Integer;
begin
  Result := False;
  for i := 0 to FSmartKey.GetBlocksCount-1 do
  begin
    TCSmartBlock := GetOneSmartKeyBlock(i);
    if (TCSmartBlock.key1 = ATickerOrAddr) or (TCSmartBlock.Abreviature = ATickerOrAddr) then
    begin
      ASmartID := TCSmartBlock.SmartID;
      Exit(True);
    end;
  end;
end;

function TBlockchain.SearchTransactionByHash(const AHash: string;
  out ATransaction: TExplorerTransactionInfo): Boolean;
var
  bc2: Tbc2;
  bc4: TCbc4;
  Key: string;
  BlockNum, DynID: Integer;
  TokenBase: TTokenBase;
  TCTokenBase: TCTokensBase;
  ChainFileWorker: TChainFileWorker;
  TokenICO: TTokenICODat;
begin
  Result := TBlockchainTokenCHN(FTokenCHN).TryFindBlockByHash(AHash, BlockNum, bc2);
  if Result then
  begin
    ATransaction.DateTime := bc2.Smart.TimeEvent;
    ATransaction.BlockNum := BlockNum;
    ATransaction.Hash := AHash;
    if GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID, TokenBase) then
      ATransaction.TransFrom := TokenBase.Token
    else
      ATransaction.TransFrom := '';
    if GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID, TokenBase) then
      ATransaction.TransTo := TokenBase.Token
    else
      ATransaction.TransTo := '';
    ATransaction.FloatSize := 8;
    ATransaction.Amount := bc2.Smart.Delta;
    ATransaction.Ticker := 'TET';
    Result := True;
  end else
  begin
    for Key in FSmartcontracts.Keys do
    begin
      ChainFileWorker := FSmartcontracts.Items[Key];
      Result := TBlockchainSmart(ChainFileWorker).TryFindBlockByHash(AHash,
        BlockNum, bc4);
      if Result then
      begin
        ATransaction.DateTime := bc4.Smart.TimeEvent;
        ATransaction.BlockNum := BlockNum;
        ATransaction.Hash := AHash;
        DynID := SmartIDByName(Key);
        if GetOneSmartDynBlock(DynID, bc4.Smart.tkn[1].TokenID, TCTokenBase) then
          ATransaction.TransFrom := TCTokenBase.Token;
        if GetOneSmartDynBlock(dynID, bc4.Smart.tkn[2].TokenID, TCTokenBase) then
          ATransaction.TransTo := TCTokenBase.Token;
        if TryGetOneICOBlock(dynID, TokenICO) then
        begin
          ATransaction.FloatSize := TokenICO.FloatSize;
          ATransaction.Amount := bc2.Smart.Delta;
          ATransaction.Ticker := TokenICO.Abreviature;
        end;
        Result := True;
        break;
      end
    end;
  end;
end;

function TBlockchain.SearchTransactionsByAddress(
  const AAddress: string): TArray<TExplorerTransactionInfo>;
var
  ChainFileWorker: TChainFileWorker;
  Pair: TPair<string, TChainFileWorker>;
  i, j, TokenID: Integer;
  bc2: Tbc2;
  bc4: TCbc4;
  TETBaseFrom, TETBaseTo: TTokenBase;
  TokenBaseFrom, TokenBaseTo: TCTokensBase;
  TokenICO: TTokenICODat;
  TransData: TExplorerTransactionInfo;
begin
  Result := [];
  FTokenCHN.DoOpen;
  FDynamicBlocks.TryGetValue(ConstStr.Token64FileName, ChainFileWorker);
  ChainFileWorker.DoOpen;
  try
    for i := 0 to FTokenCHN.GetBlocksCount - 1 do
    begin
      TBlockchainTokenCHN(FTokenCHN).TryGetBlock(i, bc2);
      if (GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID, TETBaseFrom) and
        (AAddress = TETBaseFrom.Token)) or
        (GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID, TETBaseTo) and
        (AAddress = TETBaseTo.Token)) then
      begin
        TransData.DateTime := bc2.Smart.TimeEvent;
        TransData.BlockNum := i;
        TransData.Hash := '';
        for j := 1 to TokenLength do
          TransData.Hash := TransData.Hash + IntToHex(bc2.Hash[j], 2).ToLower;
        TransData.TransFrom := TETBaseFrom.Token;
        TransData.TransTo := TETBaseTo.Token;
        TransData.Amount := bc2.Smart.Delta;
        TransData.FloatSize := 8;
        TransData.Ticker := 'TET';
        Result := Result + [TransData];
      end;
    end;
  finally
    ChainFileWorker.DoClose;
    FTokenCHN.DoClose;
  end;
  for Pair in FSmartcontracts do
  begin
    TokenID := SmartIDByName(Pair.Key);
    TBlockchainSmart(Pair.Value).DoOpen;
    FDynamicBlocks.TryGetValue(DynamicNameByID(TokenID), ChainFileWorker);
    TBlockchainTokenDynamic(ChainFileWorker).DoOpen;
    try
      for i := 0 to Pair.Value.GetBlocksCount - 1 do
      begin
        if not TBlockchainSmart(Pair.Value).TryGetBlock(i, bc4) then
          continue;
        if (GetOneSmartDynBlock(TokenID, bc4.Smart.tkn[1].TokenID, TokenBaseFrom) and
          (AAddress = TokenBaseFrom.Token)) or
          (GetOneSmartDynBlock(TokenID, bc4.Smart.tkn[2].TokenID, TokenBaseTo) and
          (AAddress = TokenBaseTo.Token)) then
        begin
          TransData.DateTime := bc4.Smart.TimeEvent;
          TransData.BlockNum := i;
          TransData.Hash := '';
          for j := 1 to CHashLength do
            TransData.Hash := TransData.Hash + IntToHex(bc4.Hash[j], 2).ToLower;
          TransData.TransFrom := TokenBaseFrom.Token;
          TransData.TransTo := TokenBaseTo.Token;
          if TryGetOneICOBlock(TokenID, TokenICO) then
          begin
            TransData.Amount := bc4.Smart.Delta;
            TransData.FloatSize := TokenICO.FloatSize;
            TransData.Ticker := TokenICO.Abreviature;
          end;
          Result := Result + [TransData];
        end;
      end;
    finally
      TBlockchainTokenDynamic(ChainFileWorker).DoClose;
      TBlockchainSmart(Pair.Value).DoClose;
    end;
  end;
end;

function TBlockchain.SearchTransactionsByBlockNum(
  const ABlockNum: Integer): TArray<TExplorerTransactionInfo>;
var
  bc2: Tbc2;
  bc4: TCbc4;
  Key: string;
  i: Integer;
  DynID: Integer;
  TokenBase: TTokenBase;
  TCTokenBase: TCTokensBase;
  ChainFileWorker: TChainFileWorker;
  TokenICO: TTokenICODat;
  TransData: TExplorerTransactionInfo;
begin
  Result := [];
  if TBlockchainTokenCHN(FTokenCHN).TryGetBlock(ABlockNum, bc2) then
  begin
    TransData.DateTime := bc2.Smart.TimeEvent;
    TransData.BlockNum := ABlockNum;
    TransData.Hash := '';
    for i := 1 to TokenLength do
      TransData.Hash := TransData.Hash + IntToHex(bc2.Hash[i], 2).ToLower;
    if GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID, TokenBase) then
      TransData.TransFrom := TokenBase.Token
    else
      TransData.TransFrom := '';
    if GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID, TokenBase) then
      TransData.TransTo := TokenBase.Token
    else
      TransData.TransTo := '';
    TransData.Amount := bc2.Smart.Delta;
    TransData.FloatSize := 8;
    TransData.Ticker := 'TET';
    Result := Result + [TransData];
  end;
  for Key in FSmartcontracts.Keys do
  begin
    ChainFileWorker := FSmartcontracts.Items[Key];
    if TBlockchainSmart(ChainFileWorker).TryGetBlock(ABlockNum, bc4) then
    begin
      TransData.DateTime := bc4.Smart.TimeEvent;
      TransData.BlockNum := ABlockNum;
      TransData.Hash := '';
      for i := 1 to CHashLength do
        TransData.Hash := TransData.Hash + IntToHex(bc4.Hash[i], 2).ToLower;
      DynID := SmartIDByName(Key);
      if GetOneSmartDynBlock(DynID, bc4.Smart.tkn[1].TokenID, TCTokenBase) then
        TransData.TransFrom := TCTokenBase.Token;
      if GetOneSmartDynBlock(DynID, bc4.Smart.tkn[2].TokenID, TCTokenBase) then
        TransData.TransTo := TCTokenBase.Token;
      if TryGetOneICOBlock(DynID, TokenICO) then
      begin
        TransData.Amount := bc4.Smart.Delta;
        TransData.FloatSize := TokenICO.FloatSize;
        TransData.Ticker := TokenICO.Abreviature;
      end;
      Result := Result + [TransData];
    end
  end;
end;

procedure TBlockchain.SetChainBlocks(APos: Int64; ABytes: TBytesBlocks; AAmount: Integer);
var
  i,bAmount: Integer;
  bc2Arr: TOneBlockBytes;
  bc2: Tbc2 absolute bc2Arr;
  tbArr: TOneBlockBytes;
  tb: TTokenBase absolute tbArr;
begin
  FTokenCHN.WriteBlocks(APos,ABytes,AAmount);

  if AppCore.DownloadRemain = 0 then
  begin
    bAmount := FTokenCHN.GetBlocksCount;
    for i := 0 to AAmount-1 do
    begin
      Move(ABytes[i*SizeOf(bc2)],bc2Arr[0],SizeOf(bc2));

      if GetOneChainDynBlock(bc2.Smart.tkn[1].TokenID,tb) then
      begin
        tb.LastBlock := bAmount-AAmount+i;
        SetDynBlock(-1,bc2.Smart.tkn[1].TokenID,tbArr);
      end;

      if GetOneChainDynBlock(bc2.Smart.tkn[2].TokenID,tb) then
      begin
        tb.LastBlock := bAmount-AAmount+i;
        SetDynBlock(-1,bc2.Smart.tkn[2].TokenID,tbArr);
      end;
    end;
  end else
  begin
    AppCore.DownloadRemain := -AAmount;
    UI.ShowDownloadProgress;
  end;

  UI.NotifyNewChainBlocks;
end;

procedure TBlockchain.SetDynBlock(ADynID: Integer; APos: Int64;
  ABytes: TOneBlockBytes);
var
  dynName: String;
  ChainFileWorker: TChainFileWorker;
begin
  dynName := DynamicNameByID(ADynID);
  if not FDynamicBlocks.TryGetValue(dynName,ChainFileWorker) then
  begin
    ChainFileWorker := TBlockchainTokenDynamic.Create(dynName);
    FDynamicBlocks.Add(dynName,ChainFileWorker);
  end;

  ChainFileWorker.WriteOneBlock(APos,ABytes);
end;

procedure TBlockchain.SetDynBlocks(ADynID: Integer; APos: Int64;
  ABytes: TBytesBlocks; AAmount: Integer);
var
  dynName: String;
  ChainFileWorker: TChainFileWorker;
begin
  dynName := DynamicNameByID(ADynID);
  if FDynamicBlocks.TryGetValue(dynName,ChainFileWorker) then
    ChainFileWorker.WriteBlocks(APos,ABytes,AAMount);

  if (ADynID = -1) and (AppCore.DownloadRemain > 0) then
  begin
    AppCore.DownloadRemain := -AAmount;
    UI.ShowDownloadProgress;
  end;
end;

procedure TBlockchain.SetICOBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
begin
  FTokenICO.WriteBlocks(APos,ABytes,AAmount);
end;

procedure TBlockchain.SetSmartBlocks(ASmartID: Integer; APos: Int64;
  ABytes: TBytesBlocks; AAmount: Integer);
var
  name: String;
  ChainFileWorker: TChainFileWorker;

  i,bAmount: Integer;
  bc4Arr: TOneBlockBytes;
  bc4: TCbc4 absolute bc4Arr;
  tbArr: TOneBlockBytes;
  tcb: TCTokensBase absolute tbArr;
begin
  name := SmartNameByID(ASmartID);
  if not FSmartcontracts.TryGetValue(name,ChainFileWorker) then exit;

  ChainFileWorker.WriteBlocks(APos,ABytes,AAmount);
  bAmount := ChainFileWorker.GetBlocksCount;
  for i := 0 to AAmount-1 do
  begin
    Move(ABytes[i*SizeOf(bc4)],bc4Arr[0],SizeOf(bc4));

    if GetOneSmartDynBlock(ASmartID,bc4.Smart.tkn[1].TokenID,tcb) then
    begin
      tcb.LastBlock := bAmount-AAmount+i;
      SetDynBlock(ASmartID,bc4.Smart.tkn[1].TokenID,tbArr);
    end;

    if GetOneSmartDynBlock(ASmartID,bc4.Smart.tkn[2].TokenID,tcb) then
    begin
      tcb.LastBlock := bAmount-AAmount+i;
      SetDynBlock(ASmartID,bc4.Smart.tkn[2].TokenID,tbArr);
    end;
  end;
  UI.NotifyNewSmartBlocks;
end;

procedure TBlockchain.SetSmartKeyBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
begin
  FSmartKey.WriteBlocks(APos,ABytes,AAmount);
  UpdateLists;
end;

function TBlockchain.SmartIDByName(AName: String): Integer;
begin
  Result := AName.Substring(0, Length(AName) - 4).ToInteger;
end;

function TBlockchain.SmartIDByTicker(ATicker: String): Integer;
begin
  Result := SmartIDByName(SmartNameByTicker(ATicker));
end;

//function TBlockchain.SmartIdNameToTicker(AIDName: String): String;
//var
//  blockBytes: TOneBlockBytes;
//  TCSmartBlock: TCSmartKey absolute blockBytes;
//  i: Integer;
//begin
//  for i := 0 to GetSmartBlocksCount(-1)-1 do
//  begin
//    blockBytes := GetOneSmartBlock(-1,i);
//    if TCSmartBlock.SmartID = SmartIDByName(AIDName) then
//      Exit(Trim(TCSmartBlock.Abreviature).ToUpper);
//  end;
//end;

function TBlockchain.SmartNameByID(AID: Integer): String;
begin
  Result := Format('%d.chn',[AID]);
end;

function TBlockchain.SmartNameByTicker(ATicker: String): String;
var
  block: TCSmartKey;
  i: Integer;
begin
  Result := '';
  for i := 0 to GetSmartsAmount-1 do
  begin
    block := GetOneSmartKeyBlock(i);
    if Trim(block.Abreviature) = ATicker then
      Exit(SmartNameByID(block.SmartID));
  end;
end;

function TBlockchain.SmartTickerToID(ATicker: String): Integer;
var
  block: TCSmartKey;
  i: Integer;
begin
  Result := -1;
  for i := 0 to GetSmartBlocksCount(-1)-1 do
  begin
    block := GetOneSmartKeyBlock(i);
    if Trim(block.Abreviature) = ATicker then
      Exit(block.SmartID);
  end;
end;

function TBlockchain.SmartTickerToIDName(ATicker: String): String;
begin
  Result := SmartNameByID(SmartTickerToID(ATicker));
end;

function TBlockchain.TryGetCTokenBase(ATokenID: Integer; const AOwnerID: Integer;
  out AID: Integer; var tb: TCTokensBase): Boolean;
var
  ChainFileWorker: TChainFileWorker;
begin
  Result := False;
  if not FDynamicBlocks.TryGetValue(DynamicNameByID(ATokenID),ChainFileWorker) then
    exit;

  Result := TBlockchainTokenDynamic(ChainFileWorker).TryGetTokenBase(AOwnerID,AID,tb);
end;

function TBlockchain.TryGetCTokenBase(ATokenID: Integer; const ATETAddress: String;
  out AID: Integer; var tb:TCTokensBase): Boolean;
var
  ChainFileWorker: TChainFileWorker;
begin
  Result := False;
  if not FDynamicBlocks.TryGetValue(DynamicNameByID(ATokenID),ChainFileWorker) then
    exit;

  Result := TBlockchainTokenDynamic(ChainFileWorker).TryGetTokenBase(ATETAddress,AID,tb);
end;

function TBlockchain.TryGetOneICOBlock(ATicker: String;
  var ICOBlock: TTokenICODat): Boolean;
begin
  Result := TBlockchainICODat(FTokenICO).TryGetTokenICO(ATicker,ICOBlock);
end;

function TBlockchain.TryGetSmartKey(ATicker: String;
  var sk: TCSmartKey): Boolean;
begin
  Result := TBlockchainSmartKey(FSmartKey).TryGetSmartKey(ATicker, sk);
end;

function TBlockchain.TryGetSmartKeyByAddress(const AAddress: String; var sk: TCSmartKey): Boolean;
begin
  Result := TBlockchainSmartKey(FSmartKey).TryGetSmartKeyByAddress(AAddress, sk);
end;

function TBlockchain.TryGetTETAddressByOwnerID(const AOwnerID: Int64;
  out ATETAddress: String): Boolean;
var
  ChainFileWorker: TChainFileWorker;
begin
  FDynamicBlocks.TryGetValue(ConstStr.Token64FileName, ChainFileWorker);

  Result := TBlockchainTETDynamic(ChainFileWorker).TryGetTETAddress(AOwnerID,ATETAddress);
end;

function TBlockchain.TryGetTETTokenBase(const ATETAddress: String;
  out AID: Integer; var tb: TTokenBase): Boolean;
var
  ChainFileWorker: TChainFileWorker;
begin
  FDynamicBlocks.TryGetValue(ConstStr.Token64FileName, ChainFileWorker);

  Result := TBlockchainTETDynamic(ChainFileWorker).TryGetTokenBase(ATETAddress,AID,tb);
end;

function TBlockchain.TryGetTETTokenBase(const AOwnerID: Int64;
  out AID: Integer; var tb: TTokenBase): Boolean;
var
  ChainFileWorker: TChainFileWorker;
begin
  FDynamicBlocks.TryGetValue(ConstStr.Token64FileName, ChainFileWorker);

  Result := TBlockchainTETDynamic(ChainFileWorker).TryGetTokenBase(AOwnerID,AID,tb);
end;

end.

