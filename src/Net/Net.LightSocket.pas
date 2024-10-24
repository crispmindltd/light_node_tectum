unit Net.LightSocket;

interface

uses
  App.Logs,
  Net.Data,
  Net.Socket,
  SysUtils;

type
  TLightSocket = class(TSocket)
    const
      ReceiveResponseTimeout = 10000;
    private
      FAddress: string;
      FPort: Word;

      function GetFullAddress: string;
    public
      constructor Create;
      destructor Destroy; override;

      function Connect(AAddress: string; APort: Word): Boolean;
      function DoRequest(ACommandCode: Byte; ARequest: string): string;
      procedure Disconnect;

      property AddrPort: string read GetFullAddress;
  end;

implementation

{ TLightSocket }

function TLightSocket.Connect(AAddress: string; APort: Word): Boolean;
begin
  try
    inherited Connect('', AAddress, '', APort);

    FAddress := AAddress;
    FPort := APort;
    Result := True;
  except
    Result := False;
  end;
end;

constructor TLightSocket.Create;
begin
  inherited Create(TSocketType.TCP, TEncoding.ANSI);

  ReceiveTimeout := ReceiveResponseTimeout;
end;

destructor TLightSocket.Destroy;
begin
  Disconnect;

  inherited;
end;

procedure TLightSocket.Disconnect;
begin
  if TSocketState.Connected in State then
  {$IFDEF MSWINDOWS}
    Close(True);
  {$ELSE IFDEF LINUX}
    Close;
  {$ENDIF}
end;

function TLightSocket.DoRequest(ACommandCode: Byte; ARequest: string): string;
var
  ToSend: TBytes;
  InfoBytes: array[0..4] of Byte;
  AmountBytes: array[0..3] of Byte;
  Amount: Integer absolute AmountBytes;
  Response: TBytes;
begin
  InfoBytes[0] := ACommandCode;
  ToSend := TEncoding.ANSI.GetBytes(ARequest);
  Amount := Length(ToSend);
  Move(AmountBytes[0], InfoBytes[1], 4);
  Send(InfoBytes, 0, 5);
  Send(ToSend, 0, Length(ToSend));
  Logs.DoLog(Format('<To %s>[%d]: %s', [GetFullAddress, ValidateCommandCode,
    ARequest]), OUTGO, tcp);

  Receive(AmountBytes, 0, 4, [TSocketFlag.WAITALL]);
  SetLength(Response, Amount);
  Receive(Response, 0, Amount, [TSocketFlag.WAITALL]);
  Send([DisconnectingCode], 0, 1);
  Disconnect;

  Result := TEncoding.ANSI.GetString(Response);
  Logs.DoLog(Format('<From %s>[%d]: %s', [GetFullAddress, ValidateCommandCode,
    Result]), INCOM, tcp);
end;

function TLightSocket.GetFullAddress: string;
begin
  Result := Format('%s:%d', [FAddress, FPort]);
end;

end.
