unit Blockchain.TETDynamic;

interface

uses
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Math;

type
  TBlockchainTETDynamic = class(TChainFileWorker)
  private
    FFile: file of TTokenBase;
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

    function TryGetTETAddress(const AOwnerID: Int64; out ATETAddress: String): Boolean;
    function TryGetTokenBase(AOwnerID: Int64; out AID: Integer;
      out tb: TTokenBase): Boolean; overload;
    function TryGetTokenBase(ATETAddress: String; out AID: Integer;
      out tb: TTokenBase): Boolean; overload;
  end;

implementation

{ TBlockchainDynamic }

constructor TBlockchainTETDynamic.Create(AFileName: String);
begin
  inherited Create('DBC',AFileName);

end;

destructor TBlockchainTETDynamic.Destory;
begin

  inherited;
end;

function TBlockchainTETDynamic.GetBlocksCount: Integer;
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

function TBlockchainTETDynamic.GetBlockSize: Integer;
begin
  Result := SizeOf(TTokenBase);
end;

function TBlockchainTETDynamic.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  tb: TTokenBase;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,AFrom);
    Read(FFile,tb);
    Move(tb, Result[0], GetBlockSize);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTETDynamic.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  tb: TTokenBase;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,tb);
      Move(tb, Result[i * SizeOf(TTokenBase)], SizeOf(tb));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTETDynamic.TryGetTETAddress(const AOwnerID: Int64;
  out ATETAddress: String): Boolean;
var
  i: Integer;
  tb: TTokenBase;
begin
  FLock.Enter;
  Result := False;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    for i := 0 to FileSize(FFile)-1 do
    begin
      Seek(FFile,i);
      Read(FFile,tb);
      if (tb.OwnerID = AOwnerID) and (tb.TokenDatID = 1) then
      begin
        ATETAddress := tb.Token;
        Exit(True);
      end;
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainTETDynamic.TryGetTokenBase(ATETAddress: String;
  out AID: Integer; out tb: TTokenBase): Boolean;
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
      Read(FFile,tb);
      if (tb.Token = ATETAddress) and (tb.TokenDatID = 1) then
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

function TBlockchainTETDynamic.TryGetTokenBase(AOwnerID: Int64; out AID: Integer;
  out tb: TTokenBase): Boolean;
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
      Read(FFile,tb);
      if (tb.OwnerID = AOwnerID) and (tb.TokenDatID = 1) then
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

function TBlockchainTETDynamic.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  tb: TTokenBase;
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
      Read(FFile,tb);
      Move(tb, Result[i * SizeOf(TTokenBase)], SizeOf(tb));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainTETDynamic.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  i: Integer;
  tbArr: array[0..SizeOf(TTokenBase)-1] of Byte;
  tb: TTokenBase absolute tbArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(tb)],tbArr[0],SizeOf(tb));
      Write(FFile,tb);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainTETDynamic.WriteOneBlock(APos: Int64;
  ABytes: TOneBlockBytes);
var
  tbArr: array[0..SizeOf(TTokenBase)-1] of Byte;
  tb: TTokenBase absolute tbArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    Move(ABytes[0],tbArr[0],SizeOf(tb));
    Write(FFile,tb);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

end.
