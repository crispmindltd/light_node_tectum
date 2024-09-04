unit Form.Start;

interface

uses
  App.Intf,
  App.Logs,
  App.Exceptions,
  Net.Socket,
  WordsPool,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Layouts,Styles, FMX.Controls.Presentation, FMX.Edit, FMX.StdCtrls,
  FMX.Effects, FMX.Filter.Effects, FMX.Ani, FMX.Platform,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Objects;

type
  TStartForm = class(TForm)
    CenterLayout: TLayout;
    AuthTabControl: TTabControl;
    LogInTabItem: TTabItem;
    SignUpTabItem: TTabItem;
    EmailEdit: TEdit;
    PasswordEdit: TEdit;
    EyeLayout: TLayout;
    LogInButtonLayout: TLayout;
    LogInButton: TButton;
    FloatAnimation1: TFloatAnimation;
    LogInLayout: TLayout;
    WordsLayout: TLayout;
    Words13Layout: TLayout;
    Word1Edit: TEdit;
    Words46Layout: TLayout;
    Word2Edit: TEdit;
    Word3Edit: TEdit;
    Word4Edit: TEdit;
    Word5Edit: TEdit;
    Word6Edit: TEdit;
    Words79Layout: TLayout;
    Word7Edit: TEdit;
    Word8Edit: TEdit;
    Word9Edit: TEdit;
    Words1012Layout: TLayout;
    Word10Edit: TEdit;
    Word11Edit: TEdit;
    Word12Edit: TEdit;
    NextButton: TButton;
    NextButtonLayout: TLayout;
    FloatAnimation2: TFloatAnimation;
    HeightFloatAnimation2: TFloatAnimation;
    HeightFloatAnimation1: TFloatAnimation;
    Tabs: TTabControl;
    AuthTab: TTabItem;
    SuccessRegTab: TTabItem;
    NewUserDataLayout: TLayout;
    LogInAfterRegButton: TButton;
    DownloadProgressBar: TProgressBar;
    ProgressLabel: TLabel;
    FloatAnimation3: TFloatAnimation;
    PleaseWaitLabel: TLabel;
    LightNodeHaderLabel: TLabel;
    EnterLoginLabel: TLabel;
    EmailLabel: TLabel;
    PasswordLabel: TLabel;
    ErrorLoginLabel: TLabel;
    SignUpLabel1: TLabel;
    SignUpLabel2: TLabel;
    SignUpLabel3: TLabel;
    SignUpLabel4: TLabel;
    ErrorSignUpLabel: TLabel;
    NewLogInLabel: TLabel;
    NewPassLabel: TLabel;
    AttentionLabel: TLabel;
    PathMemo: TMemo;
    CopyLogInSvg: TPath;
    CopyLoginLayout: TLayout;
    CopyPassLayout: TLayout;
    CopyPassSvgPath: TPath;
    Num1Text: TText;
    Num2Text: TText;
    Num3Text: TText;
    Num4Text: TText;
    Num5Text: TText;
    Num6Text: TText;
    Num7Text: TText;
    Num8Text: TText;
    Num9Text: TText;
    Num10Text: TText;
    Num11Text: TText;
    Num12Text: TText;
    EyeSvg: TPath;
    procedure FormCreate(Sender: TObject);
    procedure EyeLayoutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure EyeLayoutMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure EmailEditChangeTracking(Sender: TObject);
    procedure LogInButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure LogInAfterRegButtonClick(Sender: TObject);
    procedure AuthTabControlChange(Sender: TObject);
    procedure FloatAnimation3Finish(Sender: TObject);
    procedure CopyLoginLayoutClick(Sender: TObject);
    procedure CopyPassLayoutClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure EmailEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
  private
    phrase: String;
    procedure ShowLogInError(const AMessage: String);
    procedure HideLogInError;
    procedure ShowSignUpError(const AMessage: String);
    procedure OnDownloadingDone;
  public
    procedure ShowProgressBar(const ADownloadRemainTotal:Int64);
    procedure ShowProgress;
  end;

var
  StartForm: TStartForm;

implementation

{$R *.fmx}

procedure TStartForm.AuthTabControlChange(Sender: TObject);
var
  splt: TArray<String>;
begin
  if AuthTabControl.TabIndex = 1 then
  begin
    phrase := GenSeedPhrase;
    splt := phrase.Split([' ']);

    Word1Edit.Text := splt[0];
    Word2Edit.Text := splt[1];
    Word3Edit.Text := splt[2];
    Word4Edit.Text := splt[3];
    Word5Edit.Text := splt[4];
    Word6Edit.Text := splt[5];
    Word7Edit.Text := splt[6];
    Word8Edit.Text := splt[7];
    Word9Edit.Text := splt[8];
    Word10Edit.Text := splt[9];
    Word11Edit.Text := splt[10];
    Word12Edit.Text := splt[11];

    NewLoginLabel.Text := 'Your Log In:';
    NewPassLabel.Text := 'Password:';
    PathMemo.Lines.Clear;
  end;
end;

procedure TStartForm.CopyLoginLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(Copy(NewLogInLabel.Text,14,Length(NewLogInLabel.Text)));
end;

procedure TStartForm.CopyPassLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(Copy(NewPassLabel.Text,11,Length(NewPassLabel.Text)));
end;

procedure TStartForm.EmailEditChangeTracking(Sender: TObject);
var
  ind: Integer;
begin
  ind := EmailEdit.Text.IndexOf('@');
  LogInButton.Enabled := (ind >= 1) and
    (EmailEdit.Text.LastIndexOf('.') > ind) and (EmailEdit.Text.Length >= 5) and
    (not PasswordEdit.Text.IsEmpty) and (AppCore.DownloadRemain = 0);
