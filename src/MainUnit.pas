unit MainUnit;

interface

uses
  App.Exceptions,
  App.Intf,
  App.Logs,
  Blockchain.Intf,
  Classes,
  Crypto,
  FMX.Edit,
  FMX.Layouts,
  FMX.Memo,
  FMX.Types,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.TabControl,
  IOUtils,
  Net.Data,
  Net.Socket,
  Server.Types,
  SysUtils,
  UITypes, FMX.Memo.Types, FMX.Controls, FMX.ScrollBox,
  FMX.Controls.Presentation;

type
  TMainForm = class(TForm)
    MainPanel: TPanel;
    ExplorerButton: TButton;
    ChainsToSynchGroupBox: TGroupBox;
    VertScrollBox: TVertScrollBox;
    LogMemo: TMemo;
    ActionsGroupBox: TGroupBox;
    AuthButton: TButton;
    LogInEdit: TEdit;
    PWEdit: TEdit;
    GetBlocksCountButton: TButton;
    GetLocalBlocksCountButton: TButton;
    RegButton: TButton;
    TransferTETGroupBox: TGroupBox;
    SessionKeyEdit: TEdit;
    SessionKeyLabel: TLabel;
    TETSendToEdit: TEdit;
    TETSendToLabel: TLabel;
    TETAmountEdit: TEdit;
    TETAmountLabel: TLabel;
    TransTETButton: TButton;
    CoinsBalancesGroupBox: TGroupBox;
    TokensEdit: TEdit;
    TokensLabel: TLabel;
    TokensBalancesButton: TButton;
    AutoFillAuthCheckBox: TCheckBox;
    RegGroupBox: TGroupBox;
    SeedEdit: TEdit;
    SeedLabel: TLabel;
    HTTPTabControl: TTabControl;
    AccTabItem: TTabItem;
    RecoverGroupBox: TGroupBox;
    RecoverEdit: TEdit;
    RecoverLabel: TLabel;
    RecoverButton: TButton;
    CoinsTabItem: TTabItem;
    GetCoinsTransHistoryButton: TButton;
    CoinsHistoryGroupBox: TGroupBox;
    TransactionsHistoryAmountEdit: TEdit;
    TransactionsHistoryAmountLabel: TLabel;
    AuthGroupBox: TGroupBox;
    TokensTabItem: TTabItem;
    TokenCreateGroupBox: TGroupBox;
    FTokenNameEdit: TEdit;
    FTokenNameLabel: TLabel;
    STokenNameEdit: TEdit;
    STokenNameLabel: TLabel;
    CreateTokenButton: TButton;
    TTokenEdit: TEdit;
    TTokenLabel: TLabel;
    ATokenLabel: TLabel;
    ATokenEdit: TEdit;
    DTokenLabel: TLabel;
    DTokenEdit: TEdit;
    TokensTransferGroupBox: TGroupBox;
    TokenSendToEdit: TEdit;
    TokenSendToLabel: TLabel;
    TokenAmountEdit: TEdit;
    TokenAmountLabel: TLabel;
    TransTokenButton: TButton;
    TokenSendFromEdit: TEdit;
    TokenSendFromLabel: TLabel;
    PasswordEditButton1: TPasswordEditButton;
    PrKeyEdit: TEdit;
    PrKeyLabel: TLabel;
    PubKeyEdit: TEdit;
    PubKeyLabel: TLabel;
    TokensVertScrollBox: TVertScrollBox;
    TokensActionsGroupBox: TGroupBox;
    GetSmartAddressByIDButton: TButton;
    SMIDEdit: TEdit;
    SMIDLabel: TLabel;
    TokensBalanceGroupBox: TGroupBox;
    SmartAddressEdit: TEdit;
    SmartAddressLabel: TLabel;
    GetTokenBalanceWithSmartAddrButton: TButton;
    TETAddressEdit: TEdit;
    TETAddressLabel: TLabel;
    SmAddressEdit: TEdit;
    SmAddressLabel: TLabel;
    TokenTickerEdit: TEdit;
    TickerLabel: TLabel;
    GetSmartAddressByTickerButton: TButton;
    PubKeyGroupBox: TGroupBox;
    UserIDEdit: TEdit;
    UserIDLabel: TLabel;
    GetPubKeyByIDButton: TButton;
    GetPubKeyByKeyButton: TButton;
    AccVertScrollBox: TVertScrollBox;
    CoinsVertScrollBox: TVertScrollBox;
    SmartTickerEdit: TEdit;
    SmartTickerLabel: TLabel;
    GetTokenBalanceWithTickerButton: TButton;
    GetMyKeysButton: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ExplorerButtonClick(Sender: TObject);
    procedure AddChain(AName: String; AIsSystemChain: Boolean);
    procedure AuthButtonClick(Sender: TObject);
    procedure GetBlocksCountButtonClick(Sender: TObject);
    procedure GetLocalBlocksCountButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RegButtonClick(Sender: TObject);
    procedure TransTETButtonClick(Sender: TObject);
    procedure TokensBalancesButtonClick(Sender: TObject);
    procedure RecoverButtonClick(Sender: TObject);
    procedure GetCoinsTransHistoryButtonClick(Sender: TObject);
    procedure CreateTokenButtonClick(Sender: TObject);
    procedure TransTokenButtonClick(Sender: TObject);
    procedure GetSmartAddressByIDButtonClick(Sender: TObject);
    procedure GetPubKeyByIDButtonClick(Sender: TObject);
    procedure GetPubKeyByKeyButtonClick(Sender: TObject);
    procedure GetTokenBalanceWithSmartAddrButtonClick(Sender: TObject);
    procedure GetSmartAddressByTickerButtonClick(Sender: TObject);
    procedure GetTokenBalanceWithTickerButtonClick(Sender: TObject);
    procedure GetMyKeysButtonClick(Sender: TObject);
  private
    procedure onCheckBoxChange(Sender: TObject);
  public
    procedure onUpdaterDestroy(const AName: String);
    procedure DoLog(const AMessage: String);
    function IsChainNeedSync(const AName: String): Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

