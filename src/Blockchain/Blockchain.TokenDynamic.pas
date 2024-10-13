unit Blockchain.TokenDynamic;

interface

uses
  App.Constants,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Math;

type
  TBlockchainTokenDynamic = class(TChainFileWorker)
  private
    FFile: file of TCTokensBase;
    FIsOpened: Boolean;
  public
    constructor Create(AFileName: String);
    destructor Destory;

    function DoOpen: Boolean; override;
    procedure DoClose; override;
    function GetBlockSize: Integer; override;
    function GetBlocksCount: Integer; override;
    function ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks; override;
    function ReadBlocks(var AAmount: Integer): TBytesBlocks; override;
    function GetOneBlock(AFrom: Int64): TOneBlockBytes; override;
    procedure WriteBlocks(APos: Int64; ABytes: TBytesBlocks; AAmount: Integer); override;
    procedure WriteOneBlock(APos: Int64; ABytes: TOneBlockBytes); override;

    function TryGetTokenBase(AOwnerID: Int64; out AID: Integer;
      out tcb: TCTokensBase): Boolean; overload;
    function TryGetTokenBase(ATETAddress: String; out AID: Integer;
      out tcb: TCTokensBase): Boolean; overload;
  end;

implementation

{ TBlockchainDynamic }

constructor TBlockchainTokenDynamic.Create(AFileName: String);
begin
  inherited Create(ConstStr.SmartCPath, AFileName);

end;

destructor TBlockchainTokenDynamic.Destory;
begin

  inherited;
end;

procedure TBlockchainTokenDynamic.DoClose;
begin
  if FIsOpened then
  begin
    CloseFile(FFile);
    FIsOpened := False;
    FLock.Leave;
  end;
end;

function TBlockchainTokenDynamic.DoOpen: Boolean;
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

function TBlockchainTokenDynamic.GetBlocksCount: Integer;
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

function TBlockchainTokenDynamic.GetBlockSize: Integer;
begin
  Result := SizeOf(TCTokensBase);
end;

function TBlockchainTokenDynamic.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  NeedClose: Boolean;
  tcb: TCTokensBase;
begin
  NeedClose := DoOpen;
  try
    Seek(FFile,AFrom);
    Read(FFile,tcb);
    Move(tcb, Result[0], GetBlockSize);
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenDynamic.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  NeedClose: Boolean;
  i: Integer;
  tcb: TCTokensBase;
begin
  NeedClose := DoOpen;
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,tcb);
      Move(tcb, Result[i * SizeOf(TCTokensBase)], SizeOf(tcb));
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenDynamic.TryGetTokenBase(ATETAddress: String;
  out AID: Integer; out tcb: TCTokensBase): Boolean;
var
  NeedClose: Boolean;
  i: Integer;
begin
  Result := False;
  NeedClose := DoOpen;
  try
    for i := 0 to FileSize(FFile)-1 do
    begin
      Seek(FFile,i);
      Read(FFile,tcb);
      if tcb.Token = ATETAddress then
      begin
        AID := i;
        Exit(True);
      end;
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenDynamic.TryGetTokenBase(AOwnerID: Int64;
  out AID: Integer; out tcb: TCTokensBase): Boolean;
var
  NeedClose: Boolean;
  i: Integer;
begin
  Result := False;
  NeedClose := DoOpen;
  try
    for i := 0 to FileSize(FFile)-1 do
    begin
      Seek(FFile,i);
      Read(FFile,tcb);
      if tcb.OwnerID = AOwnerID then
      begin
        AID := i;
        Exit(True);
      end;
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenDynamic.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  NeedClose: Boolean;
  i: Integer;
  tcb: TCTokensBase;
begin
  NeedClose := DoOpen;
  try
    if AFrom >= FileSize(FFile) then
    begin
      AAmount := 0;
      exit;
    end;

    Seek(FFile,AFrom);
    AAmount := Min(FileSize(FFile)-AFrom,MAX_BLOCKS_REQUEST);
    AAmount := Max(0,AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,tcb);
      Move(tcb, Result[i * SizeOf(TCTokensBase)], SizeOf(tcb));
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTokenDynamic.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  NeedClose: Boolean;
  i: Integer;
  tcbArr: array[0..SizeOf(TCTokensBase)-1] of Byte;
  tcb: TCTokensBase absolute tcbArr;
begin
  NeedClose := DoOpen;
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(tcb)],tcbArr[0],SizeOf(tcb));
      Write(FFile,tcb);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTokenDynamic.WriteOneBlock(APos: Int64;
  ABytes: TOneBlockBytes);
var
  NeedClose: Boolean;
  tcbArr: array[0..SizeOf(TCTokensBase)-1] of Byte;
  tcb: TCTokensBase absolute tcbArr;
begin
  NeedClose := DoOpen;
  try
    Seek(FFile,APos);
    Move(ABytes[0],tcbArr[0],SizeOf(tcb));
    Write(FFile,tcb);
  finally
    if NeedClose then
      DoClose;
  end;
end;

end.
