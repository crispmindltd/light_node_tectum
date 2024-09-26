unit Blockchain.TET;

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
  TBlockchainTET = class(TChainFileWorker)
  private
    FFile: TFileStream;
  public
    constructor Create;
    destructor Destory;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Int64; override;
    procedure WriteBlock(ASkip: Int64; ABlock: Tbc2);
    procedure WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes); override;
    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<Tbc2>);
    function TryReadBlock(ASkip: Int64; out ABlock: Tbc2): Boolean;
    function ReadBlocksAsBytes(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TArray<Tbc2>;
  end;

implementation

{ TBlockchainTET }

constructor TBlockchainTET.Create;
begin
  inherited Create(ConstStr.DBCPath, ConstStr.TokenCHNFileName, True);

  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);
end;

destructor TBlockchainTET.Destory;
begin

  inherited;
end;

function TBlockchainTET.GetBlocksCount: Int64;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    Result := FFile.Size div GetBlockSize;
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

function TBlockchainTET.GetBlockSize: Integer;
begin
  Result := SizeOf(Tbc2);
end;

function TBlockchainTET.ReadBlocks(ASkip: Int64; ANumber: Integer): TArray<Tbc2>;
var
  i: Integer;
begin
  Result := [];
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    if ASkip * GetBlockSize > FFile.Size - GetBlockSize then
      exit;
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber, (FFile.Size - FFile.Position) div GetBlockSize));
    for i := 0 to Length(Result) - 1 do
      FFile.ReadData<Tbc2>(Result[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

function TBlockchainTET.ReadBlocksAsBytes(ASkip: Int64; ANumber: Integer): TBytes;
begin
  Result := [];
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    if ASkip * GetBlockSize > FFile.Size - GetBlockSize then
      exit;
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber * GetBlockSize, FFile.Size - FFile.Position));
    FFile.Read(Result, Length(Result));
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

function TBlockchainTET.TryReadBlock(ASkip: Int64; out ABlock: Tbc2): Boolean;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
    if Result then
    begin
      FFile.Seek(ASkip * GetBlockSize, soBeginning);
      FFile.ReadData<Tbc2>(ABlock);
    end;
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainTET.WriteBlock(ASkip: Int64; ABlock: Tbc2);
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.WriteData<Tbc2>(ABlock);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainTET.WriteBlocks(ASkip: Int64; ABlocks: TArray<Tbc2>);
var
  i: Integer;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    for i := 0 to Length(ABlocks) - 1 do
      FFile.WriteData<Tbc2>(ABlocks[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainTET.WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes);
begin
  if Length(ABytes) mod GetBlockSize <> 0 then
    exit;

  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.Write(ABytes, Length(ABytes));
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

end.