procedure TMainForm.AddChain(AName: String; AIsSystemChain: Boolean);
var
  NewCheckBox: TCheckBox;
begin
  VertScrollBox.BeginUpdate;
  try
    NewCheckBox := TCheckBox.Create(VertScrollBox);
    with NewCheckBox do
    begin
      Parent := VertScrollBox;
      Align := TAlignLayout.Top;
      Margins.Top := 5;
      Position.Y := Integer.MaxValue;
      Text := AName;
//      Name := 'CheckBox' + AName.Replace('.','');
      Name := 'CheckBox' + VertScrollBox.ComponentCount.ToString;
      StyledSettings := NewCheckBox.StyledSettings - [TStyledSetting.Size];
      TextSettings.Font.Size := 16;
      if AIsSystemChain then
        Tag := 1
      else
        Tag := 0;
      IsChecked := AIsSystemChain;
      OnChange := onCheckBoxChange;
    end;
  finally
    VertScrollBox.EndUpdate;
  end;
end;

procedure TMainForm.AuthButtonClick(Sender: TObject);
var
  response: String;
begin
  SessionKeyEdit.Text := '';
  try
    response := AppCore.DoAuth('*',LoginEdit.Text,PWEdit.Text);
    DoLog(Format('Auth success, session key = %s',[response.Split([' '])[2]]));
    SessionKeyEdit.Text := response.Split([' '])[2];
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Auth error: ' + E.Message,ERROR,tcp);
      DoLog('Auth error: ' + E.Message);
    end;
    on E:EAuthError do
    begin
      Logs.DoLog('Incorrect login or password',ERROR,tcp);
      DoLog('Incorrect login or password');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during auth with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during auth with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during auth with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during auth with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.CreateTokenButtonClick(Sender: TObject);
var
  response,str: String;
  amount: Int64;
  decimals: Integer;
  splt: TArray<String>;
begin
  try
    if not TryStrToInt64(ATokenEdit.Text,amount) then
      raise EValidError.Create('invalid amount');
    if not TryStrToInt(DTokenEdit.Text,decimals) then
      raise EValidError.Create('invalid decimals');

    response := AppCore.DoNewToken('*',SessionKeyEdit.Text,FTokenNameEdit.Text,
      STokenNameEdit.Text,TTokenEdit.Text.ToUpper,amount,decimals);
    splt := response.Split([' ']);
    str := Format('New token created, hash = %s, smartcontractID = %s',[splt[2],splt[3]]);
    DoLog(str);
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Token creating error: ' + E.Message,ERROR,tcp);
      DoLog('Token creating error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Token creating error: key expired',ERROR,tcp);
      DoLog('Token creating error: key expired');
    end;
    on E:ETokenAlreadyExists do
    begin
      Logs.DoLog('Token creating error: token already exists',ERROR,tcp);
      DoLog('Token creating error: token already exists');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during token creating with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during token creating with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during token creating with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during token creating with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.DoLog(const AMessage: String);
