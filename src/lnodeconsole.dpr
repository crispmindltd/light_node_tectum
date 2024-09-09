program lnodeconsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  App.Mutex in 'Core\App.Mutex.pas',
  App.Intf in 'Core\App.Intf.pas',
  App.Core in 'Core\App.Core.pas',
  Console in 'UI\Console.pas',
  Blockchain.Intf in 'Blockchain\Blockchain.Intf.pas',
  Blockchain.BaseTypes in 'Blockchain\Blockchain.BaseTypes.pas',
  App.Logs in 'Core\App.Logs.pas',
  App.Exceptions in 'Core\App.Exceptions.pas',
  App.Settings in 'Core\App.Settings.pas',
  Net.Data in 'Net\Net.Data.pas',
  Blockchain.Main in 'Blockchain\Blockchain.Main.pas',
  Blockchain.Token.chn in 'Blockchain\Blockchain.Token.chn.pas',
  Blockchain.TokenDynamic in 'Blockchain\Blockchain.TokenDynamic.pas',
  Blockchain.TETDynamic in 'Blockchain\Blockchain.TETDynamic.pas',
  Blockchain.SmartKey in 'Blockchain\Blockchain.SmartKey.pas',
  Blockchain.Smartcontracts in 'Blockchain\Blockchain.Smartcontracts.pas',
  Blockchain.ICODat in 'Blockchain\Blockchain.ICODat.pas',
  Crypto in 'Crypto\Crypto.pas',
  Net.Client in 'Net\Net.Client.pas',
  Sync.Smartcontratcs in 'Sync\Sync.Smartcontratcs.pas',
  Sync.Base in 'Sync\Sync.Base.pas',
  Sync.Chain in 'Sync\Sync.Chain.pas',
  Net.LightSocket in 'Net\Net.LightSocket.pas',
  Net.CustomSocket in 'Net\Net.CustomSocket.pas',
  Net.Server in 'Net\Net.Server.pas',
  Net.ConnectedClient in 'Net\Net.ConnectedClient.pas',
  server.HTTP in 'Web\server\server.HTTP.pas',
  server.Types in 'Web\server\server.Types.pas',
  endpoints.Token in 'Web\endpoints\endpoints.Token.pas',
  endpoints.Base in 'Web\endpoints\endpoints.Base.pas',
  endpoints.Chain in 'Web\endpoints\endpoints.Chain.pas',
  endpoints.Account in 'Web\endpoints\endpoints.Account.pas',
  WordsPool in 'Crypto\SeedPhrase\WordsPool.pas',
  App.Constants in 'Core\App.Constants.pas';

var
  LPidFileName: String;
begin
  {$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown:=True;
  {$ENDIF}

  LPidFileName := 'LNode';
  try
    with TMutex.Create(LPidFileName) do
    try
      UI := TConsoleCore.Create;
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
      Writeln('LNode is already started');
  end;
end.
