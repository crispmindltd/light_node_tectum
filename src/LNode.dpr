﻿program LNode;

uses
  System.StartUpCopy,
  SysUtils,
  Classes,
  IOUtils,
  FMX.Dialogs,
  FMX.Forms,
  FMX.Types,
  Types,
  App.Intf in 'Core\App.Intf.pas',
  App.Core in 'Core\App.Core.pas',
  Net.Client in 'Net\Net.Client.pas',
  App.Mutex in 'Core\App.Mutex.pas',
  Net.ConnectedClient in 'Net\Net.ConnectedClient.pas',
  App.Logs in 'Core\App.Logs.pas',
  server.HTTP in 'Web\server\server.HTTP.pas',
  endpoints.Node in 'Web\endpoints\endpoints.Node.pas',
  Desktop in 'UI\Desktop.pas',
  Net.CustomSocket in 'Net\Net.CustomSocket.pas',
  Net.Server in 'Net\Net.Server.pas',
  App.Settings in 'Core\App.Settings.pas',
  Crypto in 'Crypto\Crypto.pas',
  server.Types in 'Web\server\server.Types.pas',
  endpoints.Base in 'Web\endpoints\endpoints.Base.pas',
  Blockchain.Main in 'Blockchain\Blockchain.Main.pas',
  Blockchain.Intf in 'Blockchain\Blockchain.Intf.pas',
  Blockchain.TET in 'Blockchain\Blockchain.TET.pas',
  Blockchain.BaseTypes in 'Blockchain\Blockchain.BaseTypes.pas',
  Net.Data in 'Net\Net.Data.pas',
  Net.LightSocket in 'Net\Net.LightSocket.pas',
  endpoints.Account in 'Web\endpoints\endpoints.Account.pas',
  App.Exceptions in 'Core\App.Exceptions.pas',
  endpoints.Token in 'Web\endpoints\endpoints.Token.pas',
  Sync.Base in 'Sync\Sync.Base.pas',
  Form.Main in 'UI\Forms\Form.Main.pas' {MainForm},
  Form.Start in 'UI\Forms\Form.Start.pas' {StartForm},
  Styles in 'UI\Forms\Styles.pas' {StylesForm},
  WordsPool in 'Crypto\SeedPhrase\WordsPool.pas',
  Blockchain.TETDynamic in 'Blockchain\Blockchain.TETDynamic.pas',
  Blockchain.ICODat in 'Blockchain\Blockchain.ICODat.pas',
  Frame.Ticker in 'UI\Forms\Frame.Ticker.pas' {TickerFrame: TFrame},
  Frame.Explorer in 'UI\Forms\Frame.Explorer.pas' {ExplorerTransactionFrame: TFrame},
  Frame.History in 'UI\Forms\Frame.History.pas' {HistoryTransactionFrame: TFrame},
  Form.EnterKey in 'UI\Forms\Form.EnterKey.pas' {EnterPrivateKeyForm},
  App.Constants in 'Core\App.Constants.pas',
  OpenURL in 'UI\OpenURL.pas',
  Sync.TETChain in 'Sync\Sync.TETChain.pas',
  Frame.PageNum in 'UI\Forms\Frame.PageNum.pas' {PageNumFrame: TFrame},
  Blockchain.SmartKey in 'Blockchain\Blockchain.SmartKey.pas',
  Sync.TokensChains in 'Sync\Sync.TokensChains.pas',
  Blockchain.Token in 'Blockchain\Blockchain.Token.pas',
  Blockchain.TokenDynamic in 'Blockchain\Blockchain.TokenDynamic.pas';

{$R *.res}

var
  LPidFileName: string;
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:=True;
  {$ENDIF}

  LPidFileName := 'LNode';
  try
    with TMutex.Create(LPidFileName) do
    try
      UI := TUICore.Create;
      try
        AppCore := TAppCore.Create;
        AppCore.Run;
        UI.Run;
      except
        on Exception do exit;
      end;
    finally
      AppCore.Stop;
      Free;
    end;
  except
    on E:EFOpenError do
      ShowMessage('LNode is already started');
  end;
end.