begin
  LogMemo.BeginUpdate;
  try
    MainForm.LogMemo.Lines.Add(AMessage);
    if LogMemo.Lines.Count >= 300 then
      LogMemo.Lines.Delete(0);

    LogMemo.GoToTextEnd;
  finally
    LogMemo.EndUpdate;
  end;
end;

procedure TMainForm.ExplorerButtonClick(Sender: TObject);
begin
  UI.ShowExplorer;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  AppCore.Run;

  HTTPTabControl.TabIndex := 0;
end;

procedure TMainForm.GetBlocksCountButtonClick(Sender: TObject);
var
  response: String;
begin
  try
    response := AppCore.GetBlocksCount('*');
    DoLog(Format('Blocks count = %s',[response.Split([' '])[2]]));
  except
    Logs.DoLog('Server did not respond',NONE);
    DoLog('Server did not respond, try later');
  end;
end;

procedure TMainForm.GetCoinsTransHistoryButtonClick(Sender: TObject);
var
  response,str: String;
  i: Integer;
  tickersList: TStringList;
  splt,transInfo: TArray<String>;
  toLog: TStringBuilder;
begin
  try
    response := AppCore.DoGetCoinsTransfersHistory(SessionKeyEdit.Text,
      TransactionsHistoryAmountEdit.Text.ToInteger);
    splt := response.Split([' '], '<', '>');
    str := '';
    tickersList := TStringList.Create(dupIgnore,True,False);
    tickersList.AddStrings(TokensEdit.Text.Split([',']));
    try
      toLog := TStringBuilder.Create;
      toLog.Append(sLineBreak + 'Transactions history:' + sLineBreak);
      for i := 4 to Length(splt) - 1 do
      begin
        transInfo := splt[i].Trim(['<','>']).Split([' ']);
        toLog.Append('BlockNumber: ' + transInfo[5] + sLineBreak);
        toLog.Append('Time: ' + FormatDateTime('dd.mm.yyyy hh:mm:ss',
          FloatToDateTime(transInfo[6].ToExtended)) + sLineBreak);
        toLog.Append('TokenFar: ' + transInfo[0] + sLineBreak);
        toLog.Append('Transfer sum: ' + transInfo[1] + sLineBreak);
        toLog.Append('Direction: ' + transInfo[2] + sLineBreak);
        toLog.Append('Hash: ' + transInfo[3] + sLineBreak);
        toLog.Append('Amount: ' + transInfo[4] + sLineBreak + sLineBreak);
      end;
      str := TrimRight(toLog.ToString);
    finally
      tickersList.Free;
      FreeAndNil(toLog);
    end;
    DoLog(str);
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting coins transfer history error: ' + E.Message,ERROR,tcp);
      DoLog('Getting coins transfer history error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Getting coins transfer history error: key expired',ERROR,tcp);
      DoLog('Getting coins transfer history error: key expired');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting coins transfer history with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting coins transfer history with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during getting coins transfer history with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting coins transfer history with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.GetLocalBlocksCountButtonClick(Sender: TObject);
begin
  DoLog(Format('Blocks loaded: %d',[AppCore.GetBlocksCountLocal('Token.chn')]))
end;

procedure TMainForm.GetMyKeysButtonClick(Sender: TObject);
var
  response: String;
  splt: TArray<String>;
begin
  try
    response := AppCore.DoGetMyKeys('*',SessionKeyEdit.Text);
    splt := response.Split([' '],'<','>');
    DoLog('Your public key = ' + splt[2].Trim(['<','>']));
    DoLog('Your private key = ' + splt[3].Trim(['<','>']));
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting keys error: ' + E.Message,ERROR,tcp);
      DoLog('Getting keys error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Getting keys error: key expired',ERROR,tcp);
      DoLog('Getting keys error: key expired');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting keys error with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting keys error with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during getting keys error with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting keys error with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.GetPubKeyByIDButtonClick(Sender: TObject);
var
  response: String;
  id: Integer;
