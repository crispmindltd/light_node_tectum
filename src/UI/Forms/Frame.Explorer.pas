unit Frame.Explorer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects;

type
  TExplorerTransactionFrame = class(TFrame)
    DateTimeLabel: TLabel;
    BlockLabel: TLabel;
    FromLabel: TLabel;
    ToLabel: TLabel;
    HashLabel: TLabel;
    AmountLabel: TLabel;
    Rectangle: TRectangle;
    procedure FrameResize(Sender: TObject);
    procedure FrameMouseEnter(Sender: TObject);
    procedure FrameMouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; ADateTime: TDateTime; ABlock: Int64;
      AFrom, ATo, AHash: String; AAmount: String);
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

{ TFrame1 }

constructor TExplorerTransactionFrame.Create(AOwner: TComponent; ADateTime: TDateTime;
  ABlock: Int64; AFrom, ATo, AHash: String; AAmount: String);
begin
  inherited Create(AOwner);

  DateTimeLabel.Text := FormatDateTime('dd.mm.yyyy hh:mm:ss',ADateTime);
  BlockLabel.Text := ABlock.ToString;
  FromLabel.Text := AFrom;
  ToLabel.Text := ATo;
  HashLabel.Text := AHash;
  AmountLabel.Text := AAmount;
  Name := AOwner.Name + AOwner.ComponentCount.ToString;
end;

destructor TExplorerTransactionFrame.Destroy;
begin

  inherited;
end;

procedure TExplorerTransactionFrame.FrameMouseEnter(Sender: TObject);
begin
  Rectangle.Fill.Kind := TBrushKind.Solid;
end;

procedure TExplorerTransactionFrame.FrameMouseLeave(Sender: TObject);
begin
  Rectangle.Fill.Kind := TBrushKind.None;
end;

procedure TExplorerTransactionFrame.FrameResize(Sender: TObject);
var
  w: Integer;
begin
  w := Round(Self.Width - DateTimeLabel.Width - BlockLabel.Width -
    AmountLabel.Width - 75) div 3;
  FromLabel.Width := w;
  ToLabel.Width := w;
  HashLabel.Width := w;
end;

end.
