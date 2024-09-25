unit Blockchain.SmartKey;

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
  TBlockchainSmartKey = class(TChainFileWorker)
  private
    FFile: TFileStream;
  public
    constructor Create;
    destructor Destory;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Int64; override;
    procedure WriteBlock(ASkip: Int64; ABlock: TCSmartKey);
    procedure WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes); override;
    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<TCSmartKey>);
    function TryReadBlock(ASkip: Int64; out ABlock: TCSmartKey): Boolean;
    function ReadBlocksAsBytes(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TArray<TCSmartKey>;

//    function TryGetSmartKey(ATicker: String; var sk: TCSmartKey): Boolean;
//    function TryGetSmartKeyByAddress(const AAddress: String; var sk: TCSmartKey): Boolean;
  end;

implementation

{ TBlockchainSmartKey }

constructor TBlockchainSmartKey.Create;
begin
  inherited Create(ConstStr.SmartCPath, ConstStr.SmartKeyFileName, True);

  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);
end;

destructor TBlockchainSmartKey.Destory;
begin

  inherited;
end;

function TBlockchainSmartKey.GetBlocksCount: Int64;
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

function TBlockchainSmartKey.GetBlockSize: Integer;
begin
  Result := SizeOf(TCSmartKey);
end;

function TBlockchainSmartKey.ReadBlocks(ASkip: Int64;
  ANumber: Integer): TArray<TCSmartKey>;
var
  i: Integer;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber, FFile.Size - FFile.Position));
    for i := 0 to Length(Result) - 1 do
      FFile.ReadData<TCSmartKey>(Result[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

function TBlockchainSmartKey.ReadBlocksAsBytes(ASkip: Int64;
  ANumber: Integer): TBytes;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber * GetBlockSize, FFile.Size - FFile.Position));
    FFile.Read(Result, Length(Result));
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

function TBlockchainSmartKey.TryReadBlock(ASkip: Int64;
  out ABlock: TCSmartKey): Boolean;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
    if Result then
    begin
      FFile.Seek(ASkip * GetBlockSize, soBeginning);
      FFile.ReadData<TCSmartKey>(ABlock);
    end;
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainSmartKey.WriteBlock(ASkip: Int64; ABlock: TCSmartKey);
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.WriteData<TCSmartKey>(ABlock);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainSmartKey.WriteBlocks(ASkip: Int64;
  ABlocks: TArray<TCSmartKey>);
var
  i: Integer;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    for i := 0 to Length(ABlocks) - 1 do
      FFile.WriteData<TCSmartKey>(ABlocks[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainSmartKey.WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes);
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
