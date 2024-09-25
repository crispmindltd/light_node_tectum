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
  TBlockchainTETDynamic = class(TChainFileWorker)
  private
    FFile: TFileStream;
    FIsOpened: Boolean;
  public
    constructor Create;
    destructor Destory;
    function DoOpen(AMode: Word): Boolean;
    procedure DoClose;

    function GetBlockSize: Integer; override;
    function GetBlocksCount: Int64; override;
    procedure WriteBlock(ASkip: Int64; ABlock: TTokenBase);
    procedure WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes); override;
    procedure WriteBlocks(ASkip: Int64; ABlocks: TArray<TTokenBase>);
    function TryReadBlock(ASkip: Int64; out ABlock: TTokenBase): Boolean;
    function ReadBlocksAsBytes(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TBytes; override;
    function ReadBlocks(ASkip: Int64;
      ANumber: Integer = MaxBlocksNumber): TArray<TTokenBase>;

//    function TryGetTETAddress(const AOwnerID: Int64; out ATETAddress: String): Boolean;
//    function TryGetTokenBase(AOwnerID: Int64; out AID: Integer;
//      out tb: TTokenBase): Boolean; overload;
//    function TryGetTokenBase(ATETAddress: String; out AID: Integer;
//      out tb: TTokenBase): Boolean; overload;
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
    FFile.Free;
    FLock.Leave;
    FIsOpened := False;
  end;
end;

function TBlockchainTETDynamic.DoOpen(AMode: Word): Boolean;
begin
  Result := not FIsOpened;
  if Result then
  begin
    FLock.Enter;
    FFile := TFileStream.Create(FullPath, AMode);
    FIsOpened := True;
  end;
end;

function TBlockchainTETDynamic.GetBlocksCount: Int64;
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

function TBlockchainTETDynamic.GetBlockSize: Integer;
begin
  Result := SizeOf(TTokenBase);
end;

function TBlockchainTETDynamic.ReadBlocks(ASkip: Int64;
  ANumber: Integer): TArray<TTokenBase>;
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

function TBlockchainTETDynamic.ReadBlocksAsBytes(ASkip: Int64;
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

function TBlockchainTETDynamic.TryReadBlock(ASkip: Int64;
  out ABlock: TTokenBase): Boolean;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenRead or fmShareDenyNone);
  try
    Result := (ASkip >= 0) and (ASkip < GetBlocksCount);
    if Result then
    begin
      FFile.Seek(ASkip * GetBlockSize, soBeginning);
      FFile.ReadData<TTokenBase>(ABlock);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTETDynamic.WriteBlock(ASkip: Int64; ABlock: TTokenBase);
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    FFile.WriteData<TTokenBase>(ABlock);
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTETDynamic.WriteBlocks(ASkip: Int64;
  ABlocks: TArray<TTokenBase>);
var
  i: Integer;
  NeedClose: Boolean;
begin
  NeedClose := DoOpen(fmOpenWrite);
  try
    FFile.Seek(ASkip * GetBlockSize, soBeginning);
    for i := 0 to Length(ABlocks) - 1 do
      FFile.WriteData<TTokenBase>(ABlocks[i]);
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTETDynamic.WriteBlocksAsBytes(ASkip: Int64;
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

//function TBlockchainTETDynamic.TryGetTETAddress(const AOwnerID: Int64;
//  out ATETAddress: String): Boolean;
//var
//  i: Integer;
//  tb: TTokenBase;
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
//      if (tb.OwnerID = AOwnerID) and (tb.TokenDatID = 1) then
//      begin
//        ATETAddress := tb.Token;
//        Exit(True);
//      end;
//    end;
//  finally
//    CloseFile(FFile);
//    FLock.Leave;
//  end;
//end;

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

//function TBlockchainTETDynamic.TryGetTokenBase(AOwnerID: Int64; out AID: Integer;
//  out tb: TTokenBase): Boolean;
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
//      if (tb.OwnerID = AOwnerID) and (tb.TokenDatID = 1) then
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