end;

procedure TStartForm.EmailEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if LogInButton.Enabled and (Key = 13) then
    LogInButtonClick(Self);
end;

procedure TStartForm.EyeLayoutMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  PasswordEdit.Password := False;
  StylesForm.OnCopyLayoutMouseDown(Sender,Button,Shift,X,Y);
end;

procedure TStartForm.EyeLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  PasswordEdit.Password := True;
  StylesForm.OnCopyLayoutMouseUp(Sender,Button,Shift,X,Y);
end;

procedure TStartForm.FloatAnimation3Finish(Sender: TObject);
begin
  DownloadProgressBar.Visible := False;
  FloatAnimation3.Enabled := False;
end;

procedure TStartForm.FormCreate(Sender: TObject);
begin
  Caption := 'LNode' + ' ' + AppCore.GetVersion;
  AuthTabControl.TabHeight := 64;

  EyeLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  EyeLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  CopyLoginLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  CopyLoginLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  CopyLoginLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  CopyLoginLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;
  CopyPassLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  CopyPassLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  CopyPassLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  CopyPassLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;
end;

procedure TStartForm.FormResize(Sender: TObject);
begin
  LightNodeHaderLabel.Position.X := (Width div 2) - 308;
  LightNodeHaderLabel.Position.Y := (Height div 2) - 300;
end;

procedure TStartForm.FormShow(Sender: TObject);
begin
  Tabs.TabIndex := 0;
  AuthTabControl.TabIndex := 0;
  DownloadProgressBar.StyleLookup := 'DownloadProgressBarStyle';
  DownloadProgressBar.NeedStyleLookup;
  DownloadProgressBar.ApplyStyleLookup;
end;

procedure TStartForm.HideLogInError;
begin
  ErrorLoginLabel.Opacity := 0;
  ErrorLoginLabel.Visible := False;
  LogInLayout.Height := 296;
end;

procedure TStartForm.LogInAfterRegButtonClick(Sender: TObject);
begin
  EmailEdit.Text := Copy(NewLoginLabel.Text,14,Length(NewLoginLabel.Text));
  HideLogInError;
  PasswordEdit.Text := '';
  AuthTabControl.TabIndex := 0;
  Tabs.Previous;
  PasswordEdit.SetFocus;
end;

procedure TStartForm.LogInButtonClick(Sender: TObject);
var
  splt: TArray<String>;
  response: String;
begin
  try
    response := AppCore.DoAuth('*',EmailEdit.Text,PasswordEdit.Text);
    splt := response.Split([' ']);
    AppCore.SessionKey := splt[2];
    AppCore.UserID := splt[4].ToInt64;
    UI.ShowMainForm;
  except
    on E:ESocketError do
      ShowLogInError('Server did not respond, try later');
    on E:EValidError do
      ShowLogInError(E.Message);
    on E:EAuthError do
      ShowLogInError(LOGIN_ERROR_TEXT);
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during auth with code ' + E.Message,TLogType.ERROR,tcp);
      ShowLogInError('Unknown error, try later');
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during auth with message: ' + E.Message,TLogType.ERROR,tcp);
      ShowLogInError('Unknown error, try later');
    end;
  end;
end;

procedure TStartForm.NextButtonClick(Sender: TObject);
var
  response: String;
  pubKey,prKey,login,pass,addr,sPath: String;
begin
  try
    response := AppCore.DoReg('*',phrase,pubKey,prKey,login,pass,addr,sPath);
    NewLoginLabel.Text := 'Your Log In: ' + login;
    NewPassLabel.Text := 'Password: ' + pass;
    PathMemo.Text := sPath;
    Tabs.Next;
  except
    on E:ESocketError do
      ShowSignUpError('Server did not respond, try later');
    on E:EValidError do
      ShowSignUpError(E.Message);
    on E:EAuthError do
      ShowSignUpError(LOGIN_ERROR_TEXT);
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during auth with code ' + E.Message,TLogType.ERROR,tcp);
      ShowSignUpError('Unknown error, try later');
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during auth with message: ' + E.Message,TLogType.ERROR,tcp);
      ShowSignUpError('Unknown error, try later');
    end;
  end;
end;

procedure TStartForm.OnDownloadingDone;
begin
  EmailEditChangeTracking(Self);
  SignUpTabItem.Enabled := True;
end;

procedure TStartForm.ShowLogInError(const AMessage: String);
begin
  ErrorLoginLabel.Text := AMessage;
  ErrorLoginLabel.Visible := True;
  HeightFloatAnimation1.Start;
  FloatAnimation1.Start;
end;

procedure TStartForm.ShowProgress;
var
  totalCount,remain: Int64;
begin
  totalCount := Round(DownloadProgressBar.Max);
  remain := totalCount - AppCore.DownloadRemain;

  ProgressLabel.Text := Format('%d of %d blocks loaded',
    [remain,totalCount]);
  DownloadProgressBar.Value := remain;

  if remain = totalCount then
  begin
    OnDownloadingDone;
    FloatAnimation3.Enabled := True;
  end;
end;

procedure TStartForm.ShowProgressBar(const ADownloadRemainTotal: Int64);
begin
  if ADownloadRemainTotal > 0 then
  begin
    DownloadProgressBar.Max := ADownloadRemainTotal;
    ProgressLabel.Text := Format('%d of %d blocks loaded',[0,ADownloadRemainTotal]);
    DownloadProgressBar.Visible := True;
  end else
    OnDownloadingDone;
end;

procedure TStartForm.ShowSignUpError(const AMessage: String);
begin
  ErrorSignUpLabel.Text := AMessage;
  ErrorSignUpLabel.Visible := True;
  HeightFloatAnimation2.Start;
  FloatAnimation2.Start;
end;

end.
