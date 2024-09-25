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
  TBlockchainICODat = class(TChainFileWorker)
  private
    FFile: TFileStream;
  public
    constructor Create;
    destructor Destory;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Int64; override;
    procedure WriteBlock(ASkip: Int64; ABlock: TTokenICODat);
    procedure WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes); override;
    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<TTokenICODat>);
    function TryReadBlock(ASkip: Int64; out ABlock: TTokenICODat): Boolean;
    function ReadBlocksAsBytes(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TArray<TTokenICODat>;

//    function TryGetTokenICO(AFrom: Int64; var ICOBlock: TTokenICODat): Boolean; overload;
//    function TryGetTokenICO(ATicker: String; var ICOBlock: TTokenICODat): Boolean; overload;
  end;

implementation

{ TBlockchainICODat }

constructor TBlockchainICODat.Create;
begin
  inherited Create(ConstStr.DBCPath, ConstStr.ICODatFileName, True);

  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);
end;

destructor TBlockchainICODat.Destory;
begin

  inherited;
end;

function TBlockchainICODat.GetBlocksCount: Int64;
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

function TBlockchainICODat.GetBlockSize: Integer;
begin
  Result := SizeOf(TTokenICODat);
end;

function TBlockchainICODat.ReadBlocks(ASkip: Int64;
  ANumber: Integer): TArray<TTokenICODat>;
var
  i: Integer;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber, FFile.Size - FFile.Position));
    for i := 0 to Length(Result) - 1 do
      FFile.ReadData<TTokenICODat>(Result[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

function TBlockchainICODat.ReadBlocksAsBytes(ASkip: Int64;
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

function TBlockchainICODat.TryReadBlock(ASkip: Int64;
  out ABlock: TTokenICODat): Boolean;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
    if Result then
    begin
      FFile.Seek(ASkip * GetBlockSize, soBeginning);
      FFile.ReadData<TTokenICODat>(ABlock);
    end;
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainICODat.WriteBlock(ASkip: Int64; ABlock: TTokenICODat);
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.WriteData<TTokenICODat>(ABlock);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainICODat.WriteBlocks(ASkip: Int64;
  ABlocks: TArray<TTokenICODat>);
var
  i: Integer;
begin
  FLock.Enter;
  FFile := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    for i := 0 to Length(ABlocks) - 1 do
      FFile.WriteData<TTokenICODat>(ABlocks[i]);
  finally
    FFile.Free;
    FLock.Leave;
  end;
end;

procedure TBlockchainICODat.WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes);
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

//function TBlockchainICODat.TryGetTokenICO(AFrom: Int64;
//  var ICOBlock: TTokenICODat): Boolean;
//begin
//  FLock.Enter;
//  Result := False;
//  AssignFile(FFile, FFullFilePath);
//  Reset(FFile);
//  try
//    if AFrom >= FileSize(FFile) then Exit(False);
//
//    Seek(FFile,AFrom);
//    Read(FFile,ICOBlock);
//    Result := True;
//  finally
//    CloseFile(FFile);
//    FLock.Leave;
//  end;
//end;

end.
