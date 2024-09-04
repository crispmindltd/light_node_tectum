unit Frame.History;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects;

type
  THistoryTransactionFrame = class(TFrame)
    Rectangle: TRectangle;
    DateTimeLabel: TLabel;
    BlockLabel: TLabel;
    AddressLabel: TLabel;
    HashLabel: TLabel;
    AmountLabel: TLabel;
    IncomRectangle: TRectangle;
    IncomText: TText;
    procedure FrameMouseLeave(Sender: TObject);
    procedure FrameMouseEnter(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; ADateTime: TDateTime; ABlock: Int64;
      AAddress, AHash: String; AAmount: String; AIncom: Boolean);
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

{ TFrame1 }

constructor THistoryTransactionFrame.Create(AOwner: TComponent; ADateTime: TDateTime;
  ABlock: Int64; AAddress, AHash: String; AAmount: String; AIncom: Boolean);
begin
  inherited Create(AOwner);

  DateTimeLabel.Text := FormatDateTime('dd.mm.yyyy hh:mm:ss',ADateTime);
  BlockLabel.Text := ABlock.ToString;
  AddressLabel.Text := AAddress;
  HashLabel.Text := AHash;
  AmountLabel.Text := AAmount;
  Name := AOwner.Name + AOwner.ComponentCount.ToString;
  if not AIncom then
  begin
    IncomRectangle.Fill.Color := $FFE85D42;
    IncomText.Text := 'OUT';
  end;
  IncomText.AutoSize := True;
end;

destructor THistoryTransactionFrame.Destroy;
begin

  inherited;
end;

procedure THistoryTransactionFrame.FrameMouseEnter(Sender: TObject);
begin
  Rectangle.Fill.Kind := TBrushKind.Solid;
end;

procedure THistoryTransactionFrame.FrameMouseLeave(Sender: TObject);
begin
  Rectangle.Fill.Kind := TBrushKind.None;
end;

procedure THistoryTransactionFrame.FrameResize(Sender: TObject);
var
  w: Integer;
begin
  w := Round(Self.Width - DateTimeLabel.Width - BlockLabel.Width -
    AmountLabel.Width - IncomRectangle.Width - 85) div 2;
  AddressLabel.Width := w;
  HashLabel.Width := w;
end;

end.
