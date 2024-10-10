unit Blockchain.Intf;

interface

uses
  IOUtils,
  SyncObjs,
  SysUtils;

const
  MAX_BLOCKS_REQUEST = 300;   //blocks amount per request
  BLOCK_SIZE_MAX = 316;       //bytes
  SMART_BLOCK_SIZE_DEFAULT = 256;
  DYNAMIC_BLOCK_SIZE_DEFAULT = 72;

type
  TBytesBlocks = array[0..MAX_BLOCKS_REQUEST * BLOCK_SIZE_MAX] of Byte;
  TOneBlockBytes = array[0..BLOCK_SIZE_MAX-1] of Byte;

  TChainFileWorker = class abstract
  private
    FIsSystemChain: Boolean;
  protected
    FFileName: String;
    FFileFolder: String;
    FFullFilePath: String;
    FLock: TCriticalSection;
  public
    constructor Create(AFolder,AFileName: String;
      AIsSystemChain: Boolean = False);
    destructor Destroy; override;

    function DoOpen: Boolean; virtual; abstract;
    procedure DoClose; virtual; abstract;
    function GetBlockSize: Integer; virtual; abstract;
    function GetBlocksCount: Integer; virtual; abstract;
    function ReadBlocks(AFrom: Int64; var AAmount: Integer): TBytesBlocks; overload; virtual; abstract;
    function ReadBlocks(var AAmount: Integer): TBytesBlocks; overload; virtual; abstract;   //geting last blocks
    function GetOneBlock(AFrom: Int64): TOneBlockBytes; virtual; abstract;
    procedure WriteBlocks(APos: Int64; ABytes: TBytesBlocks;
      AAmount: Integer); virtual; abstract;
    procedure WriteOneBlock(APos: Int64; ABytes: TOneBlockBytes); virtual; abstract;

    property Name: String read FFileName;
    property IsSystemChain: Boolean read FIsSystemChain;
  end;

implementation

{ TChainFileWorker }

constructor TChainFileWorker.Create(AFolder,AFileName: String;
  AIsSystemChain: Boolean);
begin
  FIsSystemChain := AIsSystemChain;
  FFileName := AFileName;
  FFileFolder := TPath.Combine(ExtractFilePath(ParamStr(0)),AFolder);
  if not DirectoryExists(FFileFolder) then TDirectory.CreateDirectory(FFileFolder);
  FFullFilePath := TPath.Combine(FFileFolder,AFileName);
  if not FileExists(FFullFilePath) then TFile.WriteAllBytes(FFullFilePath,[]);

  FLock := TCriticalSection.Create;
end;

destructor TChainFileWorker.Destroy;
begin
  FLock.Free;

  inherited;
end;

end.
