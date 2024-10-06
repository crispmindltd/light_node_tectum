unit Blockchain.Intf;

interface

uses
  Classes,
  IOUtils,
  SyncObjs,
  SysUtils;

const
  MaxBlocksNumber = 3000; // max blocks number per request
  OneBlockSize = 316;
type
  TChainFileBase = class abstract
  private
    FSyncByDefault: Boolean;
  protected
    FFileName: string;
    FFileFolder: string;
    FFullFilePath: string;
    FFileStream: TFileStream;
    FIsOpened: Boolean;
    FLock: TCriticalSection;

    function GetBlockSize: Integer; virtual; abstract;
    function GetBlocksCount: Integer; virtual; abstract;
    procedure WriteBlocksAsBytes(ASkipBlocks: Integer; ABytes: TBytes);
      virtual; abstract;
    function ReadBlocksAsBytes(ASkipBlocks: Integer;
      ANumber: Integer = MaxBlocksNumber): TBytes; virtual; abstract;
  public
    constructor Create(AFolder, AFileName: string;
      AIsSystemChain: Boolean = False);
    destructor Destroy; override;

    property Name: string read FFileName;
    property FullPath: string read FFullFilePath;
    property IsSyncDefault: Boolean read FSyncByDefault;
  end;

implementation

{ TChainFileBase }

constructor TChainFileBase.Create(AFolder, AFileName: string;
  AIsSystemChain: Boolean);
begin
  FSyncByDefault := AIsSystemChain;
  FFileName := AFileName;
  FFileFolder := TPath.Combine(ExtractFilePath(ParamStr(0)), AFolder);
  if not DirectoryExists(FFileFolder) then
    TDirectory.CreateDirectory(FFileFolder);
  FFullFilePath := TPath.Combine(FFileFolder, AFileName);

  FLock := TCriticalSection.Create;
  FIsOpened := False;
end;

destructor TChainFileBase.Destroy;
begin
  FLock.Free;

  inherited;
end;

end.
