unit ExplorerUnit;

interface

uses
  Blockchain.BaseTypes,
  Blockchain.Intf,
  System.Classes,
  System.DateUtils,
  System.IOUtils,
  System.SysUtils,
  System.UITypes, System.Rtti, FMX.Grid.Style, FMX.Types, FMX.StdCtrls,
  FMX.Grid, FMX.ScrollBox, FMX.Layouts, FMX.Controls, FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Platform,
  FMX.Edit,
  FMX.Forms,
  App.Intf,
  Net.Client,
  Net.Data,
  Types,
  FMX.TabControl, FMX.ListBox, FMX.Menus;

type
  TExplorerForm = class(TForm)
    MainPanel: TPanel;
    DataGrid: TStringGrid;
    HashColumn: TStringColumn;
    StatusColumn: TIntegerColumn;
    SmrtIDColumn: TIntegerColumn;
    SmrtDateColumn: TDateTimeColumn;
    SmrtStatusColumn: TStringColumn;
    SettingsLayout: TLayout;
    Timer: TTimer;
    Splitter: TSplitter;
    SettingsGroupBox: TGroupBox;
    CurrencyIDComboBox: TComboBox;
    CurrencyIDLabel: TLabel;
    CurrencyIDLayout: TLayout;
    AmountLayout: TLayout;
    AmountLabel: TLabel;
    AmountEdit: TEdit;
    AutoCheckBox: TCheckBox;
    RefreshGridButton: TButton;
    BlockNumColumn: TIntegerColumn;
    FirstModeRadioButton: TRadioButton;
    SecondModeRadioButton: TRadioButton;
    ModeGroupBox: TGroupBox;
    BlockFromLayout: TLayout;
    BlockFromLabel: TLabel;
    BlockFromEdit: TEdit;
    SmrtDeltaColumn: TIntegerColumn;
    PopupMenu: TPopupMenu;
    CopyMenuItem: TMenuItem;
    Fee1Column: TFloatColumn;
    Fee2Column: TFloatColumn;
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DataGridResize(Sender: TObject);
    procedure AutoCheckBoxChange(Sender: TObject);
    procedure RefreshGridButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CurrencyIDComboBoxChange(Sender: TObject);
    procedure RadioButtonChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CopyMenuItemClick(Sender: TObject);
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    SMChosen: Boolean;

    procedure ClearGrid;
    procedure RefreshDataGrid(const AData: TBytesBlocks; AAmount: Integer);
  public
  end;

var
  ExplorerForm: TExplorerForm;

implementation

{$R *.fmx}

procedure TExplorerForm.AutoCheckBoxChange(Sender: TObject);
begin
  Timer.Enabled := AutoCheckBox.IsChecked;
end;

procedure TExplorerForm.ClearGrid;
var
  i,j: Integer;
begin
  DataGrid.BeginUpdate;
  try
    for i := 0 to DataGrid.ColumnCount - 1 do
      for j := 0 to DataGrid.RowCount - 1 do
        DataGrid.Cells[i,j] := '';
  finally
    DataGrid.EndUpdate;
  end;
end;

procedure TExplorerForm.CopyMenuItemClick(Sender: TObject);
var
  Service: IFMXClipBoardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipBoardService, Service) then
    Service.SetClipboard(DataGrid.Cells[DataGrid.Col,DataGrid.Row]);
end;

procedure TExplorerForm.OnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  c,r: Integer;
  coords: TPointF;
begin
  if (Button = TMouseButton.mbRight) and DataGrid.CellByPoint(X,Y,c,r) then
  begin
    DataGrid.SelectCell(c,r);
    coords := DataGrid.LocalToScreen(TPointF.Create(X, Y));
    PopupMenu.Popup(coords.X,coords.Y);
  end;
end;

procedure TExplorerForm.CurrencyIDComboBoxChange(Sender: TObject);
begin
  SMChosen := AppCore.IsSmartExists(CurrencyIDComboBox.Items[CurrencyIDComboBox.ItemIndex]);
  Fee1Column.Visible := SMChosen;
  Fee2Column.Visible := SMChosen;
  DataGridResize(Self);
  ClearGrid;
end;

procedure TExplorerForm.DataGridResize(Sender: TObject);
begin
  DataGrid.BeginUpdate;
  try
    if SMChosen then
      HashColumn.Width := DataGrid.Width - BlockNumColumn.Width - StatusColumn.Width -
        Fee1Column.Width - Fee2Column.Width - SmrtIDColumn.Width -
        SmrtStatusColumn.Width - SmrtDeltaColumn.Width - SmrtDateColumn.Width - 10
    else
      HashColumn.Width := DataGrid.Width - BlockNumColumn.Width - StatusColumn.Width -
        SmrtIDColumn.Width - SmrtStatusColumn.Width - SmrtDeltaColumn.Width -
        SmrtDateColumn.Width - 10
  finally
    DataGrid.EndUpdate;
  end;
end;

procedure TExplorerForm.RadioButtonChange(Sender: TObject);
begin
  if FirstModeRadioButton.IsChecked then
  begin
    BlockFromLayout.Visible := False;
    AutoCheckBox.Visible := True;
    AutoCheckBox.IsChecked := True;
    SettingsGroupBox.Height := CurrencyIDLayout.Height + AmountLayout.Height + RefreshGridButton.Height +
      AutoCheckBox.Height + 71;
    RefreshGridButton.Text := 'Refresh';
  end else
  begin
    BlockFromLayout.Visible := True;
    AutoCheckBox.Visible := False;
    AutoCheckBox.IsChecked := False;
    SettingsGroupBox.Height := CurrencyIDLayout.Height + AmountLayout.Height + RefreshGridButton.Height +
      BlockFromLayout.Height + 69;
    RefreshGridButton.Text := 'Get blocks';
  end;
  ClearGrid;
