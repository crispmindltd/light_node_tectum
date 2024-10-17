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
  TBlockchainToken = class(TChainFileBase)
  private
    FFile: file of TCbc4;
    FIsOpened: Boolean;

//    function TryReadBlock(ASkip: Int64; out ABlock: TCbc4): Boolean;
//    procedure WriteBlock(ASkip: Int64; ABlock: TCbc4);
//    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<TCbc4>);
  public
    constructor Create(ATokenID: Integer);
    destructor Destroy;
    function DoOpen: Boolean;
    procedure DoClose;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Integer; override;
    procedure WriteBlocksAsBytes(ASkipBlocks: Integer; ABytes: TBytes); override;
    function ReadBlocksAsBytes(ASkipBlocks: Integer;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Integer;
      ANumber: Integer = MaxBlocksNumber): TArray<TCbc4>;
  end;

implementation

{ TBlockchainToken }

constructor TBlockchainToken.Create(ATokenID: Integer);
begin
  inherited Create(ConstStr.SmartCPath, ATokenID.ToString + '.chn');

  FIsOpened := False;
end;

destructor TBlockchainToken.Destroy;
begin

  inherited;
end;

procedure TBlockchainToken.DoClose;
begin
  if FIsOpened then
  begin
    CloseFile(FFile);
    FIsOpened := False;
    FLock.Leave;
  end;
end;

function TBlockchainToken.DoOpen: Boolean;
begin
  Result := not FIsOpened;
  if Result then
  begin
    FLock.Enter;
    if not FileExists(FFullFilePath) then
      TFile.WriteAllBytes(FFullFilePath, []);
    AssignFile(FFile, FFullFilePath);
    Reset(FFile);
    FIsOpened := True;
  end;
end;

function TBlockchainToken.GetBlocksCount: Integer;
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

function TBlockchainToken.GetBlockSize: Integer;
begin
  Result := SizeOf(TCbc4);
end;

function TBlockchainToken.ReadBlocks(ASkip, ANumber: Integer): TArray<TCbc4>;
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

function TBlockchainToken.ReadBlocksAsBytes(ASkipBlocks,
  ANumber: Integer): TBytes;
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(TCbc4) - 1] of Byte;
  TCbc4Block: TCbc4 absolute BlockBytes;
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
      Read(FFile, TCbc4Block);
      Move(BlockBytes[0], Result[i * GetBlockSize], GetBlockSize);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainToken.WriteBlocksAsBytes(ASkipBlocks: Integer;
  ABytes: TBytes);
var
  NeedClose: Boolean;
  BlockBytes: array[0..SizeOf(TCbc4) - 1] of Byte;
  TCbc4Block: TCbc4 absolute BlockBytes;
  i: Integer;
begin
  if (Length(ABytes) mod GetBlockSize <> 0) or (ASkipBlocks < 0) then
    exit;

  if not FileExists(FFullFilePath) then
    TFile.WriteAllBytes(FFullFilePath, []);
  NeedClose := DoOpen;
  try
    Seek(FFile, ASkipBlocks);
    for i := 0 to (Length(ABytes) div GetBlockSize) - 1 do
    begin
      Move(ABytes[i * GetBlockSize], BlockBytes[0], GetBlockSize);
      Write(FFile, TCbc4Block);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

//function TBlockchainToken.TryReadBlock(ASkip: Int64; out ABlock: TCbc4): Boolean;
//begin
//  FLock.Enter;
//  FFile := TFileStream.Create(FullPath, fmOpenRead or fmShareDenyNone);
//  try
//    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
//    if Result then
//    begin
//      FFile.Seek(ASkip * GetBlockSize, soBeginning);
//      FFile.ReadData<TCbc4>(ABlock);
//    end;
//  finally
//    FFile.Free;
//    FLock.Leave;
//  end;
//end;

//procedure TBlockchainToken.WriteBlock(ASkip: Int64; ABlock: TCbc4);
//begin
//  FLock.Enter;
//  if not FileExists(FFullFilePath) then
//    TFile.WriteAllBytes(FFullFilePath, []);
//
//  FFile := TFileStream.Create(FullPath, fmOpenWrite);
//  try
//    FFile.Seek(ASkip * GetBlockSize, soBeginning);
//    FFile.WriteData<TCbc4>(ABlock);
//  finally
//    FFile.Free;
//    FLock.Leave;
//  end;
//end;

//procedure TBlockchainToken.WriteBlocks(ASkip: Int64; ABlocks: TArray<TCbc4>);
//var
//  i: Integer;
//begin
//  FLock.Enter;
//  if not FileExists(FFullFilePath) then
//    TFile.WriteAllBytes(FFullFilePath, []);
//
//  FFile := TFileStream.Create(FullPath, fmOpenWrite);
//  try
//    FFile.Seek(ASkip * GetBlockSize, soBeginning);
//    for i := 0 to Length(ABlocks) - 1 do
//      FFile.WriteData<TCbc4>(ABlocks[i]);
//  finally
//    FFile.Free;
//    FLock.Leave;
//  end;
//end;

end.
