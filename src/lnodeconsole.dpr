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
  App.Logs in 'Core\App.Logs.pas',
  App.Exceptions in 'Core\App.Exceptions.pas',
  App.Settings in 'Core\App.Settings.pas',
  Net.Data in 'Net\Net.Data.pas',
  Crypto in 'Crypto\Crypto.pas',
  Net.Client in 'Net\Net.Client.pas',
  Net.LightSocket in 'Net\Net.LightSocket.pas',
  Net.CustomSocket in 'Net\Net.CustomSocket.pas',
  Net.Server in 'Net\Net.Server.pas',
  Net.ConnectedClient in 'Net\Net.ConnectedClient.pas',
  server.HTTP in 'Web\server\server.HTTP.pas',
  server.Types in 'Web\server\server.Types.pas',
  endpoints.Token in 'Web\endpoints\endpoints.Token.pas',
  endpoints.Base in 'Web\endpoints\endpoints.Base.pas',
  endpoints.Account in 'Web\endpoints\endpoints.Account.pas',
  WordsPool in 'Crypto\SeedPhrase\WordsPool.pas',
  App.Constants in 'Core\App.Constants.pas',
  endpoints.Node in 'Web\endpoints\endpoints.Node.pas',
  Blockchain.BaseTypes in 'Blockchain\Blockchain.BaseTypes.pas',
  Blockchain.ICODat in 'Blockchain\Blockchain.ICODat.pas',
  Blockchain.Intf in 'Blockchain\Blockchain.Intf.pas',
  Blockchain.Main in 'Blockchain\Blockchain.Main.pas',
  Blockchain.SmartKey in 'Blockchain\Blockchain.SmartKey.pas',
  Blockchain.TET in 'Blockchain\Blockchain.TET.pas',
  Blockchain.TETDynamic in 'Blockchain\Blockchain.TETDynamic.pas',
  Blockchain.Token in 'Blockchain\Blockchain.Token.pas',
  Blockchain.TokenDynamic in 'Blockchain\Blockchain.TokenDynamic.pas',
  Sync.Base in 'Sync\Sync.Base.pas',
  Sync.TETChain in 'Sync\Sync.TETChain.pas',
  Sync.TokensChains in 'Sync\Sync.TokensChains.pas';

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
      UI := TConsoleCore.Create;
      try
        AppCore := TAppCore.Create;
        AppCore.Run;
        UI.Run;
      except
        on Exception do
          exit;
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
