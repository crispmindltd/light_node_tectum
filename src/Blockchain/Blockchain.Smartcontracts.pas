unit Blockchain.Smartcontracts;

interface

uses
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Math,
  SysUtils;

type
  TBlockchainSmart = class(TChainFileWorker)
  private
    FFile: file of TCbc4;
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

constructor TBlockchainSmart.Create(AFileName: String);
begin
  inherited Create('SmartC',AFileName);

end;

destructor TBlockchainSmart.Destory;
begin

  inherited;
end;

function TBlockchainSmart.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  Cbc4: TCbc4;
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
      Read(FFile,Cbc4);
      Move(Cbc4, Result[i * SizeOf(TCbc4)], SizeOf(Cbc4));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainSmart.GetBlocksCount: Integer;
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

function TBlockchainSmart.GetBlockSize: Integer;
begin
  Result := SizeOf(TCbc4);
end;

function TBlockchainSmart.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  Cbc4: TCbc4;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,AFrom);
    Read(FFile,Cbc4);
    Move(Cbc4, Result[0], GetBlockSize);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainSmart.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  Cbc4: TCbc4;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,Cbc4);
      Move(Cbc4, Result[i * SizeOf(TCbc4)], SizeOf(Cbc4));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainSmart.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  i: Integer;
  bc4Arr: array[0..SizeOf(TCbc4)-1] of Byte;
  bc4: TCbc4 absolute bc4Arr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(bc4)],bc4Arr[0],SizeOf(bc4));
      Write(FFile,bc4);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainSmart.WriteOneBlock(APos: Int64; ABytes: TOneBlockBytes);
var
  bc4Arr: array[0..SizeOf(TCbc4)-1] of Byte;
  bc4: TCbc4 absolute bc4Arr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    Move(ABytes[0],bc4Arr[0],SizeOf(bc4));
    Write(FFile,bc4);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

end.
