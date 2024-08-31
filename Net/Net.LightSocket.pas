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
      RECEIVE_ANSWER_TIMEOUT = 10000;
    private
      FAddress: String;
      FPort: Word;

      function GetFullAddress: String;
    public
      constructor Create;
      destructor Destroy; override;

      function Connect(AAddress: String; APort: Word): Boolean;
      function DoRequest(ACommandCode: Byte; ARequest: String): String;
      procedure Disconnect;

      property AddrPort: String read GetFullAddress;
  end;

implementation

{ TLightSocket }

function TLightSocket.Connect(AAddress: String; APort: Word): Boolean;
begin
  try
    inherited Connect('',AAddress,'',APort);

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

  ReceiveTimeout := RECEIVE_ANSWER_TIMEOUT;
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

function TLightSocket.DoRequest(ACommandCode: Byte; ARequest: String): String;
var
  bytesToSend: TBytes;
  infoBytes: array[0..4] of Byte;
  amountBytes: array[0..3] of Byte;
  bAmount: Integer absolute amountBytes;
  answer: TBytes;
begin
  infoBytes[0] := ACommandCode;
  bytesToSend := TEncoding.ANSI.GetBytes(ARequest);
  bAmount := Length(bytesToSend);
  Move(amountBytes[0],infoBytes[1],4);
  Send(infoBytes,0,5);
  Send(bytesToSend,0,Length(bytesToSend));
  Logs.DoLog(Format('<To %s>[%d]: %s',[GetFullAddress,VALIDATE_COMMAND_CODE,
    ARequest]),OUTGO,tcp);

  Receive(amountBytes,0,4,[TSocketFlag.WAITALL]);
  SetLength(answer,bAmount);
  Receive(answer,0,bAmount,[TSocketFlag.WAITALL]);
  Send([DISCONNECTING_CODE],0,1);
  Disconnect;

  Result := TEncoding.ANSI.GetString(answer);
  Logs.DoLog(Format('<From %s>[%d]: %s',[GetFullAddress,VALIDATE_COMMAND_CODE,
    Result]),INCOM,tcp);
end;

function TLightSocket.GetFullAddress: String;
begin
  Result := Format('%s:%d',[FAddress,FPort]);
end;

end.
