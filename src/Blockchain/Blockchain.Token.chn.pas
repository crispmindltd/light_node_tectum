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

    function TryFindBlockByHash(AHash: string; out ABlockNum: Integer;
      out ABlock: Tbc2): Boolean;
    function TryGetBlock(ABlockNum: Integer; out ABlock: Tbc2): Boolean;
  end;

implementation

{ TBlockchainTokenDBC }

constructor TBlockchainTokenCHN.Create(AFileName: String);
begin
  inherited Create(ConstStr.DBCPath, AFileName,True);

  FIsOpened := False;
end;

destructor TBlockchainTokenCHN.Destory;
begin

  inherited;
end;

procedure TBlockchainTokenCHN.DoClose;
begin
  if FIsOpened then
  begin
    CloseFile(FFile);
    FIsOpened := False;
    FLock.Leave;
  end;
end;

function TBlockchainTokenCHN.DoOpen: Boolean;
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

function TBlockchainTokenCHN.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  NeedClose: Boolean;
  i: Integer;
  bc2: Tbc2;
begin
  NeedClose := DoOpen;
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
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenCHN.GetBlocksCount: Integer;
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

function TBlockchainTokenCHN.GetBlockSize: Integer;
begin
  Result := SizeOf(Tbc2);
end;

function TBlockchainTokenCHN.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  NeedClose: Boolean;
  bc2: Tbc2;
begin
  NeedClose := DoOpen;
  try
    Seek(FFile,AFrom);
    Read(FFile,bc2);
    Move(bc2, Result[0], GetBlockSize);
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenCHN.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  NeedClose: Boolean;
  i: Integer;
  bc2: Tbc2;
begin
  NeedClose := DoOpen;
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,bc2);
      Move(bc2, Result[i * SizeOf(Tbc2)], SizeOf(bc2));
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenCHN.TryFindBlockByHash(AHash: string;
  out ABlockNum: Integer; out ABlock: Tbc2): Boolean;
var
  NeedClose: Boolean;
  HashHex: string;
  i, j: Integer;
begin
  Result := False;
  NeedClose := DoOpen;
  try
    Seek(FFile, 0);
    for i := FileSize(FFile) - 1 downto 0 do
    begin
      Read(FFile, ABlock);
      HashHex := '';
      ABlockNum := FileSize(FFile) - i - 1;
      for j := 1 to TokenLength do
        HashHex := HashHex + IntToHex(ABlock.Hash[j], 2);
      Result := HashHex.ToLower = AHash.ToLower;
      if Result then
        exit;
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

function TBlockchainTokenCHN.TryGetBlock(ABlockNum: Integer;
  out ABlock: Tbc2): Boolean;
var
  NeedClose: Boolean;
begin
  NeedClose := DoOpen;
  try
    Result := FileSize(FFile) - 1 >= ABlockNum;
    if Result then
    begin
      Seek(FFile, ABlockNum);
      Read(FFile, ABlock);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTokenCHN.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  NeedClose: Boolean;
  i: Integer;
  bc2Arr: array[0..SizeOf(Tbc2)-1] of Byte;
  bc2: Tbc2 absolute bc2Arr;
begin
  NeedClose := DoOpen;
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(bc2)],bc2Arr[0],SizeOf(bc2));
      Write(FFile,bc2);
    end;
  finally
    if NeedClose then
      DoClose;
  end;
end;

procedure TBlockchainTokenCHN.WriteOneBlock(APos: Int64;
  ABytes: TOneBlockBytes);
var
  NeedClose: Boolean;
  bc2Arr: array[0..SizeOf(Tbc2)-1] of Byte;
  bc2: Tbc2 absolute bc2Arr;
begin
  NeedClose := DoOpen;
  try
    Seek(FFile,APos);
    Move(ABytes[0],bc2Arr[0],SizeOf(bc2));
    Write(FFile,bc2);
  finally
    if NeedClose then
      DoClose;
  end;
end;

end.
