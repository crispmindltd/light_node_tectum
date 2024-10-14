unit Console;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  App.Intf,
{$IF Defined(MSWINDOWS)}
  Winapi.Windows;
{$ELSE}
  Posix.Unistd,
  Posix.StdLib,
  Posix.Signal;
{$ENDIF}

type
  TConsoleCore = class(TInterfacedObject, IUI)
  private
    FCS: TCriticalSection;

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

var
  ExitFlag: Boolean = False;

{$IF Defined(MSWINDOWS)}
function CtrlHandler(CtrlType: DWORD): BOOL; stdcall;
begin
  case CtrlType of
    CTRL_C_EVENT, //
      CTRL_BREAK_EVENT, //
      CTRL_CLOSE_EVENT: begin
        ExitFlag := True;
        Result := True;
      end;
  else
    Result := False;
  end;
end;
{$ELSE}
procedure SignalHandler(Sig: Integer); cdecl;
begin
  case Sig of
    SIGINT, SIGTERM:
    begin
      ExitFlag := True;
    end;
  end;
end;
{$ENDIF}

{ TConsoleCore }

procedure TConsoleCore.AddNewChain(const AName: String; AIsSystemChain: Boolean);
begin
  DoMessage('New chain: ' + AName);
end;

constructor TConsoleCore.Create;
begin
  FCS := TCriticalSection.Create;
{$IF Defined(MSWINDOWS)}
  SetConsoleCtrlHandler(@CtrlHandler, True);
{$ELSE}
  signal(SIGINT, @SignalHandler);
  signal(SIGTERM, @SignalHandler);
{$ENDIF}
end;

destructor TConsoleCore.Destroy;
begin
  try
    DoMessage('');
  finally
    FCS.Free;
    inherited;
  end;
end;

procedure TConsoleCore.DoMessage(const AMessage: String);
begin
  FCS.Enter;
  try
    Write(#13#10 + AMessage);
  finally
    FCS.Leave;
  end;
end;

function TConsoleCore.IsChainNeedSync(const AName: String): Boolean;
begin
end;

procedure TConsoleCore.NotifyNewChainBlocks;
begin
end;

procedure TConsoleCore.NotifyNewSmartBlocks;
begin
end;

procedure TConsoleCore.NullForm(var Form);
begin
end;

procedure TConsoleCore.Run;
begin
   DoMessage(Format('Tectum Light Node version %s. Copyright (c) 2024 CrispMind.',
    [AppCore.GetVersion]));
   DoMessage('Lite node is running. Press Ctrl-C to stop.');
   while not ExitFlag do begin
     Sleep(100);
   end;
   DoMessage('Terminating node ...');
end;

procedure TConsoleCore.ShowDownloadProgress;
begin
  const Remain = AppCore.DownloadRemain;

  FCS.Enter;
  try
    Write(Format('Downloading blocks ... %d left    '#13, [Remain]));
  finally
    FCS.Leave;
  end;
end;

procedure TConsoleCore.ShowEnterPrivateKeyForm;
begin
end;

procedure TConsoleCore.ShowMainForm;
begin
end;

procedure TConsoleCore.ShowTotalCountBlocksDownloadRemain;
begin
  DoMessage('');
end;

end.