begin
  try
    if not TryStrToInt(UserIDEdit.Text,id) then raise EValidError.Create('invalid ID');

    response := AppCore.GetPubKeyByID('*',id);
    DoLog(Format('Public key of user %s = %s',[UserIDEdit.Text,response.Split([' '])[2]]));
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting public key by acc ID error: ' + E.Message,ERROR,tcp);
      DoLog('Getting public key by acc ID error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Getting public key by acc ID error: key expired',ERROR,tcp);
      DoLog('Getting public key by acc ID error: key expired');
    end;
    on E:EAddressNotExistsError do
    begin
      Logs.DoLog('Getting public key by acc ID error: account does not exists',ERROR,tcp);
      DoLog('Getting public key by acc ID error: account does not exists');
    end;
    on E:ENoInfoForThisAccountError do
    begin
      Logs.DoLog('Getting public key by acc ID error: this account does not have the requested information',ERROR,tcp);
      DoLog('Getting public key by acc ID error: this account does not have the requested information');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting public key by acc ID error with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting public key by acc ID error with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during getting public key by acc ID error with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting public key by acc ID error with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.GetPubKeyByKeyButtonClick(Sender: TObject);
var
  response: String;
begin
  try
    response := AppCore.GetPubKeyBySessionKey('*',SessionKeyEdit.Text);
    DoLog(Format('Your public key = %s',[response.Split([' '])[2]]))
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting public key by session key error: ' + E.Message,ERROR,tcp);
      DoLog('Getting public key by session key error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Getting public key by session key error: key expired',ERROR,tcp);
      DoLog('Getting public key by session key error: key expired');
    end;
    on E:ENoInfoForThisAccountError do
    begin
      Logs.DoLog('Getting public key by session key error: this account does not have the requested information',ERROR,tcp);
      DoLog('Getting public key by session key error: this account does not have the requested information');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting public key by session key error with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during Getting public key by session key error with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during getting public key by session key error with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during coins getting public key by session key error with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.GetSmartAddressByIDButtonClick(Sender: TObject);
var
  response: String;
begin
  try
    response := AppCore.GetSmartAddressByID(SMIDEdit.Text.ToInt64);
    DoLog(Format('Address of smart contract with ID %s = %s',[SMIDEdit.Text,response]));
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting smartcontract address error: ' + E.Message,ERROR,tcp);
      DoLog('Getting smartcontract address error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Getting smartcontract address error: key expired',ERROR,tcp);
      DoLog('Getting smartcontract address error: key expired');
    end;
    on E:ESmartNotExistsError do
    begin
      Logs.DoLog('Getting smartcontract address error: smart contract does not exists',ERROR,tcp);
      DoLog('Getting smartcontract address error: smart contract does not exists');
    end;
    on E:ENoInfoForThisSmartError do
    begin
      Logs.DoLog('Getting smartcontract address error: this smartcontract does not have the requested information',ERROR,tcp);
      DoLog('Getting smartcontract address error: this smartcontract does not have the requested information');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting coins transfer history with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting coins transfer history with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during coins transfer history with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during coins transfer history with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.GetSmartAddressByTickerButtonClick(Sender: TObject);
var
  response: String;
begin
  try
    response := AppCore.GetSmartAddressByTicker(TokenTickerEdit.Text);
    DoLog(Format('Address of smart contract with ticker %s = %s',[TokenTickerEdit.Text,response]));
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting smartcontract address error: ' + E.Message,ERROR,tcp);
      DoLog('Getting smartcontract address error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Getting smartcontract address error: key expired',ERROR,tcp);
      DoLog('Getting smartcontract address error: key expired');
    end;
    on E:ESmartNotExistsError do
    begin
      Logs.DoLog('Getting smartcontract address error: smart contract does not exists',ERROR,tcp);
      DoLog('Getting smartcontract address error: smart contract does not exists');
    end;
    on E:ENoInfoForThisSmartError do
    begin
      Logs.DoLog('Getting smartcontract address error: this smartcontract does not have the requested information',ERROR,tcp);
      DoLog('Getting smartcontract address error: this smartcontract does not have the requested information');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting coins transfer history with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting coins transfer history with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during coins transfer history with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during coins transfer history with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.GetTokenBalanceWithSmartAddrButtonClick(Sender: TObject);
var
  response: String;
  splt: TArray<String>;
begin
  try
    response := AppCore.DoGetTokenBalanceWithSmartAddress('*',TETAddressEdit.Text,
      SmartAddressEdit.Text);
    splt := response.Split([' ']);
    DoLog('Balance = ' + splt[2]);
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting token balance error: ' + E.Message,ERROR,tcp);
      DoLog('Getting token balance error: ' + E.Message);
    end;
    on E:EAddressNotExistsError do
    begin
      Logs.DoLog('Getting token balance error: account don''t exists',ERROR,tcp);
      DoLog('Getting token balance error: account don''t exists');
    end;
    on E:ESmartNotExistsError do
    begin
      Logs.DoLog('Getting token balance error: smart contract does not exists',ERROR,tcp);
      DoLog('Getting token balance error: smart contract does not exists');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting token balance with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting token balance with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during getting token balance with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting token balance with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.GetTokenBalanceWithTickerButtonClick(Sender: TObject);
