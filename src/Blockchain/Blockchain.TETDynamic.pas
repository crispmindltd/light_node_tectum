unit Blockchain.TETDynamic;

interface

uses
  App.Constants,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Classes,
  IOUtils,
  Math,
  SysUtils;

type
  TBlockchainTETDynamic = class(TChainFileBase)
  private
    FFile: file of TTokenBase;
    FIsOpened: Boolean;
  public
    constructor Create;
    destructor Destory;
    function DoOpen: Boolean;
    procedure DoClose;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Integer; override;
    procedure WriteBlocksAsBytes(ASkipBlocks: Integer; ABytes: TBytes); override;
    procedure WriteBlock(ASkip: Integer; ABlock: TTokenBase);
    function TryReadBlock(ASkip: Integer; out ABlock: TTokenBase): Boolean;
    function ReadBlocksAsBytes(ASkipBlocks: Integer;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Integer;
      ANumber: Integer = MaxBlocksNumber): TArray<TTokenBase>;

    function TryGetTETAddress(const AOwnerID: Integer; out ATETAddress: String): Boolean;
//    function TryGetByUserID(AUserID: Int64; out ABlockID: Int64;
//      var ATETDynamic: TTokenBase): Boolean;
    function TryGetByTETAddress(ATETAddress: string; out ABlockNum: Integer;
      out ATETDynamic: TTokenBase): Boolean;
  end;

implementation

{ TBlockchainTETDynamic }

constructor TBlockchainTETDynamic.Create;
begin
  inherited Create(ConstStr.DBCPath, ConstStr.Token64FileName);

  FIsOpened := False;
  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);
end;

destructor TBlockchainTETDynamic.Destory;
begin

  inherited;
end;

procedure TBlockchainTETDynamic.DoClose;
begin
  if FIsOpened then
  begin
    CloseFile(FFile);
    FIsOpened := False;
    FLock.Leave;
  end;
end;

function TBlockchainTETDynamic.DoOpen: Boolean;
begin
  Result := not FIsOpened;
  if Result then
  begin
    FLock.Enter;
    AssignFile(FFile, FFullFilePath);
    Reset(FFile);
    FIsOpened := True;
  end;
end;

function TBlockchainTETDynamic.GetBlocksCount: Integer;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen;
  try
    Result := FileSize(FFile);
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTETDynamic.GetBlockSize: Integer;
begin
  Result := SizeOf(TTokenBase);
end;

function TBlockchainTETDynamic.ReadBlocks(ASkip,
  ANumber: Integer): TArray<TTokenBase>;
var
  NeedClose: Boolean;
  i: Integer;
begin
  Result := [];
  NeedClose := DoOpen;
  try
    if (ASkip < 0) or (ASkip >= FileSize(FFile)) then
      exit;
    Seek(FFile, ASkip);
    SetLength(Result, Min(ANumber, FileSize(FFile) - ASkip));
    for i := 0 to Length(Result) - 1 do
      Read(FFile, Result[i]);
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTETDynamic.ReadBlocksAsBytes(ASkipBlocks,
  ANumber: Integer): TBytes;
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(TTokenBase) - 1] of Byte;
  TokenBaseBlock: TTokenBase absolute BlockBytes;
  i: Integer;
begin
  Result := [];
  NeedClose := DoOpen;
  try
    if (ASkipBlocks >= FileSize(FFile)) or
      (ASkipBlocks < 0) then
      exit;

    Seek(FFile, ASkipBlocks);
    SetLength(Result, Min(ANumber, FileSize(FFile) - ASkipBlocks) * GetBlockSize);
    for i := 0 to (Length(Result) div GetBlockSize) - 1 do
    begin
      Read(FFile, TokenBaseBlock);
      Move(BlockBytes[0], Result[i * GetBlockSize], GetBlockSize);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTETDynamic.TryReadBlock(ASkip: Integer;
  out ABlock: TTokenBase): Boolean;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen;
  try
    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
    if Result then
    begin
      Seek(FFile, ASkip);
      Read(FFile, ABlock);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTETDynamic.WriteBlocksAsBytes(ASkipBlocks: Integer;
  ABytes: TBytes);
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(TTokenBase) - 1] of Byte;
  TokenBaseBlock: TTokenBase absolute BlockBytes;
  i: Integer;
