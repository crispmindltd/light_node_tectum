unit Console;

interface

uses
  App.Intf;

type
  TConsoleCore = class(TInterfacedObject, IUI)
  private
    function IsChainNeedSync(const AName: String): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Run;
    procedure DoMessage(const AMessage: String);
    procedure ShowMainForm;
    procedure ShowEnterPrivateKeyForm;
    procedure NullForm(var Form);
    procedure AddNewChain(const AName: String; AIsSystemChain: Boolean);
    procedure ShowTotalCountBlocksDownloadRemain;
    procedure ShowDownloadProgress;
    procedure NotifyNewChainBlocks;
    procedure NotifyNewSmartBlocks;
  end;

implementation

{ TConsoleCore }

procedure TConsoleCore.AddNewChain(const AName: String; AIsSystemChain: Boolean);
begin
  Writeln('AddNewChain: ' + AName);
end;

constructor TConsoleCore.Create;
begin
   Writeln('Create');
end;

destructor TConsoleCore.Destroy;
begin
   Writeln('Destroy');
  inherited;
end;

procedure TConsoleCore.DoMessage(const AMessage: String);
begin
  Writeln(AMessage);
end;

function TConsoleCore.IsChainNeedSync(const AName: String): Boolean;
begin

end;

procedure TConsoleCore.NotifyNewChainBlocks;
begin
  Writeln('New chain blocks');
end;

procedure TConsoleCore.NotifyNewSmartBlocks;
begin
  Writeln('New smart blocks');
end;

procedure TConsoleCore.NullForm(var Form);
begin
  Writeln('NullForm');
end;

procedure TConsoleCore.Run;
begin
   writeln('Lite node is running. Press Enter to stop.');
   Readln;
end;

procedure TConsoleCore.ShowDownloadProgress;
begin
   Writeln('ShowDownloadProgress');
end;

procedure TConsoleCore.ShowEnterPrivateKeyForm;
begin
  Writeln('ShowEnterPrivateKeyForm');
end;

procedure TConsoleCore.ShowMainForm;
begin
  Writeln('ShowMainForm');
end;

procedure TConsoleCore.ShowTotalCountBlocksDownloadRemain;
begin
  Writeln('ShowTotalCountBlocksDownloadRemain');
end;

end.
