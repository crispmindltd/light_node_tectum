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
  TBlockchainTET = class(TChainFileBase)
  private
    FFile: file of Tbc2;
  public
    constructor Create;
    destructor Destory;
    function DoOpen: Boolean;
    procedure DoClose;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Integer; override;
    procedure WriteBlocksAsBytes(ASkipBlocks: Integer; ABytes: TBytes); override;
    procedure WriteBlock(ASkip: Integer; ABlock: Tbc2);
//    procedure WriteBlocks(ASkip: Integer; ABlocks: TArray<Tbc2>);
    function TryReadBlock(ASkip: Integer; out ABlock: Tbc2): Boolean;
    function ReadBlocksAsBytes(ASkipBlocks: Integer;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Integer;
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

procedure TBlockchainTET.DoClose;
begin
  if FIsOpened then
  begin
    CloseFile(FFile);
    FIsOpened := False;
    FLock.Leave;
  end;
end;

function TBlockchainTET.DoOpen: Boolean;
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

function TBlockchainTET.GetBlocksCount: Integer;
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

function TBlockchainTET.GetBlockSize: Integer;
begin
  Result := SizeOf(Tbc2);
end;

function TBlockchainTET.ReadBlocks(ASkip, ANumber: Integer): TArray<Tbc2>;
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

function TBlockchainTET.ReadBlocksAsBytes(ASkipBlocks, ANumber: Integer): TBytes;
begin
  Result := [];
  FLock.Enter;
  FFileStream := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
  try
    if (ASkipBlocks * GetBlockSize > FFileStream.Size - GetBlockSize) or
      (ASkipBlocks < 0) then
      exit;
    FFileStream.Seek(ASkipBlocks * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber * GetBlockSize,
      FFileStream.Size - FFileStream.Position));
    FFileStream.Read(Result, Length(Result));
  finally
    FFileStream.Free;
    FLock.Leave;
  end;
end;

function TBlockchainTET.TryReadBlock(ASkip: Integer; out ABlock: Tbc2): Boolean;
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

procedure TBlockchainTET.WriteBlock(ASkip: Integer; ABlock: Tbc2);
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

//procedure TBlockchainTET.WriteBlocks(ASkip: Integer; ABlocks: TArray<Tbc2>);
//var
//  NeedClose: Boolean;
//  i: Integer;
//begin
//  if ASkip < 0 then
//    exit;
//
//  NeedClose := DoOpen;
//  try
//    Seek(FFile, ASkip);
//    for i := 0 to Length(ABlocks) - 1 do
//      Write(FFile, ABlocks[i]);
//  finally
//    if NeedClose then
//      DoClose;
//  end;
//end;

procedure TBlockchainTET.WriteBlocksAsBytes(ASkipBlocks: Integer; ABytes: TBytes);
begin
  if (Length(ABytes) mod GetBlockSize <> 0) or (ASkipBlocks < 0) then
    exit;

  FLock.Enter;
  FFileStream := TFileStream.Create(FullPath, fmOpenWrite);
  try
    FFileStream.Seek(ASkipBlocks * GetBlockSize, soBeginning);
    FFileStream.Write(ABytes, Length(ABytes));
  finally
    FFileStream.Free;
    FLock.Leave;
  end;
end;

end.