end;

procedure TExplorerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer.Enabled := False;
  Action := TCloseAction.caFree;
  UI.NullForm(ExplorerForm);
end;

procedure TExplorerForm.FormCreate(Sender: TObject);
var
  chainName: String;
begin
  for chainName in AppCore.GetChainsNames do
    CurrencyIDComboBox.Items.Add(chainName);
  for chainName in AppCore.GetSmartsNames do
    CurrencyIDComboBox.Items.Add(chainName);
//    CurrencyIDComboBox.Items.Add(AppCore.SmartIdNameToTicker(chainName));

  CurrencyIDComboBox.ItemIndex := 0;
  SMChosen := False;
  DataGrid.OnMouseDown := OnMouseDown;
end;

procedure TExplorerForm.FormShow(Sender: TObject);
begin
  RadioButtonChange(nil);
  DataGrid.SetFocus;
end;

procedure TExplorerForm.RefreshDataGrid(const AData: TBytesBlocks; AAmount: Integer);
var
  i,totalCount: Integer;
  chName,str: String;
  blockBytes: TOneBlockBytes;
  tchBlock: Tbc2 absolute blockBytes;
  TCbc4Block: TCbc4 absolute blockBytes;
begin
  ClearGrid;
  chName := CurrencyIDComboBox.Items[CurrencyIDComboBox.ItemIndex];

  DataGrid.BeginUpdate;
  DataGrid.RowCount := AAmount;
  try
    for i := 0 to AAmount-1 do
    begin
      if not SMChosen then
      begin
        totalCount := AppCore.GetBlocksCountLocal(chName);
        Move(AData[i*AppCore.GetBlockSize(chName)],blockBytes[0],AppCore.GetBlockSize(chName));
        SetLength(str,sizeof(tchBlock.Hash) * 2);
        BinToHex(tchBlock.Hash,pchar(str),SizeOf(tchBlock.Hash));
        DataGrid.Cells[2,i] := tchBlock.Status.ToString;
        DataGrid.Cells[3,i] := tchBlock.Smart.ID.ToString;
        DataGrid.Cells[4,i] := tchBlock.Smart.Status.ToString;
        DataGrid.Cells[5,i] := tchBlock.Smart.Delta.ToString;
        DataGrid.Cells[6,i] := DateTimeToStr(tchBlock.Smart.TimeEvent);
      end else
      begin
        totalCount := AppCore.GetSmartBlocksCountLocal(chName);
        Move(AData[i*AppCore.GetSmartBlockSize(chName)],blockBytes[0],AppCore.GetSmartBlockSize(chName));
        SetLength(str,sizeof(TCbc4Block.Hash) * 2);
        BinToHex(TCbc4Block.Hash,pchar(str),SizeOf(TCbc4Block.Hash));
        DataGrid.Cells[2,i] := TCbc4Block.Status.ToString;
        DataGrid.Cells[3,i] := TCbc4Block.Smart.fee1.ToString;
        DataGrid.Cells[4,i] := TCbc4Block.Smart.fee2.ToString;
        DataGrid.Cells[5,i] := TCbc4Block.Smart.ID.ToString; //AppCore.GetSmartTickerByID(TCbc4Block.Smart.ID);
        DataGrid.Cells[6,i] := TCbc4Block.Smart.Status.ToString;
        DataGrid.Cells[7,i] := TCbc4Block.Smart.Delta.ToString;
        DataGrid.Cells[8,i] := DateTimeToStr(TCbc4Block.Smart.TimeEvent);
      end;

      if FirstModeRadioButton.IsChecked then
        DataGrid.Cells[0,i] := (totalCount-AAmount+i).ToString
      else
        DataGrid.Cells[0,i] := (BlockFromEdit.Text.ToInteger+i).ToString;
      DataGrid.Cells[1,i] := str.ToLower;
    end;
  finally
    DataGrid.EndUpdate;
  end;
end;

procedure TExplorerForm.RefreshGridButtonClick(Sender: TObject);
begin
  AutoCheckBox.IsChecked := False;
  TimerTimer(Self);
end;

procedure TExplorerForm.TimerTimer(Sender: TObject);
var
  bBlocks: TBytesBlocks;
  chName: String;
  amount: Integer;
begin
  amount := AmountEdit.Text.ToInteger;
  chName := CurrencyIDComboBox.Items[CurrencyIDComboBox.ItemIndex];
  if FirstModeRadioButton.IsChecked then
  begin
    if AppCore.IsChainExists(chName) then
      bBlocks := AppCore.GetBlocks(chName,amount)
    else
      bBlocks := AppCore.GetSmartBlocks(chName,amount);
//      bBlocks := AppCore.GetSmartBlocks(AppCore.SmartTickerToIDName(chName),amount);
  end else
  begin
    if AppCore.IsChainExists(chName) then
      bBlocks := AppCore.GetBlocks(chName,BlockFromEdit.Text.ToInt64,amount)
    else
      bBlocks := AppCore.GetSmartBlocks(chName,BlockFromEdit.Text.ToInt64,amount);
//      bBlocks := AppCore.GetSmartBlocks(AppCore.SmartTickerToIDName(chName),BlockFromEdit.Text.ToInt64,amount);
  end;

  RefreshDataGrid(bBlocks,amount);
end;

end.
