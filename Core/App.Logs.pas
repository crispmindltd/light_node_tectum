unit App.Logs;

interface

uses
  Classes,
  IOUtils,
  SyncObjs,
  SysUtils,
  TypInfo;

type
  TLogFolder = (connections, sync, tcp, http);
  TLogType = (INCOM, OUTGO, NONE, ERROR);

  TLog = class
    private
      FFolder: TLogFolder;
      FPath: String;
      FLogNum: Int64;
      FLock: TCriticalSection;

      function CutLogString(const ALogStr: String): String;
    public
      constructor Create(AFullPath: String; AFolder: TLogFolder);
      destructor Destroy; override;

      procedure DoLog(AText: String; AType: TLogType);

      property getFolder: TLogFolder read FFolder;
  end;

  TLogs = class
    const
      mainLogsFolderName = 'logs';
    strict private
      FLogs: array[0..Ord(High(TLogFolder))] of TLog;
      FPath: String;

      procedure Init;
    public
      constructor Create;
      destructor Destroy; override;

      procedure DoLog(AText: String; AType: TLogType = INCOM; AFolder: TLogFolder = connections);
  end;

var
  Logs: TLogs;

implementation

{ TLog }

constructor TLog.Create(AFullPath: String; AFolder: TLogFolder);
begin
  FFolder := AFolder;
  FPath := AFullPath;
  FLogNum := 0;
  FLock := TCriticalSection.Create;
end;

function TLog.CutLogString(const ALogStr: String): String;
var
  l: Integer;
begin
  Result := '';
  l := Length(ALogStr);
  if l <= 600 then
    Result := ALogStr
  else
    Result := Format('%s ... %s',[ALogStr.Substring(0,300),ALogStr.Substring(l-300,300)]);
end;

destructor TLog.Destroy;
begin
  FLock.Free;

  inherited;
end;

procedure TLog.DoLog(AText: String; AType: TLogType);
var
  fileName: String;
  i: Integer;
  toLog: TStringBuilder;

  function GetFileSize(APath: String): Int64;
  var
    FS: TFileStream;
  begin
    try
      FS := TFileStream.Create(APath, fmOpenRead);
      try
        Result := FS.Size;
      finally
        FS.Free;
      end;
    except
      Result := -1;
    end;
  end;

begin
  FLock.Enter;
  toLog := TStringBuilder.Create;
  try
    if not DirectoryExists(FPath) then
      TDirectory.CreateDirectory(FPath);

    i := 0;
    fileName := TPath.Combine(FPath, FormatDateTime('yyyy.mm.dd', Now) + '.log');
    while FileExists(fileName) and (GetFileSize(fileName) >= 2097152) do  //group the logs into files no larger than 2 megabytes
    begin
      fileName := Format('%s(%d).log',[TPath.Combine(FPath, FormatDateTime('yyyy.mm.dd', Now) + '.log'),i]);
      Inc(i);
    end;

    toLog.Append(FLogNum.ToString);
    toLog.Append(#9);
    toLog.Append(FormatDateTime('dd.mm.yy hh:mm:ss:zzz', Now));
    case AType of
      INCOM:
        toLog.Append(' <- ');
      OUTGO:
        toLog.Append(' -> ');
      NONE:
        toLog.Append(' -- ');
      ERROR:
        toLog.Append(' !! ');
    end;
    toLog.Append(CutLogString(AText));

    TFile.AppendAllText(fileName, toLog.ToString.Replace(#10, '#10', [rfReplaceAll]).
                                                 Replace(#13, '#13', [rfReplaceAll])+ #13#10, TEncoding.ANSI);
    Inc(FLogNum);
  finally
    FreeAndNil(toLog);
    FLock.Leave;
  end;
end;

{ TLogs }

constructor TLogs.Create;
begin
  FPath := TPath.Combine(TDirectory.GetCurrentDirectory,mainLogsFolderName);
  Init;
end;

destructor TLogs.Destroy;
var
  i: Integer;
begin
  for i := 0 to Ord(High(TLogFolder)) do
    FLogs[i].Free;

  inherited;
end;

procedure TLogs.DoLog(AText: String; AType: TLogType; AFolder: TLogFolder);
var
  log: TLog;
begin
  for log in FLogs do
    if log.getFolder = AFolder then
      log.DoLog(AText,AType);
end;

procedure TLogs.Init;
var
  fullPath: String;
  i: Integer;
begin
  for i := 0 to Ord(High(TLogFolder)) do
  begin
    fullPath := TPath.Combine(FPath,GetEnumName(TypeInfo(TLogFolder),i));
    FLogs[i] := TLog.Create(fullPath,TLogFolder(i));
  end;
end;

end.

