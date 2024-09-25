unit Blockchain.Intf;

interface

uses
  IOUtils,
  SyncObjs,
  SysUtils;

const
  MaxBlocksNumber = 3000; // max blocks number per request
  OneBlockSize = 316;
  // SMART_BLOCK_SIZE_DEFAULT = 256;
  // DYNAMIC_BLOCK_SIZE_DEFAULT = 72;

type
  TChainFileWorker = class abstract
  private
    FSyncByDefault: Boolean;
  protected
    FFileName: String;
    FFileFolder: String;
    FFullFilePath: String;
    FLock: TCriticalSection;
  public
    constructor Create(AFolder, AFileName: String;
      AIsSystemChain: Boolean = False);
    destructor Destroy; override;

    function GetBlockSize: Integer; virtual; abstract;
    function GetBlocksCount: Int64; virtual; abstract;
    procedure WriteBlocksAsBytes(ASkip: Int64; ABytes: TBytes); virtual; abstract;
    function ReadBlocksAsBytes(ASkip: Int64; ANumber: Integer): TBytes; virtual; abstract;

    property Name: String read FFileName;
    property FullPath: String read FFullFilePath;
    property IsSyncDefault: Boolean read FSyncByDefault;
  end;

implementation

{ TChainFileWorker }

constructor TChainFileWorker.Create(AFolder, AFileName: String;
  AIsSystemChain: Boolean);
begin
  FSyncByDefault := AIsSystemChain;
  FFileName := AFileName;
  FFileFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), AFolder);
  if not DirectoryExists(FFileFolder) then
    TDirectory.CreateDirectory(FFileFolder);
  FFullFilePath := TPath.Combine(FFileFolder, AFileName);

  FLock := TCriticalSection.Create;
end;

destructor TChainFileWorker.Destroy;
begin
  FLock.Free;

  inherited;
end;

end.
