unit Frame.Ticker;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TTickerFrame = class(TFrame)
    RoundRect: TRoundRect;
    TickerText: TText;
    procedure RoundRectMouseEnter(Sender: TObject);
    procedure RoundRectMouseLeave(Sender: TObject);
  private
    FIsSelected: Boolean;
    function GetTicker: String;
  public
    constructor Create(AOwner: TComponent; AName: String);
    destructor Destroy; override;

    property Selected: Boolean read FIsSelected write FIsSelected;
    property Ticker: String read GetTicker;
  end;

implementation

{$R *.fmx}

{ TTickerFrame }

constructor TTickerFrame.Create(AOwner: TComponent; AName: String);
begin
  inherited Create(AOwner);

  TickerText.Text := AName;
  TickerText.AutoSize := True;
  Self.Width := TickerText.Width + 20;
  Name := 'TickerItem' + AName.Replace(' ','');

  if (AName = 'Search result') or (AName = 'Tectum') then
    Align := TAlignLayout.MostLeft;

  FIsSelected := False;
end;

destructor TTickerFrame.Destroy;
begin

  inherited;
end;

function TTickerFrame.GetTicker: String;
begin
  Result := TickerText.Text;
end;

procedure TTickerFrame.RoundRectMouseEnter(Sender: TObject);
begin
  TickerText.TextSettings.FontColor := $FFFFFFFF;
  if not FIsSelected then
    RoundRect.Fill.Color := $FF489FE5;
end;

procedure TTickerFrame.RoundRectMouseLeave(Sender: TObject);
begin
  if not FIsSelected then
  begin
    TickerText.TextSettings.FontColor := $FD000000;
    RoundRect.Fill.Color := $FFF3F3F3;
  end;
end;

end.