var
  response: String;
  splt: TArray<String>;
begin
  try
    response := AppCore.DoGetTokenBalanceWithTicker('*',TETAddressEdit.Text,SmartTickerEdit.Text);
    splt := response.Split([' ']);
    DoLog('Balance = ' + splt[2]);
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting token balance error: ' + E.Message,ERROR,tcp);
      DoLog('Getting token balance error: ' + E.Message);
    end;
    on E:EAddressNotExistsError do
    begin
      Logs.DoLog('Getting token balance error: account don''t exists',ERROR,tcp);
      DoLog('Getting token balance error: account don''t exists');
    end;
    on E:ESmartNotExistsError do
    begin
      Logs.DoLog('Getting token balance error: smart contract does not exists',ERROR,tcp);
      DoLog('Getting token balance error: smart contract does not exists');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting token balance with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting token balance with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during getting token balance with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting token balance with message: ' + E.Message);
    end;
  end;
end;

function TMainForm.IsChainNeedSync(const AName: String): Boolean;
var
  i: Integer;
  CB: TCheckBox;
begin
  for i := 0 to VertScrollBox.ComponentCount-1 do
    if VertScrollBox.Components[i] is TCheckBox then
    begin
      CB := (VertScrollBox.Components[i] as TCheckBox);
      if CB.Text = AName then Exit(CB.IsChecked);
    end;
  Result := True;
end;

procedure TMainForm.onCheckBoxChange(Sender: TObject);
var
  CheckBox: TCheckBox;
begin
  CheckBox := Sender as TCheckBox;

  if CheckBox.IsChecked then
    AppCore.BeginSync(CheckBox.Text,CheckBox.Tag = 1)
  else
    AppCore.StopSync(CheckBox.Text,CheckBox.Tag = 1);
end;

procedure TMainForm.onUpdaterDestroy(const AName: String);
var
  i: Integer;
  CheckBox: TCheckBox;
begin
  for i := 0 to VertScrollBox.ComponentCount-1 do
    if VertScrollBox.Components[i] is TCheckBox then
    begin
      CheckBox := VertScrollBox.Components[i] as TCheckBox;
      if CheckBox.Text = AName then
      begin
        CheckBox.IsChecked := False;
        exit;
      end;
    end;
end;

procedure TMainForm.RecoverButtonClick(Sender: TObject);
var
  PrKey,PubKey: String;
