unit Blockchain.ICODat;

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
  TBlockchainICODat = class(TChainFileBase)
  private
    FFile: file of TTokenICODat;
  public
    constructor Create;
    destructor Destory;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Integer; override;
    procedure WriteBlocksAsBytes(ASkipBlocks: Integer; ABytes: TBytes); override;
    procedure WriteBlock(ASkip: Integer; ABlock: TTokenICODat);
//    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<TTokenICODat>);
    function TryReadBlock(ASkip: Integer; out ABlock: TTokenICODat): Boolean;
    function ReadBlocksAsBytes(ASkipBlocks: Integer;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Integer;
      ANumber: Integer = MaxBlocksNumber): TArray<TTokenICODat>;

//    function TryGetTokenICO(ATicker: String; var ICOBlock: TTokenICODat): Boolean;
  end;

implementation

{ TBlockchainICODat }

constructor TBlockchainICODat.Create;
begin
  inherited Create(ConstStr.DBCPath, ConstStr.ICODatFileName);

  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);
end;

destructor TBlockchainICODat.Destory;
begin

  inherited;
end;

function TBlockchainICODat.GetBlocksCount: Integer;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Result := FileSize(FFile);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainICODat.GetBlockSize: Integer;
begin
  Result := SizeOf(TTokenICODat);
end;

function TBlockchainICODat.ReadBlocks(ASkip,
  ANumber: Integer): TArray<TTokenICODat>;
var
  i: Integer;
begin
  Result := [];
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    if (ASkip < 0) or (ASkip >= FileSize(FFile)) then
      exit;
    Seek(FFile, ASkip);
    SetLength(Result, Min(ANumber, FileSize(FFile) - ASkip));
    for i := 0 to Length(Result) - 1 do
      Read(FFile, Result[i]);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainICODat.ReadBlocksAsBytes(ASkipBlocks,
  ANumber: Integer): TBytes;
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(TTokenICODat) - 1] of Byte;
  TokenICODatBlock: TTokenICODat absolute BlockBytes;
  i: Integer;
begin
  Result := [];
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    if (ASkipBlocks >= FileSize(FFile)) or
      (ASkipBlocks < 0) then
      exit;

    Seek(FFile, ASkipBlocks);
    SetLength(Result, Min(ANumber, FileSize(FFile) - ASkipBlocks) * GetBlockSize);
    for i := 0 to (Length(Result) div GetBlockSize) - 1 do
    begin
      Read(FFile, TokenICODatBlock);
      Move(BlockBytes[0], Result[i * GetBlockSize], GetBlockSize);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainICODat.WriteBlocksAsBytes(ASkipBlocks: Integer;
  ABytes: TBytes);
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(TTokenICODat) - 1] of Byte;
  TokenICODatBlock: TTokenICODat absolute BlockBytes;
  i: Integer;
begin
  if (Length(ABytes) mod GetBlockSize <> 0) or (ASkipBlocks < 0) then
    exit;

  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile, ASkipBlocks);
    for i := 0 to (Length(ABytes) div GetBlockSize) - 1 do
    begin
      Move(ABytes[i * GetBlockSize], BlockBytes[0], GetBlockSize);
      Write(FFile, TokenICODatBlock);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainICODat.WriteBlock(ASkip: Integer; ABlock: TTokenICODat);
begin
  if ASkip < 0 then
    exit;

  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile, ASkip);
    Read(FFile, ABlock);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainICODat.TryReadBlock(ASkip: Integer;
  out ABlock: TTokenICODat): Boolean;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Result := (ASkip >= 0) and (ASkip < FileSize(FFile));
    if Result then
    begin
      Seek(FFile, ASkip);
      Read(FFile, ABlock);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

//procedure TBlockchainICODat.WriteBlocks(ASkip: Int64;
//  ABlocks: TArray<TTokenICODat>);
//var
//  i: Integer;
//begin
//  FLock.Enter;
//  FFile := TFileStream.Create(FullPath, fmOpenWrite);
//  try
//    FFile.Seek(ASkip * GetBlockSize, soBeginning);
//    for i := 0 to Length(ABlocks) - 1 do
//      FFile.WriteData<TTokenICODat>(ABlocks[i]);
//  finally
//    FFile.Free;
//    FLock.Leave;
//  end;
//end;

//function TBlockchainICODat.TryGetTokenICO(ATicker: String;
//  var ICOBlock: TTokenICODat): Boolean;
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
//      Read(FFile,ICOBlock);
//      if (ICOBlock.Abreviature = ATicker) then
//        Exit(True);
//    end;
//  finally
//    CloseFile(FFile);
//    FLock.Leave;
//  end;
//end;

end.
