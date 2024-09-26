unit Blockchain.TokenDynamic;

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
  TBlockchainTokenDynamic = class(TChainFileWorker)
  private
    FFile: TFileStream;
    FIsOpened: Boolean;
  public
    constructor Create(ATokenID: Integer);
    destructor Destory;

    function DoOpen(AMode: Word): Boolean;
    procedure DoClose;
    function GetBlockSize: Integer; override;
    function GetBlocksCount: Int64; override;
    procedure WriteBlock(ASkip: Int64; ABlock: TCTokensBase);
    procedure WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes); override;
    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<TCTokensBase>);
    function TryReadBlock(ASkip: Int64; out ABlock: TCTokensBase): Boolean;
    function ReadBlocksAsBytes(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TArray<TCTokensBase>;

//    function TryGetTokenBase(AOwnerID: Int64; out AID: Integer;
//      out tcb: TCTokensBase): Boolean;
  end;

implementation

{ TBlockchainTokenDynamic }

constructor TBlockchainTokenDynamic.Create(ATokenID: Integer);
begin
  inherited Create(ConstStr.SmartCPath, ATokenID.ToString + '.tkn');

end;

destructor TBlockchainTokenDynamic.Destory;
begin

  inherited;
end;

procedure TBlockchainTokenDynamic.DoClose;
begin
  if FIsOpened then
  begin
    FFile.Free;
    FLock.Leave;
    FIsOpened := False;
  end;
end;

function TBlockchainTokenDynamic.DoOpen(AMode: Word): Boolean;
begin
  Result := not FIsOpened;
  if Result then
  begin
    FLock.Enter;
    if not FileExists(FFullFilePath) then
      TFile.WriteAllBytes(FFullFilePath, []);
    FFile := TFileStream.Create(FullPath, AMode);
    FIsOpened := True;
  end;
end;

function TBlockchainTokenDynamic.GetBlocksCount: Int64;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenRead or fmShareDenyNone);
  try
    Result := FFile.Size div GetBlockSize;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenDynamic.GetBlockSize: Integer;
begin
  Result := SizeOf(TCTokensBase);
end;

//function TBlockchainTokenDynamic.TryGetTokenBase(AOwnerID: Int64;
//  out AID: Integer; out tcb: TCTokensBase): Boolean;
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
//      Read(FFile,tcb);
//      if tcb.OwnerID = AOwnerID then
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

function TBlockchainTokenDynamic.TryReadBlock(ASkip: Int64;
  out ABlock: TCTokensBase): Boolean;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenRead or fmShareDenyNone);
  try
    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
    if Result then
    begin
      FFile.Seek(ASkip * GetBlockSize, soBeginning);
      FFile.ReadData<TCTokensBase>(ABlock);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenDynamic.ReadBlocks(ASkip: Int64;
  ANumber: Integer): TArray<TCTokensBase>;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenRead or fmShareDenyNone);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber * GetBlockSize, FFile.Size - FFile.Position));
    FFile.Read(Result, Length(Result));
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenDynamic.ReadBlocksAsBytes(ASkip: Int64;
  ANumber: Integer): TBytes;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenRead or fmShareDenyNone);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    SetLength(Result, Min(ANumber * GetBlockSize, FFile.Size - FFile.Position));
    FFile.Read(Result, Length(Result));
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTokenDynamic.WriteBlock(ASkip: Int64; ABlock: TCTokensBase);
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.WriteData<TCTokensBase>(ABlock);
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTokenDynamic.WriteBlocks(ASkip: Int64;
  ABlocks: TArray<TCTokensBase>);
var
  i: Integer;
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    for i := 0 to Length(ABlocks) - 1 do
      FFile.WriteData<TCTokensBase>(ABlocks[i]);
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTokenDynamic.WriteBlocksAsBytes(ASkip: Int64;
  ABytes: TBytes);
var
  NeedClose: Boolean;
begin
  if Length(ABytes) mod GetBlockSize <> 0 then
    exit;

  NeedClose := DoOpen(fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.Write(ABytes, Length(ABytes));
  finally
    if NeedClose then
      DoClose;
  end;
end;

end.
