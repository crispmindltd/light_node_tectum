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
  public
    constructor Create(AFileName: String);
    destructor Destory;

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

function TBlockchainTokenDynamic.GetBlocksCount: Integer;
begin
  FLock.Enter;
  try
    try
      AssignFile(FFile, FFullFilePath);
      Reset(FFile);
      try
        Result := FileSize(FFile);
      finally
        CloseFile(FFile);
      end;
    except
      Result := 0;
    end;
  finally
    FLock.Leave;
  end;
end;

function TBlockchainTokenDynamic.GetBlockSize: Integer;
begin
  Result := SizeOf(TCTokensBase);
end;

function TBlockchainTokenDynamic.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  tcb: TCTokensBase;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,AFrom);
    Read(FFile,tcb);
    Move(tcb, Result[0], GetBlockSize);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTokenDynamic.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  tcb: TCTokensBase;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,tcb);
      Move(tcb, Result[i * SizeOf(TCTokensBase)], SizeOf(tcb));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTokenDynamic.TryGetTokenBase(ATETAddress: String;
  out AID: Integer; out tcb: TCTokensBase): Boolean;
var
  i: Integer;
begin
  FLock.Enter;
  Result := False;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
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
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTokenDynamic.TryGetTokenBase(AOwnerID: Int64;
  out AID: Integer; out tcb: TCTokensBase): Boolean;
var
  i: Integer;
begin
  FLock.Enter;
  Result := False;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
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
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTokenDynamic.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  tcb: TCTokensBase;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
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
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainTokenDynamic.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  i: Integer;
  tcbArr: array[0..SizeOf(TCTokensBase)-1] of Byte;
  tcb: TCTokensBase absolute tcbArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(tcb)],tcbArr[0],SizeOf(tcb));
      Write(FFile,tcb);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainTokenDynamic.WriteOneBlock(APos: Int64;
  ABytes: TOneBlockBytes);
var
  tcbArr: array[0..SizeOf(TCTokensBase)-1] of Byte;
  tcb: TCTokensBase absolute tcbArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    Move(ABytes[0],tcbArr[0],SizeOf(tcb));
    Write(FFile,tcb);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

end.
