unit Net.Data;

interface

uses
  Classes,
  SysUtils;

const
  DEFAULT_NODE_ADDRESS = '185.180.223.168:50000';
  DEFAULT_TCP_LISTEN_TO = '127.0.0.1:50000';
  DEFAULT_HTTP_PORT = 8917;

  DISCONNECTING_CODE = 0;
  CONNECT_ERROR_CODE = 1;
  ERROR_CODE = 2;
  SUCCESS_CODE = 3;
  VALIDATE_COMMAND_CODE = 100;
  CHAIN_SYNC_COMMAND_CODE = 101;
  CHAIN_DYN_SYNC_COMMAND_CODE = 102;
  TOKEN_ICO_SYNC_COMMAND_CODE = 103;
  SMART_SYNC_COMMAND_CODE = 104;
  SMART_DYN_SYNC_COMMAND_CODE = 105;
  CHAIN_TOTAL_COUNT_COMMAND_CODE = 106;
  DYN_CHAIN_TOTAL_COUNT_COMMAND_CODE = 107;

type
  TNodesConnectManager = class
    private
      FNodesPool: TStringList;

      function IsPoolEmpty: Boolean;
    public
      constructor Create;
      destructor Destroy; override;

      procedure AddNodeToPool(const ANodeAddress: String);
      function GetNodeToConnect: String;
      function GetAnotherNodeToConnect(const ACurNode: String): String;

      property IsEmpty: Boolean read IsPoolEmpty;
  end;

var
  Nodes: TNodesConnectManager;
  ListenTo: String;
  HTTPPort: Word;

implementation

{ TNodesConnectManager }

procedure TNodesConnectManager.AddNodeToPool(const ANodeAddress: String);
begin
  FNodesPool.Add(ANodeAddress);
end;

constructor TNodesConnectManager.Create;
begin
  FNodesPool := TStringList.Create(dupIgnore,True,False);
end;

destructor TNodesConnectManager.Destroy;
begin
  FNodesPool.Free;

  inherited;
end;

function TNodesConnectManager.GetAnotherNodeToConnect(
  const ACurNode: String): String;
var
  i: Integer;
begin
  if FNodesPool.Count > 1 then
  begin
    Randomize;
    repeat
      i := Random(FNodesPool.Count);
    until not FNodesPool.Strings[i].Equals(ACurNode);
    Result := FNodesPool.Strings[i];
  end else
    Result := FNodesPool[0];
end;

function TNodesConnectManager.GetNodeToConnect: String;
begin
  Randomize;
  Result := FNodesPool.Strings[Random(FNodesPool.Count)];
end;

function TNodesConnectManager.IsPoolEmpty: Boolean;
begin
  Result := FNodesPool.Count = 0;
end;

initialization
  Nodes := TNodesConnectManager.Create;

finalization
  Nodes.Free;

end.
