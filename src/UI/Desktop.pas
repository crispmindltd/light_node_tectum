unit Desktop;

interface

uses
  App.Intf,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Classes,
  FMX.Dialogs,
  FMX.Forms,
  Form.Main,
  Form.EnterKey,
  Form.Start,
  Math,
  SyncObjs,
  SysUtils,
  Styles,
  UITypes;

type
  TAccessCommonCustomForm = class(TCommonCustomForm);

type
  TUICore = class(TInterfacedObject, IUI)
  private
    FStartFormCreated: TEvent;

    procedure CreateForm(const InstanceClass: TComponentClass;
      var Reference; AsMainForm: Boolean = False);
    procedure SetMainForm(const Reference);
    procedure ShowForm(Form: TCommonCustomForm; AsMainForm: Boolean = False);
    procedure CreateAndShowForm(const InstanceClass: TComponentClass;
      var Reference; AsMainForm: Boolean = False);
    procedure ReleaseForm(var Form);
    procedure DoReleaseForm(Form: TCommonCustomForm);
    procedure NullForm(var Form);
  public
    constructor Create;
    destructor Destroy; override;

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

{ TUI }

constructor TUICore.Create;
begin
  FStartFormCreated := TEvent.Create;
  FStartFormCreated.ResetEvent;
  Application.Initialize;
  CreateAndShowForm(TStartForm, StartForm, True);
  CreateForm(TStylesForm, StylesForm);
  FStartFormCreated.SetEvent;
end;

procedure TUICore.CreateAndShowForm(const InstanceClass: TComponentClass;
  var Reference; AsMainForm: Boolean);
begin
  CreateForm(InstanceClass,Reference,AsMainForm);
  ShowForm(TCommonCustomForm(Reference));
end;

procedure TUICore.CreateForm(const InstanceClass: TComponentClass; var Reference;
  AsMainForm: Boolean);
begin
  if TObject(Reference) = nil then
  begin
    Application.CreateForm(InstanceClass,Reference);
    if AsMainForm then SetMainForm(Reference);
  end;
end;

destructor TUICore.Destroy;
begin
  if Assigned(FStartFormCreated) then
    FStartFormCreated.Free;

  inherited;
end;

procedure TUICore.ReleaseForm(var Form);
var
  F: TCommonCustomForm;
begin
  F := TCommonCustomForm(Form);

  if Assigned(F) then DoReleaseForm(F);
end;

procedure TUICore.Run;
begin
  Application.Run;
end;

procedure TUICore.SetMainForm(const Reference);
begin
//  if Assigned(TObject(Reference)) then
  Application.MainForm := TCommonCustomForm(Reference);
end;

procedure TUICore.ShowDownloadingDone;
begin
  if not Application.Terminated and Assigned(StartForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      StartForm.HideProgressBar;
    end);
end;

procedure TUICore.ShowDownloadProgress;
begin
  if not Application.Terminated and Assigned(StartForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      StartForm.ShowProgress;
    end);
end;

procedure TUICore.ShowEnterPrivateKeyForm;
begin
  CreateForm(TEnterPrivateKeyForm,EnterPrivateKeyForm,False);

  if (EnterPrivateKeyForm.ShowModal = mrOk) then
    if AppCore.TrySaveKeysToFile(EnterPrivateKeyForm.PrKeyMemo.Text) then
      MainForm.onKeysSaved
    else
      MainForm.onKeysSavingError;

  NullForm(EnterPrivateKeyForm);
end;

procedure TUICore.ShowForm(Form: TCommonCustomForm; AsMainForm: Boolean);
begin
  if Assigned(Form) then
  begin
    if Form.Visible then TAccessCommonCustomForm(Form).DoShow;
    Form.Show;
    if AsMainForm then SetMainForm(Form);
  end;
end;

procedure TUICore.ShowMainForm;
begin
  FreeAndNil(FStartFormCreated);
  ReleaseForm(StartForm);
  CreateAndShowForm(TMainForm, MainForm, True);
end;

procedure TUICore.ShowTotalBlocksToDownload(const ABlocksNumberToLoad: UInt64);
begin
  FStartFormCreated.WaitFor(5000);
  if Assigned(StartForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      StartForm.SetProgressBarMaxValue(ABlocksNumberToLoad);
    end);
end;

procedure TUICore.DoReleaseForm(Form: TCommonCustomForm);
begin
  TAccessCommonCustomForm(Form).ReleaseForm;
end;

procedure TUICore.NotifyNewTETBlocks(const ANeedRefreshBalance: Boolean);
begin
  if Assigned(MainForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      MainForm.NewTETChainBlocksEvent(ANeedRefreshBalance);
    end);
end;

procedure TUICore.NotifyNewToken(const ASmartKey: TCSmartKey);
begin
  if Assigned(MainForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      MainForm.NewTokenEvent(ASmartKey);
    end);
end;

procedure TUICore.NotifyNewTokenBlocks(const ASmartKey: TCSmartKey;
  ANeedRefreshBalance: Boolean);
begin
  if Assigned(MainForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      MainForm.NewTokenBlocksEvent(ASmartKey, ANeedRefreshBalance);
    end);
end;

procedure TUICore.NullForm(var Form);
begin
  TAccessCommonCustomForm(Form) := nil;
end;

end.
