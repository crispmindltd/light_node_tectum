unit Console;

interface

uses
  Blockchain.BaseTypes,
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
    FTotalBlocksNumberToLoad: UInt64;
    FCS: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure DoMessage(const AMessage: string; ANewLine: Boolean = True);
    procedure Run;
    procedure ShowMainForm;
    procedure ShowEnterPrivateKeyForm;
    procedure ShowTotalBlocksToDownload(const ABlocksNumberToLoad: UInt64);
    procedure ShowDownloadProgress;
    procedure ShowDownloadingDone;
    procedure NotifyNewTETBlocks(const ANeedRefreshBalance: Boolean);
    procedure NotifyNewToken(const ASmartKey: TCSmartKey);
    procedure NotifyNewTokenBlocks(const ASmartKey: TCSmartKey;
      ANeedRefreshBalance: Boolean);
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

constructor TConsoleCore.Create;
begin
  FCS := TCriticalSection.Create;
{$IF Defined(MSWINDOWS)}
  SetConsoleCtrlHandler(@CtrlHandler, True);
{$ELSE}
  signal(SIGINT, @SignalHandler);
  signal(SIGTERM, @SignalHandler);
{$ENDIF}

  FTotalBlocksNumberToLoad := 0;
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

procedure TConsoleCore.DoMessage(const AMessage: string; ANewLine: Boolean);
begin
  FCS.Enter;
  try
    if ANewLine then
      Write(sLineBreak + AMessage)
    else
      Write(AMessage);
  finally
    FCS.Leave;
  end;
end;

procedure TConsoleCore.NotifyNewTETBlocks(const ANeedRefreshBalance: Boolean);
begin
  if AppCore.BlocksSyncDone then
    DoMessage('New TET blocks have been received');
end;

procedure TConsoleCore.NotifyNewToken(const ASmartKey: TCSmartKey);
begin
  if AppCore.BlocksSyncDone then
    DoMessage(Format('Data synchronization for the %s token has begun',
      [ASmartKey.Abreviature]));
end;

procedure TConsoleCore.NotifyNewTokenBlocks(const ASmartKey: TCSmartKey;
  ANeedRefreshBalance: Boolean);
begin
  if AppCore.BlocksSyncDone then
    DoMessage(Format('New blocks of the %s token have been received',
      [ASmartKey.Abreviature]));
end;

procedure TConsoleCore.Run;
begin
   DoMessage(Format('Tectum Light Node version %s. Copyright (c) 2024 CrispMind.',
    [AppCore.GetVersion]));
   DoMessage('Lite node is running. Press Ctrl-C to stop.');
   DoMessage('Please wait until blocks are loaded...');

   while not ExitFlag do
   begin
     Sleep(100);
   end;

   DoMessage('Terminating node...');
end;

procedure TConsoleCore.ShowDownloadingDone;
begin
  if AppCore.BlocksSyncDone then
    DoMessage(' Done' + sLineBreak + 'HTTP requests are now available', False);
end;

procedure TConsoleCore.ShowDownloadProgress;
var
  CurrentBlocksNumber: UInt64;
begin
  CurrentBlocksNumber := AppCore.GetTETChainBlocksCount +
    AppCore.GetDynTETChainBlocksCount;

  DoMessage(Format('%d of %d blocks loaded...',
    [CurrentBlocksNumber, FTotalBlocksNumberToLoad]));

  AppCore.BlocksSyncDone := CurrentBlocksNumber = FTotalBlocksNumberToLoad;
end;

procedure TConsoleCore.ShowEnterPrivateKeyForm;
begin
end;

procedure TConsoleCore.ShowMainForm;
begin
end;

procedure TConsoleCore.ShowTotalBlocksToDownload(
  const ABlocksNumberToLoad: UInt64);
begin
  FTotalBlocksNumberToLoad := ABlocksNumberToLoad;
  AppCore.BlocksSyncDone := FTotalBlocksNumberToLoad =
    (AppCore.GetTETChainBlocksCount + AppCore.GetDynTETChainBlocksCount);
end;

end.
