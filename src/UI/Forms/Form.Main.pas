unit Form.Main;

interface

uses
  App.Exceptions,
  App.Logs,
  App.Intf,
  Blockchain.BaseTypes,
  Blockchain.Intf,
  Frame.Explorer,
  Frame.History,
  Frame.PageNum,
  Frame.Ticker,
  Generics.Collections,
  Math,
  Net.Data,
  Net.Socket,
  Styles,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.Edit, FMX.TabControl, FMX.Platform,
  FMX.ListBox, FMX.Effects, FMX.Objects, FMX.Layouts, FMX.StdCtrls, FMX.Ani,
  System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, FMX.Memo.Types, FMX.Memo;

type
  TMainForm = class(TForm)
    Tabs: TTabControl;
    TokensTabItem: TTabItem;
    ExplorerTabItem: TTabItem;
    PopupRectangle: TRectangle;
    ShadowEffect2: TShadowEffect;
    ShadowEffect1: TShadowEffect;
    SearchTokenEdit: TEdit;
    ShadowEffect3: TShadowEffect;
    TokensListBox: TListBox;
    MainRectangle: TRectangle;
    TokenNameEdit: TEdit;
    RecepientAddressEdit: TEdit;
    ShadowEffect4: TShadowEffect;
    AmountTokenEdit: TEdit;
    ShadowEffect5: TShadowEffect;
    SendTokenButton: TButton;
    HideTokenMessageTimer: TTimer;
    HistoryTokenHeaderLayout: TLayout;
    ExplorerHeaderLayout: TLayout;
    ExplorerHorzScrollBox: THorzScrollBox;
    TectumTabItem: TTabItem;
    BalanceTETLabel: TLabel;
    BalanceTETValueLabel: TLabel;
    AddressTETLabel: TLabel;
    SendTETToEdit: TEdit;
    ShadowEffect6: TShadowEffect;
    AmountTETEdit: TEdit;
    ShadowEffect7: TShadowEffect;
    SendTETButton: TButton;
    HistoryTETLabel: TLabel;
    HistoryTETHeaderLayout: TLayout;
    DateTimeTETHeaderLabel: TLabel;
    BlockNumTETHeaderLabel: TLabel;
    AddressTETHeaderLabel: TLabel;
    HashTETHeaderLabel: TLabel;
    AmountTETHeaderLabel: TLabel;
    BalanceTETHeaderLayout: TLayout;
    SendTETDataLayout: TLayout;
    TransferTETStatusLabel: TLabel;
    FloatAnimation2: TFloatAnimation;
    HideTETMessageTimer: TTimer;
    TokenHeaderLayout: TLayout;
    AddressTokenLabel: TLabel;
    BalanceTokenLabel: TLabel;
    BalanceTokenValueLabel: TLabel;
    SendTokenDataLayout: TLayout;
    HistoryTokenLabel: TLabel;
    AmountTokenHeaderLabel: TLabel;
    BlockNumTokenHeaderLabel: TLabel;
    DateTimeTokenHeaderLabel: TLabel;
    AddressTokenHeaderLabel: TLabel;
    HashTokenHeaderLabel: TLabel;
    TransferTokenStatusLabel: TLabel;
    FloatAnimation1: TFloatAnimation;
    AmountExplorerHeaderLabel: TLabel;
    BlockNumExplorerHeaderLabel: TLabel;
    DateTimeExplorerHeaderLabel: TLabel;
    FromExplorerHeaderLabel: TLabel;
    HashExplorerHeaderLabel: TLabel;
    ToExplorerHeaderLabel: TLabel;
    CreateTokenTabItem: TTabItem;
    CreateTokenLabel: TLabel;
    CreateTokenDataLayout: TLayout;
    CreateTokenShortNameEdit: TEdit;
    ShadowEffect8: TShadowEffect;
    CreateTokenNameLabel: TLabel;
    CreateTokenSymbolEdit: TEdit;
    ShadowEffect9: TShadowEffect;
    CreateTokenSymbolLabel: TLabel;
    CreateTokenAmountEdit: TEdit;
    ShadowEffect10: TShadowEffect;
    AmountLabel: TLabel;
    DecimalsEdit: TEdit;
    ShadowEffect11: TShadowEffect;
    DecimalsLabel: TLabel;
    CreateTokenInformationLabel: TLabel;
    CreateTokenInformationMemo: TMemo;
    ShadowEffect12: TShadowEffect;
    TokenCreationFeeLabel: TLabel;
    CreateTokenButton: TButton;
    NewTokenHelpInfoRectangle: TRectangle;
    NewTokenHelpInfoLabel1: TLabel;
    NewTokenHelpInfoLabel2: TLabel;
    NewTokenHelpInfoLabel3: TLabel;
    NewTokenHelpInfoLabel4: TLabel;
    NewTokenHelpInfoLabel5: TLabel;
    NewTokenHelpInfoLabel6: TLabel;
    NewTokenHelpInfoLabel7: TLabel;
    NewTokenHelpTokenNameLayout: TLayout;
    NewTokenHelpTokenSymbolLayout: TLayout;
    NewTokenHelpAmountLayout: TLayout;
    NewTokenHelpDecimalsLayout: TLayout;
    NewTokenHelpTokenNameLabel: TLabel;
    NewTokenHelpTokenNameLabel2: TLabel;
    NewTokenHelpTokenSymbolLabel: TLabel;
    NewTokenHelpTokenSymbolLabel2: TLabel;
    NewTokenHelpAmountLabel2: TLabel;
    NewTokenHelpAmountLabel: TLabel;
    NewTokenHelpDecimalsLabel: TLabel;
    NewTokenHelpDecimalsLabel2: TLabel;
    NewTokenHelpTokenInfoLayout: TLayout;
    NewTokenHelpTokenInfoLabel: TLabel;
    NewTokenHelpTokenInfoLabel2: TLabel;
    NewTokenHelpTokenInfoLabel3: TLabel;
    TokenCreatingStatusLabel: TLabel;
    FloatAnimation3: TFloatAnimation;
    HideCreatingMessageTimer: TTimer;
    ExplorerTabControl: TTabControl;
    ExporerTabItemData: TTabItem;
    ExplorerTransactionDataTabItem: TTabItem;
    ExpTransactionDetailsLabel: TLabel;
    ExpTransactionDetailsLayout: TLayout;
    TransactionDetailsRectangle: TRectangle;
    HashDetailsLayout: TLayout;
    HashDetailsLabel: TLabel;
    BlockDetailsLayout: TLayout;
    BlockDetailsLabel: TLabel;
    DateTimeDetailsLayout: TLayout;
    DateTimeDetailsLabel: TLabel;
    BlockDetailsText: TText;
    HashDetailsText: TText;
    DateTimeDetailsText: TText;
    Line1: TLine;
    FromDetailsLayout: TLayout;
    FromDetailsLabel: TLabel;
    FromDetailsText: TText;
    ToDetailsLayout: TLayout;
    ToDetalisLabel: TLabel;
    ToDetailsText: TText;
    Line2: TLine;
    AmountDetailsLayout: TLayout;
    AmountDetailsLabel: TLabel;
    AmountDetailsText: TText;
    TokenDetailsLayout: TLayout;
    TokenDetailsLabel: TLabel;
    TokenDetailsText: TText;
    TokenInfoDetailsLayout: TLayout;
    TokenInfoDetailsLabel: TLabel;
    TokenInfoDetailsLabelValue: TLabel;
    ExplorerBackArrowPath: TPath;
    ExplorerBackCircle: TCircle;
    FeeDetailsLayout: TLayout;
    FeeDetailsLabel: TLabel;
    FeeDetailsText: TText;
    CopyLoginLayout: TLayout;
    CopyHashSvg: TPath;
    CopyFromLayout: TLayout;
    CopyFromSvg: TPath;
    CopyToLayout: TLayout;
    CopyToSvg: TPath;
    TopExplorerHorzLayout: TLayout;
    NoTETHistoryLabel: TLabel;
    StatusTETHeaderLabel: TLabel;
    NoTokenHistoryLabel: TLabel;
    StatusTokenHeaderLabel: TLabel;
    TETTabControl: TTabControl;
    TETTabItemData: TTabItem;
    TETTransactionDataTabItem: TTabItem;
    TETTransactionDetailsLayout: TLayout;
    TETTransactionDetailsLabel: TLabel;
    TETBackCircle: TCircle;
    TETBackArrowPath: TPath;
    TETTransactionDetailsRectangle: TRectangle;
    TETHashDetailsLayout: TLayout;
    TETHashDetailsLabel: TLabel;
    TETHashDetailsText: TText;
    TETCopyLoginLayout: TLayout;
    TETCopyHashSvg: TPath;
    TETBlockDetailsLayout: TLayout;
    TETBlockDetailsLabel: TLabel;
    TETBlockDetailsText: TText;
    TETDateTimeDetailsLayout: TLayout;
    TETDateTimeDetailsLabel: TLabel;
    TETDateTimeDetailsText: TText;
    Line3: TLine;
    TETAddressDetailsLayout: TLayout;
    TETAddressDetailsLabel: TLabel;
    TETAddressDetailsText: TText;
    TETCopyAddressLayout: TLayout;
    TETCopyAddressSvg: TPath;
    Line4: TLine;
    TETAmountDetailsLayout: TLayout;
    TETAmountDetailsLabel: TLabel;
    TETAmountDetailsText: TText;
    TETDetailsLayout: TLayout;
    TETDetailsLabel: TLabel;
    TETDetailsText: TText;
    TETInfoDetailsLayout: TLayout;
    TETInfoDetailsLabel: TLabel;
    TETInfoDetailsLabelValue: TLabel;
    TETFeeDetailsLayout: TLayout;
    TETFeeDetailsLabel: TLabel;
    TETFeeDetailsText: TText;
    TokenInfoRectangle: TRectangle;
    TokenShortNameEdit: TEdit;
    TokenInfoMemo: TMemo;
    ExplorerVertScrollBox: TVertScrollBox;
    HistoryTETVertScrollBox: TVertScrollBox;
    HistoryTokenVertScrollBox: TVertScrollBox;
    TokenTabControl: TTabControl;
    TokenTabItemData: TTabItem;
    TokenTransactionDataTabItem: TTabItem;
    TokenTransactionDetailsLayout: TLayout;
    TokenTransactionDetailsLabel: TLabel;
    TokenBackCircle: TCircle;
    TokenBackArrowPath: TPath;
    TokenTransactionDetailsRectangle: TRectangle;
    TokenHashDetailsLayout: TLayout;
    TokenHashDetailsLabel: TLabel;
    TokenHashDetailsText: TText;
    TokenCopyLoginLayout: TLayout;
    TokenCopyHashSvg: TPath;
    TokenBlockDetailsLayout: TLayout;
    TokenBlockDetailsLabel: TLabel;
    TokenBlockDetailsText: TText;
    TokenDateTimeDetailsLayout: TLayout;
    TokenDateTimeDetailsLabel: TLabel;
    TokenDateTimeDetailsText: TText;
    Line5: TLine;
    TokenAddressDetailsLayout: TLayout;
    TokenAddressDetailsLabel: TLabel;
    TokenAddressDetailsText: TText;
    TokenCopyAddressLayout: TLayout;
    TokenCopyAddressSvg: TPath;
    Line6: TLine;
    TokenAmountDetailsLayout: TLayout;
    TokenAmountDetailsLabel: TLabel;
    TokenAmountDetailsText: TText;
    TokenDetailsAdvLayout: TLayout;
    TokenDetailsAdvLabel: TLabel;
    TokenDetailsAdvText: TText;
    TokenInfoDetailsAdvLayout: TLayout;
    TokenInfoDetailsAdvLabel: TLabel;
    TokenInfoDetailsAdvLabelValue: TLabel;
    TokenFeeDetailsLayout: TLayout;
    TokenFeeDetailsLabel: TLabel;
    TokenFeeDetailsText: TText;
    InputPrKeyButton: TButton;
    PaginationBottomLayout: TLayout;
    PagesPanelLayout: TLayout;
    NextPageLayout: TLayout;
    NextPagePath: TPath;
    PrevPageLayout: TLayout;
    PrevPagePath: TPath;
    SearchEdit: TEdit;
    SearchButton: TButton;
    TransactionNotFoundLabel: TLabel;
    FloatAnimation4: TFloatAnimation;
    HideTransactionNotFoundTimer: TTimer;
    AniIndicator1: TAniIndicator;
    procedure MainRectangleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure TokenItemClick(Sender: TObject);
    procedure TokenNameEditClick(Sender: TObject);
    procedure SearchTokenEditChangeTracking(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TokenItemApplyStyleLookup(Sender: TObject);
    procedure TokenNameEditChangeTracking(Sender: TObject);
    procedure RecepientAddressEditChangeTracking(Sender: TObject);
    procedure AmountTokenEditChangeTracking(Sender: TObject);
    procedure SendTokenButtonClick(Sender: TObject);
    procedure FloatAnimation1Finish(Sender: TObject);
    procedure HideTokenMessageTimerTimer(Sender: TObject);
    procedure RoundRectMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure AmountTETEditChangeTracking(Sender: TObject);
    procedure SendTETButtonClick(Sender: TObject);
    procedure FloatAnimation2Finish(Sender: TObject);
    procedure HideTETMessageTimerTimer(Sender: TObject);
    procedure ExplorerVertScrollBoxResized(Sender: TObject);
    procedure CreateTokenAmountEditChange(Sender: TObject);
    procedure CreateTokenButtonClick(Sender: TObject);
    procedure CreateTokenEditChangeTracking(Sender: TObject);
    procedure TabsChange(Sender: TObject);
    procedure HideCreatingMessageTimerTimer(Sender: TObject);
    procedure FloatAnimation3Finish(Sender: TObject);
    procedure ExplorerBackCircleMouseEnter(Sender: TObject);
    procedure ExplorerBackCircleMouseLeave(Sender: TObject);
    procedure ExplorerBackCircleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure CopyLoginLayoutClick(Sender: TObject);
    procedure CopyFromLayoutClick(Sender: TObject);
    procedure CopyToLayoutClick(Sender: TObject);
    procedure CreateTokenSymbolEditChangeTracking(Sender: TObject);
    procedure HistoryTETVertScrollBoxResized(Sender: TObject);
    procedure HistoryTETVertScrollBoxPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure ExplorerVertScrollBoxPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure HistoryTokenVertScrollBoxResized(Sender: TObject);
    procedure HistoryTokenVertScrollBoxPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure TETBackCircleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure TETCopyLoginLayoutClick(Sender: TObject);
    procedure TETCopyAddressLayoutClick(Sender: TObject);
    procedure TokenBackCircleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure TokenCopyLoginLayoutClick(Sender: TObject);
    procedure TokenCopyAddressLayoutClick(Sender: TObject);
    procedure InputPrKeyButtonClick(Sender: TObject);
    procedure PrevPageLayoutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure NextPageLayoutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure SearchEditChangeTracking(Sender: TObject);
    procedure SearchButtonClick(Sender: TObject);
    procedure SearchEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure FloatAnimation4Finish(Sender: TObject);
    procedure HideTransactionNotFoundTimerTimer(Sender: TObject);
  const
    TransToDrawNumber = 18;
  private
    FBalances: TDictionary<string, Double>;
    chosenToken, chosenTicker: string;
    totalPagesAmount, pageNum: Integer;

    function DecimalsCount(const AValue: string): Integer;
    procedure RefreshTETBalance;
    procedure RefreshTETHistory;
    procedure AlignTETHeaders;
    procedure RefreshHeaderBalance(AName: string);
    procedure RefreshTokensBalances;
    procedure RefreshTokenHistory;
    procedure AlignTokensHeaders;
    procedure RefreshPagesLayout;
    procedure OnPageSelected;
    procedure RefreshExplorer;
    procedure AlignExplorerHeaders;
    procedure CleanScrollBox(AVertScrollBox: TVertScrollBox);

    procedure AddTokenItem(AName: String; AValue: Extended);
    procedure AddTicker(AName: String);
    procedure AddPageNum(APageNum: Integer);
    procedure ShowTETTransferStatus(const AMessage: String; AIsError: Boolean = False);
    procedure ShowTokenTransferStatus(const AMessage: String; AIsError: Boolean = False);
    procedure ShowTokenCreatingStatus(const AMessage: String; AIsError: Boolean = False);
    procedure AddOrRefreshBalance(AName: String; AValue: Extended);
    procedure ShowExplorerTransactionDetails(ATicker, ADateTime, ABlockNum, AHash,
      ATransFrom, ATransTo, AAmount: string);

    procedure onTETHistoryFrameClick(Sender: TObject);
    procedure onTokenHistoryFrameClick(Sender: TObject);
    procedure onExplorerFrameClick(Sender: TObject);
    procedure onPageNumFrameClick(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure onTransactionSearchingDone(AIsFound: Boolean);
  public
    procedure NewChainBlocksEvent;
    procedure NewSmartBlocksEvent;
    procedure onKeysSaved;
    procedure onKeysSavingError;
  end;

var
  MainForm: TMainForm;

implementation

function CustomSortCompare(Left, Right: TFmxObject): Integer;
begin
  Result := CompareStr((Left as TListBoxItem).Text,(Right as TListBoxItem).Text);
end;

{$R *.fmx}

procedure TMainForm.TokenNameEditChangeTracking(Sender: TObject);
begin
  AmountTokenEditChangeTracking(nil);
  NoTokenHistoryLabel.Text := Format('No %s transactions yet',[TokenNameEdit.Text]);
  RefreshTokenHistory;
end;

procedure TMainForm.TokenNameEditClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to TokensListBox.Count-1 do
    TokensListBox.ListItems[i].OnApplyStyleLookup(TokensListBox.ListItems[i]);
  MainRectangle.Visible := True;
end;

procedure TMainForm.AddPageNum(APageNum: Integer);
var
  pageNumFrame: TPageNumFrame;
begin
  pageNumFrame := TPageNumFrame.Create(PagesPanelLayout,APageNum,APageNum = pageNum);
  pageNumFrame.Parent := PagesPanelLayout;
  PagesPanelLayout.Width := PagesPanelLayout.Width + PageNumFrame.Width;
  pageNumFrame.Position.Y := -2;
  pageNumFrame.Position.X := PagesPanelLayout.Width - NextPageLayout.Width -
    PageNumFrame.Width;
  if APageNum > 0 then
    pageNumFrame.OnMouseDown := onPageNumFrameClick;
end;

procedure TMainForm.AddTicker(AName: String);
var
  ticker: TTickerFrame;
begin
  ticker := TTickerFrame.Create(TopExplorerHorzLayout,AName);
  ticker.Parent := TopExplorerHorzLayout;
  ticker.Position.X := Single.MaxValue;
  ticker.RoundRect.OnMouseDown := RoundRectMouseDown;

  if AName = 'Tectum' then
  begin
    ticker.RoundRect.OnMouseDown(ticker,TMouseButton.mbLeft,[],0,0);
    TopExplorerHorzLayout.Width := ticker.Width;
  end else
    TopExplorerHorzLayout.Width := TopExplorerHorzLayout.Width + ticker.Width +
      ticker.Margins.Left;
end;

procedure TMainForm.AddTokenItem(AName: String; AValue: Extended);
var
  newItem: TListBoxItem;
begin
  newItem := TListBoxItem.Create(TokensListBox);
  newItem.Parent := TokensListBox;
  PopupRectangle.Height := SearchTokenEdit.Height +
    40 * (Min(TokensListBox.Count,3)) + 32;
  newItem.StyleLookup := 'TokenItemStyle';

  newItem.BeginUpdate;
  try
    with newItem do
    begin
      Name := 'TokenItem' + TokensListBox.Count.ToString;
      Margins.Top := 5;
      Text := AName;
      TextSettings.Font.Family := 'Inter';
      TextSettings.Font.Size := 14;
      TextSettings.FontColor := $FF323130;
      HitTest := True;

      onMouseEnter := StylesForm.OnTokenItemMouseEnter;
      onMouseLeave := StylesForm.OnTokenItemMouseLeave;
      onMouseDown := StylesForm.OnTokenItemMouseDown;
      onMouseUp := StylesForm.OnTokenItemMouseUp;
      onClick := TokenItemClick;
      onApplyStyleLookup := TokenItemApplyStyleLookup;
    end;
  finally
    newItem.EndUpdate;
  end;
  AddTicker(AName);
end;

procedure TMainForm.AlignExplorerHeaders;
var
  frame: TExplorerTransactionFrame;
  i: Integer;
begin
  ExplorerVertScrollBox.BeginUpdate;
  try
    frame := nil;
    for i := 0 to ExplorerVertScrollBox.ComponentCount-1 do
      if ExplorerVertScrollBox.Components[i] is TExplorerTransactionFrame then
      begin
        frame := ExplorerVertScrollBox.Components[i] as TExplorerTransactionFrame;
        break;
      end;
    if not Assigned(frame) then exit;

    DateTimeExplorerHeaderLabel.Width := frame.DateTimeLabel.Width;
    BlockNumExplorerHeaderLabel.Width := frame.BlockLabel.Width;
    FromExplorerHeaderLabel.Width := frame.FromLabel.Width;
    ToExplorerHeaderLabel.Width := frame.ToLabel.Width;
    HashExplorerHeaderLabel.Width := frame.HashLabel.Width;
    AmountExplorerHeaderLabel.Width := frame.AmountLabel.Width;
  finally
    ExplorerVertScrollBox.EndUpdate;
  end;
end;

procedure TMainForm.AlignTETHeaders;
var
  frame: THistoryTransactionFrame;
  i: Integer;
begin
  HistoryTETVertScrollBox.BeginUpdate;
  try
    frame := nil;
    for i := 0 to HistoryTETVertScrollBox.ComponentCount-1 do
      if HistoryTETVertScrollBox.Components[i] is THistoryTransactionFrame then
      begin
        frame := HistoryTETVertScrollBox.Components[i] as THistoryTransactionFrame;
        break;
      end;
    if not Assigned(frame) then exit;

    DateTimeTETHeaderLabel.Width := frame.DateTimeLabel.Width;
    BlockNumTETHeaderLabel.Width := frame.BlockLabel.Width;
    AddressTETHeaderLabel.Width := frame.AddressLabel.Width;
    HashTETHeaderLabel.Width := frame.HashLabel.Width;
    AmountTETHeaderLabel.Width := frame.AmountLabel.Width;
  finally
    HistoryTETVertScrollBox.EndUpdate;
  end;
end;

procedure TMainForm.AlignTokensHeaders;
var
  frame: THistoryTransactionFrame;
  i: Integer;
begin
  HistoryTokenVertScrollBox.BeginUpdate;
  try
    frame := nil;
    for i := 0 to HistoryTokenVertScrollBox.ComponentCount-1 do
      if HistoryTokenVertScrollBox.Components[i] is THistoryTransactionFrame then
      begin
        frame := HistoryTokenVertScrollBox.Components[i] as THistoryTransactionFrame;
        break;
      end;
    if not Assigned(frame) then exit;

    DateTimeTokenHeaderLabel.Width := frame.DateTimeLabel.Width;
    BlockNumTokenHeaderLabel.Width := frame.BlockLabel.Width;
    AddressTokenHeaderLabel.Width := frame.AddressLabel.Width;
    HashTokenHeaderLabel.Width := frame.HashLabel.Width;
    AmountTokenHeaderLabel.Width := frame.AmountLabel.Width;
  finally
    HistoryTokenVertScrollBox.EndUpdate;
  end;
end;

procedure TMainForm.AmountTokenEditChangeTracking(Sender: TObject);
var
  isNumber: Boolean;
  val,balance: Double;
  tICO: TTokenICODat;
begin
//  const isGetTokenSuccess = AppCore.TryGetTokenICO(TokenNameEdit.Text, tICO);
  FBalances.TryGetValue(TokenNameEdit.Text, balance);
  isNumber := TryStrToFloat(AmountTokenEdit.Text, val);

  const Decimals = DecimalsCount(AmountTokenEdit.Text);

//  SendTokenButton.Enabled := isGetTokenSuccess and (Length(RecepientAddressEdit.Text) >= 10) and
//    isNumber and (val > 0) and (val <= balance) and (Decimals <= tICO.FloatSize);

  with TransferTokenStatusLabel do
  begin
    if isNumber and (val > balance) then
    begin
      Text := 'Insufficient funds';
      TextSettings.FontColor := ERROR_TEXT_COLOR;
      Opacity := 1;
    end
    else if (Decimals > tICO.FloatSize) then
    begin
      Text := 'Too much digits';
      TextSettings.FontColor := ERROR_TEXT_COLOR;
      Opacity := 1;
    end else
      Opacity := 0;
  end;
end;

procedure TMainForm.ExplorerBackCircleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  ExplorerTabControl.Previous;
  SearchEdit.SetFocus;
end;

procedure TMainForm.ExplorerBackCircleMouseEnter(Sender: TObject);
begin
  (Sender as TCircle).Fill.Kind := TBrushKind.Solid;
end;

procedure TMainForm.ExplorerBackCircleMouseLeave(Sender: TObject);
begin
  (Sender as TCircle).Fill.Kind := TBrushKind.None;
end;

procedure TMainForm.TETBackCircleMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  TETTabControl.Previous;
end;

procedure TMainForm.CleanScrollBox(AVertScrollBox: TVertScrollBox);
var
  component: TComponent;
  i: Integer;
begin
  AVertScrollBox.BeginUpdate;
  try
    i := 0;
    repeat
      component := AVertScrollBox.Components[i];
      if (AVertScrollBox.Components[i] is TExplorerTransactionFrame) or
         (AVertScrollBox.Components[i] is THistoryTransactionFrame) then
        component.Free
      else
        Inc(i);
    until i = AVertScrollBox.ComponentCount;
  finally
    AVertScrollBox.EndUpdate;
  end;
end;

procedure TMainForm.CopyFromLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(FromDetailsText.Text);
end;

procedure TMainForm.CopyLoginLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(HashDetailsText.Text);
end;

procedure TMainForm.CopyToLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(ToDetailsText.Text);
end;

procedure TMainForm.CreateTokenAmountEditChange(Sender: TObject);
var
  value: Int64;
begin
  if TryStrToInt64(CreateTokenAmountEdit.Text,value) then
    CreateTokenAmountEdit.Text := Max(value,1).ToString;
end;

procedure TMainForm.CreateTokenButtonClick(Sender: TObject);
var
  response: string;
begin
  try
//    response := AppCore.DoNewToken('*',AppCore.SessionKey,
//      CreateTokenInformationMemo.Text, CreateTokenShortNameEdit.Text,
//      CreateTokenSymbolEdit.Text, CreateTokenAmountEdit.Text.ToInt64,
//      DecimalsEdit.Text.ToInteger);

    CreateTokenShortNameEdit.Text := '';
    CreateTokenSymbolEdit.Text := '';
    CreateTokenAmountEdit.Text := '';
    DecimalsEdit.Text := '';
    CreateTokenInformationMemo.Text := '';
    ShowTokenCreatingStatus('Token successfully created');
  except
    on E:EValidError do
      ShowTokenCreatingStatus(E.Message,True);
    on E:EKeyExpiredError do
      ShowTokenCreatingStatus('Session key expired, please relogin',True);
    on E:ETokenAlreadyExists do
      ShowTokenCreatingStatus('Token already exists',True);
    on E:EInsufficientFundsError do
      ShowTokenCreatingStatus('Insufficient funds to pay the fee',True);
    on E:EUnknownError do
    begin
      ShowTokenCreatingStatus('Unknown error with code ' + E.Message,True);
      Logs.DoLog('Unknown error during token creating with code ' + E.Message,ERROR,tcp);
    end;
    on E:Exception do
    begin
      ShowTokenCreatingStatus('Unknown error',True);
      Logs.DoLog('Unknown error during token creating  with message: ' + E.Message,ERROR,tcp);
    end;
  end;
end;

procedure TMainForm.CreateTokenEditChangeTracking(Sender: TObject);
var
  k: Integer;
  l: Int64;
begin
  with TokenCreatingStatusLabel do
  begin
    if TryStrToInt(DecimalsEdit.Text,k) and
      (k + Length(CreateTokenAmountEdit.Text) > 18) then
    begin
      Text := 'The sum of the digits of the quantity and ' +
        'the value of the "Decimal" field must not be greater than 18';
      TextSettings.FontColor := ERROR_TEXT_COLOR;
      Opacity := 1;
    end else
      Opacity := 0;
  end;

  CreateTokenButton.Enabled := (Length(CreateTokenShortNameEdit.Text) >= 3) and
    (Length(CreateTokenSymbolEdit.Text) >= 3) and
    TryStrToInt64(CreateTokenAmountEdit.Text,l) and (l >= 1000) and
    (l <= 9999999999999999) and TryStrToInt(DecimalsEdit.Text,k) and
    (Length(CreateTokenInformationMemo.Text) >= 10) and
    (TokenCreatingStatusLabel.Opacity = 0);

//  if CreateTokenButton.Enabled and TryStrToInt64(CreateTokenAmountEdit.Text,l) and
//    TryStrToInt(DecimalsEdit.Text,k) then
//    TokenCreationFeeLabel.Text := Format('Creation token fee: %d TET',
//      [AppCore.GetNewTokenFee(l,k)])
//  else
    TokenCreationFeeLabel.Text := 'Creation token fee: 0 TET';
end;

procedure TMainForm.CreateTokenSymbolEditChangeTracking(Sender: TObject);
begin
  CreateTokenSymbolEdit.Text := CreateTokenSymbolEdit.Text.ToUpper;
  CreateTokenEditChangeTracking(Self);
end;

function TMainForm.DecimalsCount(const AValue: string): Integer;
begin
  const TrimmedValue = AValue //
    .Trim //
    .Replace('.', FormatSettings.DecimalSeparator) //
    .Replace(',', FormatSettings.DecimalSeparator);
  const DecimalPos = Pos(FormatSettings.DecimalSeparator, TrimmedValue);
  if DecimalPos = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := Length(TrimmedValue) - DecimalPos;
end;

procedure TMainForm.ExplorerVertScrollBoxPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  AlignExplorerHeaders;
end;

procedure TMainForm.ExplorerVertScrollBoxResized(Sender: TObject);
begin
  AlignExplorerHeaders;
end;

procedure TMainForm.TokenItemClick(Sender: TObject);
var
  tICO: TTokenICODat;
begin
  TokenNameEdit.Text := (Sender as TListBoxItem).Text;
  chosenToken := (Sender as TListBoxItem).Text;
  RefreshHeaderBalance(TokenNameEdit.Text);
  MainRectangleMouseDown(nil,TMouseButton.mbLeft,[],0,0);

//  if AppCore.TryGetTokenICO(TokenNameEdit.Text,tICO) then
//  begin
//    TokenShortNameEdit.Text := tICO.ShortName;
//    TokenInfoMemo.Text := tICO.FullName;
//  end else
//  begin
//    TokenShortNameEdit.Text := '';
//    TokenInfoMemo.Text := '';
//  end;
end;

procedure TMainForm.FloatAnimation1Finish(Sender: TObject);
begin
  FloatAnimation1.Inverse := not FloatAnimation1.Inverse;
  if FloatAnimation1.Inverse then
    HideTokenMessageTimer.Enabled := True;
end;

procedure TMainForm.FloatAnimation2Finish(Sender: TObject);
begin
  FloatAnimation2.Inverse := not FloatAnimation2.Inverse;
  if FloatAnimation2.Inverse then
    HideTETMessageTimer.Enabled := True;
end;

procedure TMainForm.FloatAnimation3Finish(Sender: TObject);
begin
  FloatAnimation3.Inverse := not FloatAnimation3.Inverse;
  if FloatAnimation3.Inverse then
    HideCreatingMessageTimer.Enabled := True;
end;

procedure TMainForm.FloatAnimation4Finish(Sender: TObject);
begin
  FloatAnimation4.Inverse := not FloatAnimation4.Inverse;
  FloatAnimation4.Enabled := False;
  HideTransactionNotFoundTimer.Enabled := FloatAnimation4.Inverse;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := 'LNode' + ' ' + AppCore.GetVersion;
  FBalances := TDictionary<string, Double>.Create;

  TETCopyLoginLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  TETCopyLoginLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  TETCopyLoginLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  TETCopyLoginLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;

  TETCopyAddressLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  TETCopyAddressLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  TETCopyAddressLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  TETCopyAddressLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;

  TokenCopyLoginLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  TokenCopyLoginLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  TokenCopyLoginLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  TokenCopyLoginLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;

  TokenCopyAddressLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  TokenCopyAddressLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  TokenCopyAddressLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  TokenCopyAddressLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;

  CopyLoginLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  CopyLoginLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  CopyLoginLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  CopyLoginLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;

  CopyFromLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  CopyFromLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  CopyFromLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  CopyFromLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;

  CopyToLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  CopyToLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  CopyToLayout.OnMouseDown := StylesForm.OnCopyLayoutMouseDown;
  CopyToLayout.OnMouseUp := StylesForm.OnCopyLayoutMouseUp;

  PrevPageLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  PrevPageLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;
  NextPageLayout.OnMouseEnter := StylesForm.OnCopyLayoutMouseEnter;
  NextPageLayout.OnMouseLeave := StylesForm.OnCopyLayoutMouseLeave;

  chosenToken := '';
  chosenTicker := '';
//  AddTicker('Tectum');

  const Digitals = '0123456789' + FormatSettings.DecimalSeparator;
  AmountTETEdit.FilterChar := Digitals;
  AmountTokenEdit.FilterChar := Digitals;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FBalances.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  AddressTETLabel.Text := AppCore.TETAddress;
  RefreshTETBalance;
  RefreshTokensBalances;
  RefreshTETHistory;
end;

procedure TMainForm.HideCreatingMessageTimerTimer(Sender: TObject);
begin
  HideCreatingMessageTimer.Enabled := False;
  FloatAnimation3.Start;
end;

procedure TMainForm.HideTETMessageTimerTimer(Sender: TObject);
begin
  HideTETMessageTimer.Enabled := False;
  FloatAnimation2.Start;
end;

procedure TMainForm.HideTokenMessageTimerTimer(Sender: TObject);
begin
  HideTokenMessageTimer.Enabled := False;
  FloatAnimation1.Start;
end;

procedure TMainForm.HideTransactionNotFoundTimerTimer(Sender: TObject);
begin
  HideTransactionNotFoundTimer.Enabled := False;
  FloatAnimation4.Enabled := True;
end;

procedure TMainForm.HistoryTETVertScrollBoxPaint(Sender: TObject;
  Canvas: TCanvas; const ARect: TRectF);
begin
  AlignTETHeaders;
end;

procedure TMainForm.HistoryTETVertScrollBoxResized(Sender: TObject);
begin
  AlignTETHeaders;
end;

procedure TMainForm.HistoryTokenVertScrollBoxPaint(Sender: TObject;
  Canvas: TCanvas; const ARect: TRectF);
begin
  AlignTokensHeaders;
end;

procedure TMainForm.HistoryTokenVertScrollBoxResized(Sender: TObject);
begin
  AlignTokensHeaders;
end;

procedure TMainForm.InputPrKeyButtonClick(Sender: TObject);
begin
  UI.ShowEnterPrivateKeyForm;
end;

procedure TMainForm.TabsChange(Sender: TObject);
begin
  case Tabs.TabIndex of
    0: SendTETToEdit.SetFocus;
    1: RecepientAddressEdit.SetFocus;
    2: CreateTokenShortNameEdit.SetFocus;
    3: begin
         ExplorerTabControl.TabIndex := 0;
         SearchEdit.SetFocus;
       end;
  end;
end;

procedure TMainForm.TETCopyAddressLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(TETAddressDetailsText.Text);
end;

procedure TMainForm.TETCopyLoginLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(TETHashDetailsText.Text);
end;

procedure TMainForm.TokenBackCircleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  TokenTabControl.Previous;
end;

procedure TMainForm.TokenCopyAddressLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(TokenAddressDetailsText.Text);
end;

procedure TMainForm.TokenCopyLoginLayoutClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(TokenHashDetailsText.Text);
end;

procedure TMainForm.TokenItemApplyStyleLookup(Sender: TObject);
var
  item: TListBoxItem;
  rect: TRectangle;
  valueLabel: TLabel;
  value: Double;
begin
  item := Sender as TListBoxItem;
  item.BeginUpdate;
  try
    rect := item.FindStyleResource('RectangleStyle') as TRectangle;
    if Assigned(rect) then
    begin
      valueLabel := rect.FindStyleResource('TokenAmountLabelStyle') as TLabel;
      if FBalances.TryGetValue(item.Text, value) then
        valueLabel.Text := FormatFloat('0.########',value);
    end;
  finally
    item.EndUpdate;
  end;
end;

procedure TMainForm.MainRectangleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  MainRectangle.Visible := False;
  SearchTokenEdit.Text := '';
end;

procedure TMainForm.NewChainBlocksEvent;
begin
  RefreshTETBalance;
  RefreshTETHistory;
  RefreshPagesLayout;
  RefreshExplorer;
end;

procedure TMainForm.OnPageSelected;
var
  frame: TPageNumFrame;
  i: Integer;
begin
  for i := 0 to PagesPanelLayout.ComponentCount-1 do
  begin
    if (PagesPanelLayout.Components[i] is TPageNumFrame) then
    begin
      frame := PagesPanelLayout.Components[i] as TPageNumFrame;
      if ((PagesPanelLayout.Components[i] as TPageNumFrame).Tag = pageNum) then
        frame.PageNumText.TextSettings.FontColor := $FF4285F4
      else
        frame.PageNumText.TextSettings.FontColor := MOUSE_LEAVE_COLOR;
    end;
  end;

  PrevPageLayout.Enabled := pageNum > 1;
  NextPageLayout.Enabled := pageNum < totalPagesAmount;
  RefreshExplorer;
end;

procedure TMainForm.NewSmartBlocksEvent;
begin
  RefreshTokensBalances;
  RefreshTokenHistory;
  RefreshPagesLayout;
  RefreshExplorer;
end;

procedure TMainForm.NextPageLayoutMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Inc(pageNum);
  RefreshPagesLayout;
end;

procedure TMainForm.onExplorerFrameClick(Sender: TObject);
begin
  with (Sender as TExplorerTransactionFrame) do
  begin
    ShowExplorerTransactionDetails(chosenTicker, DateTimeLabel.Text,
      BlockLabel.Text, HashLabel.Text, FromLabel.Text, ToLabel.Text,
      AmountLabel.Text);
  end;
end;

procedure TMainForm.onKeysSaved;
begin
  InputPrKeyButton.Visible := False;
  ShowTokenTransferStatus('Keys saved successfully');
end;

procedure TMainForm.onKeysSavingError;
begin
  ShowTokenTransferStatus('Error saving keys: invalid private key',True);
end;

procedure TMainForm.onPageNumFrameClick(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if pageNum = (Sender as TPageNumFrame).Tag then
    exit;
  pageNum := (Sender as TPageNumFrame).Tag;
  RefreshPagesLayout;
end;

procedure TMainForm.onTETHistoryFrameClick(Sender: TObject);
var
  ticker: String;
  tICO: TTokenICODat;
begin
//  if not AppCore.TryGetTokenICO('TET',tICO) then
//    exit;

  with (Sender as THistoryTransactionFrame) do
  begin
    TETDateTimeDetailsText.AutoSize := False;
    TETDateTimeDetailsText.Text := DateTimeLabel.Text;
    TETDateTimeDetailsText.AutoSize := True;

    TETBlockDetailsText.AutoSize := False;
    TETBlockDetailsText.Text := BlockLabel.Text;
    TETBlockDetailsText.AutoSize := True;

    if IncomText.Text = 'OUT' then
      TETAddressDetailsLabel.Text := 'To'
    else
      TETAddressDetailsLabel.Text := 'From';

    TETAddressDetailsText.AutoSize := False;
    TETAddressDetailsText.Text := AddressLabel.Text;
    TETAddressDetailsText.AutoSize := True;

    TETHashDetailsText.AutoSize := False;
    TETHashDetailsText.Text := HashLabel.Text;
    TETHashDetailsText.AutoSize := True;

    TETAmountDetailsText.AutoSize := False;
    TETAmountDetailsText.Text := AmountLabel.Text;
    TETAmountDetailsText.AutoSize := True;

    TETDetailsText.AutoSize := False;
    TETDetailsText.Text := Format('%s (%s)',[tICO.Abreviature,tICO.ShortName]);
    TETDetailsText.AutoSize := True;

    TETInfoDetailsLabelValue.AutoSize := False;
    TETInfoDetailsLabelValue.Text := tICO.FullName;
    TETInfoDetailsLabelValue.AutoSize := True;
  end;
  TETTransactionDetailsRectangle.Height := TETInfoDetailsLabelValue.Height + 381;

  TETTabControl.Next;
end;

procedure TMainForm.onTokenHistoryFrameClick(Sender: TObject);
var
  ticker: String;
  tICO: TTokenICODat;
begin
//  if not AppCore.TryGetTokenICO(TokenNameEdit.Text,tICO) then
//    exit;

  with (Sender as THistoryTransactionFrame) do
  begin
    TokenDateTimeDetailsText.AutoSize := False;
    TokenDateTimeDetailsText.Text := DateTimeLabel.Text;
    TokenDateTimeDetailsText.AutoSize := True;

    TokenBlockDetailsText.AutoSize := False;
    TokenBlockDetailsText.Text := BlockLabel.Text;
    TokenBlockDetailsText.AutoSize := True;

    if IncomText.Text = 'OUT' then
      TokenAddressDetailsLabel.Text := 'To'
    else
      TokenAddressDetailsLabel.Text := 'From';

    TokenAddressDetailsText.AutoSize := False;
    TokenAddressDetailsText.Text := AddressLabel.Text;
    TokenAddressDetailsText.AutoSize := True;

    TokenHashDetailsText.AutoSize := False;
    TokenHashDetailsText.Text := HashLabel.Text;
    TokenHashDetailsText.AutoSize := True;

    TokenAmountDetailsText.AutoSize := False;
    TokenAmountDetailsText.Text := AmountLabel.Text;
    TokenAmountDetailsText.AutoSize := True;

    TokenDetailsAdvText.AutoSize := False;
    TokenDetailsAdvText.Text := Format('%s (%s)',[tICO.Abreviature,tICO.ShortName]);
    TokenDetailsAdvText.AutoSize := True;

    TokenInfoDetailsAdvLabelValue.AutoSize := False;
    TokenInfoDetailsAdvLabelValue.Text := tICO.FullName;
    TokenInfoDetailsAdvLabelValue.AutoSize := True;
  end;
  TokenTransactionDetailsRectangle.Height := TokenInfoDetailsAdvLabelValue.Height + 381;

  TokenTabControl.Next;
end;

procedure TMainForm.onTransactionSearchingDone(AIsFound: Boolean);
begin
  FloatAnimation4.Enabled := not AIsFound;
end;

procedure TMainForm.PrevPageLayoutMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Dec(pageNum);
  RefreshPagesLayout;
end;

procedure TMainForm.RecepientAddressEditChangeTracking(Sender: TObject);
begin
  if Length(RecepientAddressEdit.Text) = 42 then
    TokenNameEditChangeTracking(nil)
  else
    SendTokenButton.Enabled := False;
end;

procedure TMainForm.RefreshExplorer;
var
  transArray: TArray<TExplorerTransactionInfo>;
  newTransFrame: TExplorerTransactionFrame;
  i,TransNumber,pagesAmount: Integer;
  format: string;
  tICO: TTokenICODat;
  smartKey: TCSmartKey;
begin
  if chosenTicker.IsEmpty then exit;

  TransNumber := TransToDrawNumber;
//  if chosenTicker = 'Tectum' then
//  begin
//    i := AppCore.GetChainBlocksCount - pageNum * TransNumber;
//    if i < 0 then
//    begin
//      Inc(TransNumber,i);
//      i := 0;
//    end;
//    transArray := AppCore.GetChainTransations(i,TransNumber);
//    if not AppCore.TryGetTokenICO('TET',tICO) then exit;
//  end else
//  begin
//    if not AppCore.TryGetTokenBase(chosenTicker,smartKey) then exit;
//    i := AppCore.GetSmartBlocksCount(smartKey.SmartID) - pageNum * TransNumber;
//    if i < 0 then
//    begin
//      Inc(TransNumber,i);
//      i := 0;
//    end;
//    transArray := AppCore.GetSmartTransactions(chosenTicker,i,TransNumber);
//    if not AppCore.TryGetTokenICO(chosenTicker,tICO) then exit;
//  end;

  CleanScrollBox(ExplorerVertScrollBox);
  ExplorerVertScrollBox.BeginUpdate;
  try
    format := '0.' + string.Create('0', tICO.FloatSize);
    for i := TransNumber - 1 downto 0 do
    begin
//      newTransFrame := TExplorerTransactionFrame.Create(ExplorerVertScrollBox,
//                                                        transArray[i].DateTime,
//                                                        transArray[i].BlockNum,
//                                                        transArray[i].TransFrom,
//                                                        transArray[i].TransTo,
//                                                        transArray[i].Hash,
//                                                        FormatFloat(format,transArray[i].Amount));
      newTransFrame.OnClick := onExplorerFrameClick;
      newTransFrame.Parent := ExplorerVertScrollBox;
    end;
  finally
    ExplorerVertScrollBox.EndUpdate;
    AlignExplorerHeaders;
  end;
end;

procedure TMainForm.RefreshHeaderBalance(AName: String);
var
  value: Double;
begin
  if FBalances.TryGetValue(AName,value) then
    BalanceTokenValueLabel.Text :=
      Format('%s %s',[FormatFloat('0.########',value), AName]);

//  AddressTokenLabel.Text := AppCore.GetSmartAddressByTicker(AName);
end;

procedure TMainForm.RefreshPagesLayout;
const
  AtTheEdges = 5;
var
  i,PageNumToDraw,PagesToDraw,TotalBlocksNumber: Integer;
  TokenBase: TCSmartKey;
begin
//  if chosenTicker = 'Tectum' then
//  begin
//    TotalBlocksNumber := AppCore.GetChainBlocksCount;
//    TotalPagesAmount := TotalBlocksNumber div TransToDrawNumber;
//    if TotalBlocksNumber mod TransToDrawNumber > 0 then
//      Inc(TotalPagesAmount);
//  end else
//  begin
//    if not AppCore.TryGetTokenBase(chosenTicker,TokenBase) then
//      exit;
//    TotalBlocksNumber := AppCore.GetSmartBlocksCount(TokenBase.SmartID);
//    TotalPagesAmount := TotalBlocksNumber div TransToDrawNumber;
//    if TotalBlocksNumber mod TransToDrawNumber > 0 then
//      Inc(TotalPagesAmount);
//  end;

  PaginationBottomLayout.BeginUpdate;
  PagesPanelLayout.BeginUpdate;
  try
    PagesPanelLayout.DestroyComponents;
    PagesPanelLayout.Width := 48;
    PaginationBottomLayout.Visible := TotalPagesAmount > 1;
    if not PaginationBottomLayout.Visible then
      exit;

    PagesToDraw := 3 + AtTheEdges * 2;
    AddPageNum(1);
    if (pageNum - AtTheEdges > 3) and (TotalPagesAmount > PagesToDraw + 2) then
    begin
      AddPageNum(-1);
      Dec(PagesToDraw);
    end;
    if (pageNum + AtTheEdges < TotalPagesAmount - 2) and
      (TotalPagesAmount > PagesToDraw + 2) then
      Dec(PagesToDraw);
    PageNumToDraw := Max(2,Min(TotalPagesAmount - PagesToDraw,pageNum - AtTheEdges));
    if (pageNum - AtTheEdges = 3) then
      Dec(PageNumToDraw);
    for i := PageNumToDraw to pageNum do
    begin
      if (i = 1) or (i = TotalPagesAmount) then
        continue;
      AddPageNum(i);
    end;
    PageNumToDraw := Min(TotalPagesAmount - 1,Max(PagesToDraw + 1,pageNum + AtTheEdges));
    if (pageNum + AtTheEdges = TotalPagesAmount - 2) then
      Inc(PageNumToDraw);
    for i := pageNum + 1 to PageNumToDraw do
    begin
      if (i = 1) or (i = TotalPagesAmount) then
        continue;
      AddPageNum(i);
    end;
    if (pageNum + AtTheEdges < TotalPagesAmount - 2) and
      (TotalPagesAmount > PagesToDraw + 2) then
      AddPageNum(-1);
    AddPageNum(TotalPagesAmount);
    OnPageSelected;
  finally
    PagesPanelLayout.EndUpdate;
    PaginationBottomLayout.EndUpdate;
    RefreshExplorer;
  end;
end;

procedure TMainForm.RefreshTETBalance;
var
  Balance: Double;
begin
  try
    Balance := AppCore.GetTETBalance;
    FBalances.AddOrSetValue('TET', Balance);
    BalanceTETValueLabel.Text := FormatFloat('0.########', Balance) + ' TET';
  except
    on E:ENoInfoForThisAccountError do
      BalanceTETValueLabel.Text := '<ERROR: DATA NOT FOUND>';
    on E:Exception do
      BalanceTETValueLabel.Text := '<UNKNOWN ERROR>';
  end;
end;

procedure TMainForm.RefreshTETHistory;
var
  transArray: TArray<THistoryTransactionInfo>;
  i: Integer;
  newTransFrame: THistoryTransactionFrame;
  amount: Integer;
begin
  amount := 20;
//  transArray := AppCore.GetChainLastUserTransactions(AppCore.UserID,amount);

  NoTETHistoryLabel.Visible := amount = 0;
  HistoryTETHeaderLayout.Visible := not NoTETHistoryLabel.Visible;
  HistoryTETVertScrollBox.Visible := not NoTETHistoryLabel.Visible;
  if NoTETHistoryLabel.Visible then exit;

  CleanScrollBox(HistoryTETVertScrollBox);
  HistoryTETVertScrollBox.BeginUpdate;
  try
    for i := 0 to amount-1 do
    begin
//      newTransFrame := THistoryTransactionFrame.Create(HistoryTETVertScrollBox,
//                                                       transArray[i].DateTime,
//                                                       transArray[i].BlockNum,
//                                                       transArray[i].Address,
//                                                       transArray[i].Hash,
//                                                       FormatFloat('0.00000000',transArray[i].Amount),
//                                                       transArray[i].Incom);
      newTransFrame.OnClick := onTETHistoryFrameClick;
      newTransFrame.Parent := HistoryTETVertScrollBox;
    end;
  finally
    HistoryTETVertScrollBox.EndUpdate;
    AlignTETHeaders;
  end;
end;

procedure TMainForm.RefreshTokenHistory;
var
  transArray: TArray<THistoryTransactionInfo>;
  i: Integer;
  newTransFrame: THistoryTransactionFrame;
  amount: Integer;
  format: String;
  tICO: TTokenICODat;
begin
//  if not AppCore.TryGetTokenICO(TokenNameEdit.Text,tICO) then
//    exit;

  amount := 20;
//  transArray := AppCore.GetSmartLastUserTransactions(AppCore.UserID,TokenNameEdit.Text,amount);

  NoTokenHistoryLabel.Visible := amount = 0;
  HistoryTokenHeaderLayout.Visible := not NoTokenHistoryLabel.Visible;
  HistoryTokenVertScrollBox.Visible := not NoTokenHistoryLabel.Visible;
  if NoTokenHistoryLabel.Visible then exit;

  CleanScrollBox(HistoryTokenVertScrollBox);
  HistoryTokenVertScrollBox.BeginUpdate;
  try
    format := '0.' + string.Create('0', tICO.FloatSize);
    for i := 0 to amount-1 do
    begin
//      newTransFrame := THistoryTransactionFrame.Create(HistoryTokenVertScrollBox,
//                                                       transArray[i].DateTime,
//                                                       transArray[i].BlockNum,
//                                                       transArray[i].Address,
//                                                       transArray[i].Hash,
//                                                       FormatFloat(format,transArray[i].Amount),
//                                                       transArray[i].Incom);
      newTransFrame.OnClick := onTokenHistoryFrameClick;
      newTransFrame.Parent := HistoryTokenVertScrollBox;
    end;
  finally
    HistoryTokenVertScrollBox.EndUpdate;
    AlignTokensHeaders;
  end;
end;

procedure TMainForm.RefreshTokensBalances;
var
  splt: TArray<String>;
  balance: String;
  i: Integer;
begin
//  for balance in AppCore.GetLocalTokensBalances do
//  begin
//    splt := balance.Split([':']);
//    AddOrRefreshBalance(splt[0],splt[1].ToExtended);
//  end;
  TokensListBox.Sort(CustomSortCompare);

  if TokensListBox.Count > 0 then
  begin
    BalanceTokenLabel.Opacity := 1;
    AddressTokenLabel.Opacity := 1;
    TokenNameEdit.Enabled := True;
    RecepientAddressEdit.Enabled := True;
    AmountTokenEdit.Enabled := True;
    ExplorerTabItem.Enabled := True;
    if chosenToken.IsEmpty then
      TokensListBox.ListItems[0].OnClick(TokensListBox.ListItems[0])
    else for i := 0 to TokensListBox.Count-1 do
         if TokensListBox.Items[i] = chosenToken then
         begin
           TokensListBox.ListItems[i].OnClick(TokensListBox.ListItems[i]);
           break;
         end;
  end else
  begin
    BalanceTokenLabel.Opacity := 0;
    BalanceTokenValueLabel.Text := 'No custom tokens yet';
    AddressTokenLabel.Opacity := 0;
  end;
end;

procedure TMainForm.RoundRectMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  i: Integer;
  parent: TTickerFrame;
  child: TTickerFrame;
begin
  if Sender is TTickerFrame then
    parent := Sender as TTickerFrame
  else
    parent := (Sender as TRoundRect).Parent as TTickerFrame;
  if parent.Ticker = chosenTicker then exit;

  parent.RoundRect.Fill.Color := $FF0072D5;
  parent.TickerText.TextSettings.FontColor := $FFFFFFFF;
  parent.Selected := True;
  chosenTicker := parent.Ticker;

  for i := 0 to TopExplorerHorzLayout.ComponentCount - 1 do
    if (TopExplorerHorzLayout.Components[i] is TTickerFrame) and
       ((TopExplorerHorzLayout.Components[i] as TTickerFrame).Ticker <> chosenTicker) and
       (TopExplorerHorzLayout.Components[i] as TTickerFrame).Selected then
      begin
        child := TopExplorerHorzLayout.Components[i] as TTickerFrame;
        child.TickerText.TextSettings.FontColor := $FD000000;
        child.RoundRect.Fill.Color := $FFF3F3F3;
        child.Selected := False;
        break;
      end;

  pageNum := 1;
  RefreshPagesLayout;
end;

procedure TMainForm.AddOrRefreshBalance(AName: String; AValue: Extended);
var
  i: Integer;
begin
  FBalances.AddOrSetValue(AName,AValue);
  if TokensListBox.Items.IndexOf(AName) = -1 then
    AddTokenItem(AName,AValue);

  for i := 0 to TokensListBox.Count-1 do
  begin
    if TokensListBox.ListItems[i].Text = AName then
    begin
      TokensListBox.ListItems[i].ApplyStyleLookup;
      if BalanceTokenValueLabel.Text.Contains(AName) then
        RefreshHeaderBalance(AName);
      break;
    end;
  end;
end;

procedure TMainForm.SearchButtonClick(Sender: TObject);
var
  Hash: string;
begin
  Hash := SearchEdit.Text;
  SearchEdit.Text := '';
  AniIndicator1.Visible := True;
  AniIndicator1.Enabled := True;

  TThread.CreateAnonymousThread(
  procedure
  var
    TransInfo: TExplorerTransactionInfo;
    Ticker: string;
    Success: Boolean;
  begin
//    Success := AppCore.SearchTransactionByHash(Hash, Ticker, TransInfo);
    AniIndicator1.Enabled := False;
    AniIndicator1.Visible := False;
    TThread.Synchronize(nil,
    procedure
    begin
//      onTransactionSearchingDone(Success);
//      if Success then
//        ShowExplorerTransactionDetails(Ticker,
//                                       FormatDateTime('dd.mm.yyyy hh:mm:ss', TransInfo.DateTime),
//                                       TransInfo.BlockNum.ToString,
//                                       TransInfo.Hash,
//                                       TransInfo.TransFrom,
//                                       TransInfo.TransTo,
//                                       TransInfo.Amount.ToString);
    end);
  end).Start;
end;

procedure TMainForm.SearchEditChangeTracking(Sender: TObject);
begin
  SearchButton.Enabled := not SearchEdit.Text.IsEmpty;
end;

procedure TMainForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if SearchButton.Enabled and (Key = 13) then
    SearchButtonClick(Self);
end;

procedure TMainForm.SearchTokenEditChangeTracking(Sender: TObject);
var
  i,invisCount: Integer;
begin
  TokensListBox.BeginUpdate;
  try
    invisCount := 0;
    for i := 0 to TokensListBox.Count-1 do
    begin
      TokensListBox.ListItems[i].Visible :=
        TokensListBox.Items[i].StartsWith(SearchTokenEdit.Text);

      if TokensListBox.ListItems[i].Visible then
        Inc(invisCount);
    end;
    PopupRectangle.Height := SearchTokenEdit.Height +
        40 * (Min(invisCount,3)) + 32;
  finally
    TokensListBox.EndUpdate;
  end;
end;

procedure TMainForm.AmountTETEditChangeTracking(Sender: TObject);
var
  isNumber: Boolean;
  val,balance: Double;
begin
  FBalances.TryGetValue('TET', balance);
  isNumber := TryStrToFloat(AmountTETEdit.Text, val);

  const Decimals = DecimalsCount(AmountTETEdit.Text);

  SendTETButton.Enabled := (Length(SendTETToEdit.Text) >= 10) and
    isNumber and (val > 0) and (val <= balance) and (Decimals <= 8);

  with TransferTETStatusLabel do
  begin
    if isNumber and (val > balance) then
    begin
      Text := 'Insufficient funds';
      TextSettings.FontColor := ERROR_TEXT_COLOR;
      Opacity := 1;
    end
    else if Decimals > 8 then
    begin
      Text := 'Too much digits';
      TextSettings.FontColor := ERROR_TEXT_COLOR;
      Opacity := 1;
    end
     else
      Opacity := 0;
  end;
end;

procedure TMainForm.SendTETButtonClick(Sender: TObject);
var
  response: string;
begin
  try
//    response := AppCore.DoCoinsTransfer('*',AppCore.SessionKey,SendTETToEdit.Text,
//      AmountTETEdit.Text.ToExtended);
    SendTETToEdit.Text := '';
    AmountTETEdit.Text := '';
    ShowTETTransferStatus('Transaction successful');
  except
    on E:EValidError do
      ShowTETTransferStatus(E.Message,True);
    on E:EUnknownError do
    begin
      ShowTETTransferStatus('Unknown error with code ' + E.Message,True);
      Logs.DoLog('Unknown error during TET transfer with code ' + E.Message,ERROR,tcp);
    end;
    on E:Exception do
    begin
      ShowTETTransferStatus('Unknown error',True);
      Logs.DoLog('Unknown error during TET transfer with message: ' + E.Message,ERROR,tcp);
    end;
  end;
end;

procedure TMainForm.SendTokenButtonClick(Sender: TObject);
var
  response: String;
  prKey,pubKey: String;
begin
  try
    AppCore.TryExtractPrivateKeyFromFile(prKey,pubKey);
//    response := AppCore.DoTokenTransfer('*',AppCore.TETAddress,RecepientAddressEdit.Text,
//      AddressTokenLabel.Text, AmountTokenEdit.Text.ToExtended,prKey,pubKey);

    RecepientAddressEdit.Text := '';
    AmountTokenEdit.Text := '';
    ShowTokenTransferStatus('Transaction accepted for processing');
  except
    on E:EValidError do
      ShowTokenTransferStatus(E.Message,True);
    on E:EFileNotExistsError do
    begin
      ShowTokenTransferStatus('Unable to send transaction: keys not found',True);
      InputPrKeyButton.Visible := True;
    end;
    on E:ESameAddressesError do
      ShowTokenTransferStatus('Unable to send to yourself',True);
    on E:EInsufficientFundsError do
      ShowTokenTransferStatus('Transfer failed: insufficient funds',True);
    on E:EInvalidSignError do
      ShowTokenTransferStatus('Transfer failed: validator did not confirm the signature',True);
    on E:ESocketError do
    begin
      ShowTokenTransferStatus('Remote server did not respond, try later',True);
      Logs.DoLog('Token transfer error: remote server did not respond',ERROR,tcp);
    end;
    on E:EValidatorDidNotAnswerError do
    begin
      ShowTokenTransferStatus('Validator did not answer, try later',True);
      Logs.DoLog('Token transfer error: validator did not answer',ERROR,tcp);
    end;
    on E:EUnknownError do
    begin
      ShowTokenTransferStatus('Unknown error with code ' + E.Message,True);
      Logs.DoLog('Unknown error during token transfer with code ' + E.Message,ERROR,tcp);
    end;
    on E:Exception do
    begin
      ShowTokenTransferStatus('Unknown error',True);
      Logs.DoLog('Unknown error during token transfer with message: ' + E.Message,ERROR,tcp);
    end;
  end;
end;

procedure TMainForm.ShowExplorerTransactionDetails(ATicker, ADateTime, ABlockNum,
  AHash, ATransFrom, ATransTo, AAmount: string);
var
  tICO: TTokenICODat;
begin
  if ATicker = 'Tectum' then
    ATicker := 'TET';
//  if not AppCore.TryGetTokenICO(ATicker, tICO) then
//    exit;

  DateTimeDetailsText.AutoSize := False;
  DateTimeDetailsText.Text := ADateTime;
  DateTimeDetailsText.AutoSize := True;

  BlockDetailsText.AutoSize := False;
  BlockDetailsText.Text := ABlockNum;
  BlockDetailsText.AutoSize := True;

  FromDetailsText.AutoSize := False;
  FromDetailsText.Text := ATransFrom;
  FromDetailsText.AutoSize := True;

  ToDetailsText.AutoSize := False;
  ToDetailsText.Text := ATransTo;
  ToDetailsText.AutoSize := True;

  HashDetailsText.AutoSize := False;
  HashDetailsText.Text := AHash;
  HashDetailsText.AutoSize := True;

  AmountDetailsText.AutoSize := False;
  AmountDetailsText.Text := AAmount;
  AmountDetailsText.AutoSize := True;

  TokenDetailsText.AutoSize := False;
  TokenDetailsText.Text := Format('%s (%s)',[tICO.Abreviature, tICO.ShortName]);
  TokenDetailsText.AutoSize := True;

  TokenInfoDetailsLabelValue.AutoSize := False;
  TokenInfoDetailsLabelValue.Text := tICO.FullName;
  TokenInfoDetailsLabelValue.AutoSize := True;

  TransactionDetailsRectangle.Height := TokenInfoDetailsLabelValue.Height + 424;
  if ExplorerTabControl.Index = 0 then
    ExplorerTabControl.Next;
end;

procedure TMainForm.ShowTETTransferStatus(const AMessage: String;
  AIsError: Boolean);
begin
  TransferTETStatusLabel.Text := AMessage;
  if AIsError then
    TransferTETStatusLabel.TextSettings.FontColor := ERROR_TEXT_COLOR
  else
    TransferTETStatusLabel.TextSettings.FontColor := SUCCESS_TEXT_COLOR;

  FloatAnimation2.Start;
end;

procedure TMainForm.ShowTokenCreatingStatus(const AMessage: String;
  AIsError: Boolean);
begin
  TokenCreatingStatusLabel.Text := AMessage;
  if AIsError then
    TokenCreatingStatusLabel.TextSettings.FontColor := ERROR_TEXT_COLOR
  else
    TokenCreatingStatusLabel.TextSettings.FontColor := SUCCESS_TEXT_COLOR;

  FloatAnimation3.Start;
end;

procedure TMainForm.ShowTokenTransferStatus(const AMessage: String; AIsError: Boolean);
begin
  TransferTokenStatusLabel.Text := AMessage;
  if AIsError then
    TransferTokenStatusLabel.TextSettings.FontColor := ERROR_TEXT_COLOR
  else
    TransferTokenStatusLabel.TextSettings.FontColor := SUCCESS_TEXT_COLOR;

  FloatAnimation1.Start;
end;

end.
