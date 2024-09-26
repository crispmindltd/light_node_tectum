unit Blockchain.Token;

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
  TBlockchainToken = class(TChainFileWorker)
  private
    FFile: TFileStream;
  public
    constructor Create(ATokenID: Integer);
    destructor Destory;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Int64; override;
    procedure WriteBlock(ASkip: Int64; ABlock: TCbc4);
    procedure WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes); override;
    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<TCbc4>);
    function TryReadBlock(ASkip: Int64; out ABlock: TCbc4): Boolean;
    function ReadBlocksAsBytes(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TArray<TCbc4>;
  end;

implementation

{ TBlockchainToken }

constructor TBlockchainToken.Create(ATokenID: Integer);
begin
  inherited Create(ConstStr.SmartCPath, ATokenID.ToString + '.chn');

end;

destructor TBlockchainToken.Destory;
begin

  inherited;
end;

function TBlockchainToken.GetBlocksCount: Int64;
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

function TBlockchainToken.GetBlockSize: Integer;
begin
  Result := SizeOf(TCbc4);
end;

function TBlockchainToken.ReadBlocks(ASkip: Int64; ANumber: Integer): TArray<TCbc4>;
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
      FFile.ReadData<TCbc4>(Result[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

function TBlockchainToken.ReadBlocksAsBytes(ASkip: Int64; ANumber: Integer): TBytes;
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

function TBlockchainToken.TryReadBlock(ASkip: Int64; out ABlock: TCbc4): Boolean;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
    if Result then
    begin
      FFile.Seek(ASkip * GetBlockSize, soBeginning);
      FFile.ReadData<TCbc4>(ABlock);
    end;
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainToken.WriteBlock(ASkip: Int64; ABlock: TCbc4);
begin
  FLock.Enter;
  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);

  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.WriteData<TCbc4>(ABlock);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainToken.WriteBlocks(ASkip: Int64; ABlocks: TArray<TCbc4>);
var
  i: Integer;
begin
  FLock.Enter;
  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);

  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    for i := 0 to Length(ABlocks) - 1 do
      FFile.WriteData<TCbc4>(ABlocks[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainToken.WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes);
begin
  if Length(ABytes) mod GetBlockSize <> 0 then
    exit;

  FLock.Enter;
  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);

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
