unit Styles;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.ListBox, FMX.Layouts, FMX.Graphics,
  FMX.Dialogs, FMX.Objects;

const
  MOUSE_ENTER_COLOR = $FF323232;
  MOUSE_LEAVE_COLOR = $FF5A6773;
  MOUSE_DOWN_COLOR = $FF4285F4;
  SUCCESS_TEXT_COLOR = $FF2E9806;
  ERROR_TEXT_COLOR = $FFFC4949;

type
  TStylesForm = class(TForm)
    LNodeStyleBook: TStyleBook;
  private
    { Private declarations }
  public
    procedure OnCopyLayoutMouseEnter(Sender: TObject);
    procedure OnCopyLayoutMouseLeave(Sender: TObject);
    procedure OnCopyLayoutMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure OnCopyLayoutMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);

    procedure OnTokenItemMouseEnter(Sender: TObject);
    procedure OnTokenItemMouseLeave(Sender: TObject);
    procedure OnTokenItemMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure OnTokenItemMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  end;

var
  StylesForm: TStylesForm;

implementation

{$R *.fmx}

{ TStylesForm }

procedure TStylesForm.OnCopyLayoutMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  layout: TLayout;
  svg: TPath;
  c: TComponent;
  i: Integer;
begin
  if not(Sender is TLayout) then exit;

  layout := Sender as TLayout;
  svg := nil;
  for i := 0 to layout.ChildrenCount-1 do
    if layout.Children[i] is TPath then
    begin
      svg := layout.Children[i] as TPath;
      break;
    end;
  if Assigned(svg) then
  begin
    svg.Fill.Color := MOUSE_DOWN_COLOR;
    svg.Stroke.Color := MOUSE_DOWN_COLOR;
  end;
end;

procedure TStylesForm.OnCopyLayoutMouseEnter(Sender: TObject);
var
  layout: TLayout;
  svg: TPath;
  c: TComponent;
  i: Integer;
begin
  if not(Sender is TLayout) then exit;

  layout := Sender as TLayout;
  svg := nil;
  for i := 0 to layout.ChildrenCount-1 do
    if layout.Children[i] is TPath then
    begin
      svg := layout.Children[i] as TPath;
      break;
    end;
  if Assigned(svg) then
  begin
    svg.Fill.Color := MOUSE_ENTER_COLOR;
    svg.Stroke.Color := MOUSE_ENTER_COLOR;
  end;
end;

procedure TStylesForm.OnCopyLayoutMouseLeave(Sender: TObject);
var
  layout: TLayout;
  svg: TPath;
  c: TComponent;
  i: Integer;
begin
  if not(Sender is TLayout) then exit;

  layout := Sender as TLayout;
  svg := nil;
  for i := 0 to layout.ChildrenCount-1 do
    if layout.Children[i] is TPath then
    begin
      svg := layout.Children[i] as TPath;
      break;
    end;
  if Assigned(svg) then
  begin
    svg.Fill.Color := MOUSE_LEAVE_COLOR;
    svg.Stroke.Color := MOUSE_LEAVE_COLOR;
  end;
end;

procedure TStylesForm.OnCopyLayoutMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  OnCopyLayoutMouseEnter(Sender);
end;

procedure TStylesForm.OnTokenItemMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  obj: TRectangle;
begin
  if not (Sender is TListBoxItem) then exit;
  obj := nil;
  obj := (Sender as TListBoxItem).FindStyleResource('RectangleStyle') as TRectangle;
  if Assigned(obj) then
    obj.Fill.Color := $994285F4;
end;

procedure TStylesForm.OnTokenItemMouseEnter(Sender: TObject);
var
  obj: TRectangle;
begin
  if not (Sender is TListBoxItem) then exit;
  obj := nil;
  obj := (Sender as TListBoxItem).FindStyleResource('RectangleStyle') as TRectangle;
  if Assigned(obj) then
    obj.Fill.Color := $99E0E0E0;
end;

procedure TStylesForm.OnTokenItemMouseLeave(Sender: TObject);
var
  obj: TRectangle;
begin
  if not (Sender is TListBoxItem) then exit;
  obj := nil;
  obj := (Sender as TListBoxItem).FindStyleResource('RectangleStyle') as TRectangle;
  if Assigned(obj) then
    obj.Fill.Color := $FFFFFFFF;
end;

procedure TStylesForm.OnTokenItemMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  OnTokenItemMouseEnter(Sender);
end;

end.
