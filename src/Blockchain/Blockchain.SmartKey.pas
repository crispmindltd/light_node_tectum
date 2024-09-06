unit Blockchain.SmartKey;

interface

uses
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Math,
  SysUtils;

type
  TBlockchainSmartKey = class(TChainFileWorker)
  private
    FFile: file of TCSmartKey;
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

    function TryGetSmartKey(ATicker: String; var sk: TCSmartKey): Boolean;
  end;

implementation

{ TBlockchainSmartKey }

constructor TBlockchainSmartKey.Create(AFileName: String);
begin
  inherited Create('smartc',AFileName,True);

end;

destructor TBlockchainSmartKey.Destory;
begin

  inherited;
end;

function TBlockchainSmartKey.GetBlocksCount: Integer;
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

function TBlockchainSmartKey.GetBlockSize: Integer;
begin
  Result := SizeOf(TCSmartKey);
end;

function TBlockchainSmartKey.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  TCSkey: TCSmartKey;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,AFrom);
    Read(FFile,TCSkey);
    Move(TCSkey, Result[0], GetBlockSize);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainSmartKey.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  TCSkey: TCSmartKey;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,TCSkey);
      Move(TCSkey, Result[i * SizeOf(TCSmartKey)], SizeOf(TCSkey));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainSmartKey.TryGetSmartKey(ATicker: String;
  var sk: TCSmartKey): Boolean;
var
  i: Integer;
begin
  Result := False;
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    for i := 0 to FileSize(FFile)-1 do
    begin
      Seek(FFile,i);
      Read(FFile,sk);
      if sk.Abreviature = ATicker then Exit(True);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainSmartKey.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  TCSkey: TCSmartKey;
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
      Read(FFile,TCSkey);
      Move(TCSkey, Result[i * SizeOf(TCSmartKey)], SizeOf(TCSkey));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainSmartKey.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  i: Integer;
  TCSkeyArr: array[0..SizeOf(TCSmartKey)-1] of Byte;
  TCSkey: TCSmartKey absolute TCSkeyArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(TCSkey)],TCSkeyArr[0],SizeOf(TCSkey));
      Write(FFile,TCSkey);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainSmartKey.WriteOneBlock(APos: Int64;
  ABytes: TOneBlockBytes);
var
  TCSkeyArr: array[0..SizeOf(TCSmartKey)-1] of Byte;
  TCSkey: TCSmartKey absolute TCSkeyArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    Move(ABytes[0],TCSkeyArr[0],SizeOf(TCSkey));
    Write(FFile,TCSkey);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

end.