begin
  try
    AppCore.DoRecoverKeys(RecoverEdit.Text,PubKey,PrKey);
    DoLog(Format('Recovered private key: "%s"%sRecovered public key: "%s"',
      [PrKey,sLineBreak,PubKey]));
  except
    on E:EValidError do
    begin
      Logs.DoLog('Recover keys error: ' + E.Message,ERROR,tcp);
      DoLog('Recover keys error: ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during keys recover with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during keys recover with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.RegButtonClick(Sender: TObject);
var
  response: String;
  pubKey,prKey,login,pass,addr: String;
  splt: TArray<String>;
begin
  try
    response := AppCore.DoReg('*',SeedEdit.Text,pubKey,prKey,login,pass,addr);
    splt := response.Split([' ']);
    DoLog('Client ID: ' + splt[2]);
    DoLog(Format('Seed phrase:"%s"',[SeedEdit.Text]));
    DoLog('Login: ' + login);
    DoLog('Password: ' + pass);
    DoLog('Address: ' + addr);
    if AutoFillAuthCheckBox.IsChecked then
    begin
      LogInEdit.Text := login;
      PWEdit.Text := pass;
    end;
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Reg error: ' + E.Message,ERROR,tcp);
      DoLog('Reg error: ' + E.Message);
    end;
    on E:EAccAlreadyExistsError do
    begin
      Logs.DoLog('Reg error: account already exists',ERROR,tcp);
      DoLog('Reg error: account already exists');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during reg with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during reg with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during reg with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during reg with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.TokensBalancesButtonClick(Sender: TObject);
var
  response,str: String;
  i: Integer;
  tickersList: TStringList;
  splt,tokenInfo: TArray<String>;
begin
  try
    response := AppCore.DoGetCoinsBalances('*',SessionKeyEdit.Text);
    splt := response.Split([' '], '<', '>');
    str := '';
    tickersList := TStringList.Create(dupIgnore,True,False);
    tickersList.AddStrings(TokensEdit.Text.Split([',']));
    try
      for i := 2 to Length(splt) - 3 do
      begin
        tokenInfo := splt[i].Trim(['<','>']).Split([' ']);
        if (tickersList.IndexOf(tokenInfo[3]) <> -1) or tickersList.IsEmpty then
          str := Format('%s%s%s balance = %s%saddress body = %s',
            [str,sLineBreak,tokenInfo[3],tokenInfo[1],sLineBreak,tokenInfo[2]]);
      end;
      str := Trim(str);
      if str.IsEmpty then DoLog('data not found');
    finally
      tickersList.Free;
    end;
    DoLog(str);
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('Getting coins balances error: ' + E.Message,ERROR,tcp);
      DoLog('Getting coins balances error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('Getting coins balances error: key expired',ERROR,tcp);
      DoLog('Getting coins balances error: key expired');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during getting coins balances with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during getting coins balances with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during getting coins balances with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during TET getting coins balances message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.TransTETButtonClick(Sender: TObject);
var
  response: String;
  amount: Extended;
begin
  try
    if not TryStrToFloat(TETAmountEdit.Text.Replace('.',','), amount) then
      raise EValidError.Create('invalid amount');

    response := AppCore.DoCoinsTransfer('*',SessionKeyEdit.Text,TETSendToEdit.Text,
      amount);
    DoLog(Format('Transfer success, hash = %s',[response.Split([' '])[3]]));
  except
    on E:ESocketError do
    begin
      Logs.DoLog('Server did not respond',ERROR,tcp);
      DoLog('Server did not respond, try later');
    end;
    on E:EValidError do
    begin
      Logs.DoLog('TET transfer error: ' + E.Message,ERROR,tcp);
      DoLog('TET transfer error: ' + E.Message);
    end;
    on E:EKeyExpiredError do
    begin
      Logs.DoLog('TET transfer error: key expired',ERROR,tcp);
      DoLog('TET transfer error: key expired');
    end;
    on E:EAddressNotExistsError do
    begin
      Logs.DoLog('TET transfer error: address does not exists',ERROR,tcp);
      DoLog('TET transfer error: address does not exists');
    end;
    on E:EInsufficientFundsError do
    begin
      Logs.DoLog('TET transfer error: insufficient funds',ERROR,tcp);
      DoLog('TET transfer error: insufficient funds');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during TET transfer with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during TET transfer with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during TET with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during TET transfer with message: ' + E.Message);
    end;
  end;
end;

procedure TMainForm.TransTokenButtonClick(Sender: TObject);
var
  response: Byte;
  amount: Extended;
begin
  try
    if not TryStrToFloat(TokenAmountEdit.Text.Replace('.',','),amount) then
      raise EValidError.Create('incorrect amount');

    response := AppCore.DoTokenTransfer('*',TokenSendFromEdit.Text,TokenSendToEdit.Text,
      SmAddressEdit.Text,amount,PrKeyEdit.Text,PubKeyEdit.Text);
    case response of
      SUCCESS_CODE: DoLog('Transaction accepted for processing');
      ERROR_CODE : raise EValidError.Create('Transfer error: invalid signature');
      CONNECT_ERROR_CODE: raise EValidatorDidNotAnswerError.Create('');
    end;
  except
    on E:EValidError do
    begin
      Logs.DoLog('Token transfer error: ' + E.Message,ERROR,tcp);
      DoLog('Token transfer error: ' + E.Message);
    end;
    on E:ESameAddressesError do
    begin
      Logs.DoLog('Token transfer error: ' + E.Message,ERROR,tcp);
      DoLog('Token transfer error: ' + E.Message);
    end;
    on E:EValidatorDidNotAnswerError do
    begin
      Logs.DoLog('Token transfer error: validator did not answer, try later',ERROR,tcp);
      DoLog('Token transfer error: validator did not answer, try later');
    end;
    on E:EUnknownError do
    begin
      Logs.DoLog('Unknown error during token transfer with code ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during token transfer with code ' + E.Message);
    end;
    on E:Exception do
    begin
      Logs.DoLog('Unknown error during token with message: ' + E.Message,ERROR,tcp);
      DoLog('Unknown error during token transfer with message: ' + E.Message);
    end;
  end;
end;

end.
