unit Blockchain.DataGetter;

interface

uses
  App.Intf,
  Blockchain.BaseTypes,
  Classes,
  SysUtils;

type
  TUserTokensBalancesGetter = class(TThread)
    private
      FMaxAmount: Integer;
      FResult: TArray<String>;
    protected
      procedure Execute; override;
    public
      constructor Create(ACallBack: TNotifyEvent);
      destructor Destroy; override;

      property Balances: TArray<String> read FResult;
  end;

  TTokensHistoryItem = record
    Date: TDateTime;
    TransFrom: String;
    TransTo: String;
    TransHash: String;
    Amount: Extended;
  end;

  TUserTokensHistoryGetter = class(TThread)
    private
      FMaxAmount: Integer;
      FResult: TArray<TTokensHistoryItem>;
    protected
      procedure Execute; override;
    public
      constructor Create(AMaxAmount: Integer = 10);
      destructor Destroy; override;
  end;

implementation

{ TUserHistoryGetter }

constructor TUserTokensHistoryGetter.Create(AMaxAmount: Integer);
begin
  inherited Create;

  FMaxAmount := AMaxAmount;
  FreeOnTerminate := True;
  FResult := [];
end;

destructor TUserTokensHistoryGetter.Destroy;
begin

  inherited;
end;

procedure TUserTokensHistoryGetter.Execute;
var
  i: Integer;
begin
  inherited;


end;

{ TUserTokensBalancesGetter }

constructor TUserTokensBalancesGetter.Create(ACallBack: TNotifyEvent);
begin
  inherited Create;

  FreeOnTerminate := True;
  onTerminate := ACallBack;
  FResult := [];
end;

destructor TUserTokensBalancesGetter.Destroy;
begin

  inherited;
end;

procedure TUserTokensBalancesGetter.Execute;
var
  sKey: TCSmartKey;
  balance,val: String;
  i: Integer;
begin
  inherited;

  for i := 0 to AppCore.GetSmartBlocksCount(-1)-1 do
  begin
    if Terminated then exit;

    sKey := AppCore.GetOneSmartKeyBlock(i);
    val := AppCore.DoGetTokenBalanceWithTicker('*',AppCore.TETAddress,Trim(skey.Abreviature));
    balance := Format('%s:%s',[Trim(sKey.Abreviature),val.Split([' '])[2]]);
    FResult := FResult + [balance];
  end;
end;

end.