begin
  if (Length(ABytes) mod GetBlockSize <> 0) or (ASkipBlocks < 0) then
    exit;

  NeedClose := DoOpen;
  try
    Seek(FFile, ASkipBlocks);
    for i := 0 to (Length(ABytes) div GetBlockSize) - 1 do
    begin
      Move(ABytes[i * GetBlockSize], BlockBytes[0], GetBlockSize);
      Write(FFile, TokenBaseBlock);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTETDynamic.TryGetByTETAddress(ATETAddress: string;
  out ABlockNum: Integer; out ATETDynamic: TTokenBase): Boolean;
var
  NeedClose: Boolean;
  i: Integer;
begin
  Result := False;
  NeedClose := DoOpen;
  try
    Seek(FFile, 0);
    for i := 0 to FileSize(FFile) - 1 do
    begin
      Read(FFile, ATETDynamic);
      if (ATETDynamic.Token = ATETAddress) and (ATETDynamic.TokenDatID = 1) then
      begin
        ABlockNum := i;
        exit(True);
      end;
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

//function TBlockchainTETDynamic.TryGetByUserID(AUserID: Int64; out ABlockID: Int64;
//  var ATETDynamic: TTokenBase): Boolean;
//var
//  NeedClose: Boolean;
//  i: Integer;
//begin
//  Result := False;
//  NeedClose := DoOpen(fmOpenRead or fmShareDenyNone);
//  try
//    for i := 0 to (FFile.Size div GetBlockSize) - 1 do
//    begin
//      FFile.Seek(i * GetBlockSize, soBeginning);
//      FFile.ReadData<TTokenBase>(ATETDynamic);
//      if (ATETDynamic.OwnerID = AUserID) and (ATETDynamic.TokenDatID = 1) then
//      begin
//        ABlockID := i;
//        exit(True);
//      end;
//    end;
//  finally
//    if NeedClose then
//      DoClose;
//  end;
//end;

procedure TBlockchainTETDynamic.WriteBlock(ASkip: Integer; ABlock: TTokenBase);
var
  NeedClose: Boolean;
begin
  if ASkip < 0 then
    exit;

  NeedClose := DoOpen;
  try
    Seek(FFile, ASkip);
    Read(FFile, ABlock);
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTETDynamic.TryGetTETAddress(const AOwnerID: Integer;
  out ATETAddress: String): Boolean;
var
  NeedClose: Boolean;
  i: Integer;
  TETDyn: TTokenBase;
begin
  Result := False;
  NeedClose := DoOpen;
  try
    Seek(FFile, 0);
    for i := 0 to FileSize(FFile) - 1 do
    begin
      Read(FFile, TETDyn);
      if (TETDyn.OwnerID = AOwnerID) and (TETDyn.TokenDatID = 1) then
      begin
        ATETAddress := TETDyn.Token;
        exit(True);
      end;
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

//function TBlockchainTETDynamic.TryGetTokenBase(ATETAddress: String;
//  out AID: Integer; out tb: TTokenBase): Boolean;
//var
//  i: Integer;
//begin
//  FLock.Enter;
//  Result := False;
//  AssignFile(FFile, FFullFilePath);
//  Reset(FFile);
//  try
//    for i := 0 to FileSize(FFile)-1 do
//    begin
//      Seek(FFile,i);
//      Read(FFile,tb);
//      if (tb.Token = ATETAddress) and (tb.TokenDatID = 1) then
//      begin
//        AID := i;
//        Exit(True);
//      end;
//    end;
//  finally
//    CloseFile(FFile);
//    FLock.Leave;
//  end;
//end;

end.
