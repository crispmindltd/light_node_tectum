unit Blockchain.ICODat;

interface

uses
  App.Constants,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  System.SyncObjs,
  System.Math;

type
  TBlockchainICODat = class(TChainFileWorker)
  private
    FFile: file of TTokenICODat;
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

    function TryGetTokenICO(AFrom: Int64; var ICOBlock: TTokenICODat): Boolean; overload;
    function TryGetTokenICO(ATicker: String; var ICOBlock: TTokenICODat): Boolean; overload;
  end;

implementation

{ TBlockchainDynamic }

constructor TBlockchainICODat.Create(AFileName: String);
begin
  inherited Create(ConstStr.DBCPath, AFileName);

end;

destructor TBlockchainICODat.Destory;
begin

  inherited;
end;

function TBlockchainICODat.GetBlocksCount: Integer;
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

function TBlockchainICODat.GetBlockSize: Integer;
begin
  Result := SizeOf(TTokenICODat);
end;

function TBlockchainICODat.GetOneBlock(AFrom: Int64): TOneBlockBytes;
var
  tico: TTokenICODat;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,AFrom);
    Read(FFile,tico);
    Move(tico, Result[0], GetBlockSize);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainICODat.ReadBlocks(var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  tico: TTokenICODat;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    AAmount := Max(0,Min(FileSize(FFile),Min(MAX_BLOCKS_REQUEST,AAmount)));
    Seek(FFile,FileSize(FFile)-AAmount);
    for i := 0 to AAmount-1 do
    begin
      Read(FFile,tico);
      Move(tico, Result[i * SizeOf(TTokenICODat)], SizeOf(tico));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainICODat.TryGetTokenICO(ATicker: String;
  var ICOBlock: TTokenICODat): Boolean;
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
      Read(FFile,ICOBlock);
      if (ICOBlock.Abreviature = ATicker) then
        Exit(True);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainICODat.TryGetTokenICO(AFrom: Int64;
  var ICOBlock: TTokenICODat): Boolean;
begin
  FLock.Enter;
  Result := False;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    if AFrom >= FileSize(FFile) then Exit(False);

    Seek(FFile,AFrom);
    Read(FFile,ICOBlock);
    Result := True;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

function TBlockchainICODat.ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks;
var
  i: Integer;
  tico: TTokenICODat;
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
      Read(FFile,tico);
      Move(tico, Result[i * SizeOf(TTokenICODat)], SizeOf(tico));
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainICODat.WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
  AAmount: Integer);
var
  i: Integer;
  ticoArr: array[0..SizeOf(TTokenICODat)-1] of Byte;
  tico: TTokenICODat absolute ticoArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    AAmount := Max(AAmount,0);                  // <=0
    for i := 0 to AAmount - 1 do
    begin
      Move(ABytes[i*SizeOf(tico)],ticoArr[0],SizeOf(tico));
      Write(FFile,tico);
    end;
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

procedure TBlockchainICODat.WriteOneBlock(APos: Int64; ABytes: TOneBlockBytes);
var
  ticoArr: array[0..SizeOf(TTokenICODat)-1] of Byte;
  tico: TTokenICODat absolute ticoArr;
begin
  FLock.Enter;
  AssignFile(FFile, FFullFilePath);
  Reset(FFile);
  try
    Seek(FFile,APos);
    Move(ABytes[0],ticoArr[0],SizeOf(tico));
    Write(FFile,tico);
  finally
    CloseFile(FFile);
    FLock.Leave;
  end;
end;

end.
