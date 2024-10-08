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
  SysUtils,
  Styles,
  UITypes;

type
  TAccessCommonCustomForm = class(TCommonCustomForm);

type
  TUICore = class(TInterfacedObject, IUI)
  private
    procedure CreateForm(const InstanceClass: TComponentClass;
      var Reference; AsMainForm: Boolean = False);
    procedure SetMainForm(const Reference);
    procedure ShowForm(Form: TCommonCustomForm; AsMainForm: Boolean = False);
    procedure CreateAndShowForm(const InstanceClass: TComponentClass;
      var Reference; AsMainForm: Boolean = False);
    function IsChainNeedSync(const AName: String): Boolean;
    procedure ReleaseForm(var Form);
    procedure DoReleaseForm(Form: TCommonCustomForm);
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

procedure TUICore.AddNewChain(const AName: String; AIsSystemChain: Boolean);
begin
//  if Assigned(MainForm) then
//    MainForm.AddChain(AName, AIsSystemChain);
//  if Assigned(ExplorerForm) then
//  begin
//    if ExplorerForm.CurrencyIDComboBox.Items.IndexOf(AName) = -1 then
//      ExplorerForm.CurrencyIDComboBox.Items.Add(AName);
//  end;
end;

{ TUI }

constructor TUICore.Create;
begin
  Application.Initialize;
  CreateAndShowForm(TStartForm, StartForm, True);
  CreateForm(TStylesForm, StylesForm);
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
  ReleaseForm(StartForm);
  CreateAndShowForm(TMainForm, MainForm, True);
end;

procedure TUICore.ShowTotalCountBlocksDownloadRemain;
begin
  if Assigned(StartForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      StartForm.ShowProgressBar(AppCore.DownloadRemain);
    end);
end;

procedure TUICore.DoMessage(const AMessage: String);
begin
  TThread.Synchronize(nil,
  procedure
  begin
    ShowMessage(AMessage);
//    if Assigned(MainFormNew) then MainFormNew.DoLog(AMessage);
  end);
end;

procedure TUICore.DoReleaseForm(Form: TCommonCustomForm);
begin
  TAccessCommonCustomForm(Form).ReleaseForm;
end;

function TUICore.IsChainNeedSync(const AName: String): Boolean;
begin
//  Result := MainForm.IsChainNeedSync(AName);
end;

procedure TUICore.NotifyNewChainBlocks;
begin
  if Assigned(MainForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      MainForm.NewChainBlocksEvent;
    end);
end;

procedure TUICore.NotifyNewSmartBlocks;
begin
  if Assigned(MainForm) then
    TThread.Synchronize(nil,
    procedure
    begin
      MainForm.NewSmartBlocksEvent;
    end);
end;

procedure TUICore.NullForm(var Form);
begin
  TAccessCommonCustomForm(Form) := nil;
end;

end.
