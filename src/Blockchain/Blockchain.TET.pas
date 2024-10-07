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
    FIsOpened: Boolean;
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
  inherited Create(ConstStr.DBCPath, ConstStr.TokenCHNFileName);

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
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(Tbc2) - 1] of Byte;
  Tbc2Block: Tbc2 absolute BlockBytes;
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
      Read(FFile, Tbc2Block);
      Move(BlockBytes[0], Result[i * GetBlockSize], GetBlockSize);
    end;
  finally
    if NeedClose then
      DoClose;
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
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(Tbc2) - 1] of Byte;
  Tbc2Block: Tbc2 absolute BlockBytes;
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
      Write(FFile, Tbc2Block);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

end.
