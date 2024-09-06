unit Console;

interface

uses
  System.SysUtils,
  System.SyncObjs,
  App.Intf;

type
  TConsoleCore = class(TInterfacedObject, IUI)
  private
    CS:TCriticalSection;
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
  DoMessage('New chain: ' + AName);
end;

constructor TConsoleCore.Create;
begin
  CS := TCriticalSection.Create;
end;

destructor TConsoleCore.Destroy;
begin
  try
    DoMessage('');
  finally
    CS.Free;
    inherited;
  end;
end;

procedure TConsoleCore.DoMessage(const AMessage: String);
begin
  CS.Enter;
  try
    Write(#13#10 + AMessage);
  finally
    CS.Leave;
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
   DoMessage(Format('Tectum Light Node version %s. Copyright (c) 2024 CrispMind.',[AppCore.GetVersion]));
   DoMessage('Lite node is running. Press Enter to stop.');
   Readln;
end;

procedure TConsoleCore.ShowDownloadProgress;
begin
  const Remain = AppCore.DownloadRemain;

  CS.Enter;
  try
    Write(Format('Downloading blocks ... %d left    '#13, [Remain]));
  finally
    CS.Leave;
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

