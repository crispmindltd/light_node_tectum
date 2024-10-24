unit Blockchain.BaseTypes;

interface

const
   TokenLength = 32;
   TockenLength1 = 64;
   CTockenLength1 = 64;
   CHashLength = 32;
   CSignLine = 120;

type
  THash = array[1..TokenLength] of byte;

  TTknFromTo = record
    TokenID: Integer;
    Amount: Int64;
    FromBlock: Integer;
  end;

  TTknSmart = record
    ID: Int64;
    Status: Byte;
    Delta: Int64;
    tkn: array [1..2] of TTknFromTo;
    TimeEvent: Tdatetime;
  end;

  Tbc2 = record
    Hash: THash;
    Status: Byte;
    Smart: TTknSmart;
  end;

  TCHash = array[1..CHashLength] of byte;

  TCTknFromTo = record
     TokenID   : integer;
     Amount    : int64;
     FromBlock : integer;
  end;

  TCSmart = record
     ID        : int64;
     Status    : byte;
     Delta     : int64;
     tkn       : array[1..2]of TCTknFromTo;
     fee1      : int64;
     fee2      : int64;
     TimeEvent : Tdatetime;
  end;

  TCSign = record
     SignLine  : string[CSignLine];
     CCount    : integer; // exclude double tz
  end;

  TCbc4 = record               //smart contrakt for token
     Hash      : TCHash;
     Status    : byte;
     Smart     : TCSmart;
     CSign     : TCSign;
  end;

  TCSmartKey = record          //startup keys
    status  : byte;
    Abreviature    : string[8];
    key1    : string[150];
    key2    : string[150];
    SmartID : integer;
  end;

  TTokenBase = record
    Status        : byte; //1-ok, 55-hold
    OwnerID       : integer;
    TCount        : integer;  // transactions count
    TokenDatID    : integer; // ID ICO
    StartBlock    : integer;
    LastBlock     : integer;
    HoldAmount    : int64;
    Direct        : byte;//1-from, 2-to
    Token         : string[TockenLength1];
  end;

  TCTokensBase = record
    Status        : byte; //1-ok, 55-hold
    OwnerID       : integer;
    StartBlock    : integer;
    LastBlock     : integer;
    HoldAmount    : Uint64;
    Token         : string[CTockenLength1];
  end;

  TTokenICODat = record
    OwnerID     : integer;
    ICOID       : integer;
    Status      : byte;      //11 - smart with privat key
    FullName    : shortstring;
    ShortName   : string[32];
    Abreviature : string[8];
    TockenCount : int64;
    FloatSize   : byte;
    BountyPcent : single;
    RegDate     : Tdatetime;
    StartDate   : Tdatetime;
    EndDate     : Tdatetime;
    Fiat        : single;
    Valut       : byte; //1-$
  end;

  TExplorerTransactionInfo = record
    DateTime: TDateTime;
    BlockNum: Integer;
    Hash: String[CHashLength*2];
    TransFrom: String[TockenLength1];
    TransTo: String[TockenLength1];
    Amount: Double;
    FloatSize: Byte;
    Ticker: string[8];
  end;

  THistoryTransactionInfo = record
    DateTime: TDateTime;
    BlockNum: Int64;
    Hash: String[CHashLength*2];
    Address: String[TockenLength1];
    Value: Double;
    Incom: Boolean;
  end;

implementation

end.
