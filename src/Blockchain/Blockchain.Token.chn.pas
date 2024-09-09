unit Blockchain.Token.chn;

interface

uses
  App.Constants,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Math,
  SyncObjs,
  SysUtils;

type
  TBlockchainTokenCHN = class(TChainFileWorker)
  private
    FFile: file of Tbc2;
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
  end;

implementation

{ TBlockchainTokenDBC }

constructor TBlockchainTokenCHN.Create(AFileName: String);
begin
  inherited Create(ConstStr.DBCPath, AFileName,True);

end;

destructor TBlockchainTokenCHN.Destory;
begin

  inherited;
end;

function TBlockchainTokenCHN.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  bc2: Tbc2;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,AFrom);
    AAmount := Min(FileSize(FFile)-AFrom,MAX_BLOCKS_REQUEST);
    AAmount := Max(0,AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,bc2);
      Move(bc2, Result[i * SizeOf(Tbc2)], SizeOf(bc2));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTokenCHN.GetBlocksCount: Integer;
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

function TBlockchainTokenCHN.GetBlockSize: Integer;
begin
  Result := SizeOf(Tbc2);
end;

function TBlockchainTokenCHN.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  bc2: Tbc2;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,AFrom);
    Read(FFile,bc2);
    Move(bc2, Result[0], GetBlockSize);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTokenCHN.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  bc2: Tbc2;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,bc2);
      Move(bc2, Result[i * SizeOf(Tbc2)], SizeOf(bc2));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainTokenCHN.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  i: Integer;
  bc2Arr: array[0..SizeOf(Tbc2)-1] of Byte;
  bc2: Tbc2 absolute bc2Arr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(bc2)],bc2Arr[0],SizeOf(bc2));
      Write(FFile,bc2);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainTokenCHN.WriteOneBlock(APos: Int64;
  ABytes: TOneBlockBytes);
var
  bc2Arr: array[0..SizeOf(Tbc2)-1] of Byte;
  bc2: Tbc2 absolute bc2Arr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    Move(ABytes[0],bc2Arr[0],SizeOf(bc2));
    Write(FFile,bc2);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

end.
