unit Blockchain.Transactions;

interface

uses
  Blockchain.BaseTypes,
  SysUtils;

type
  TTransactionsChain = class(TBaseChain)
  public
    constructor Create(AName: string; const Data: TBytes;
      AtypeChain: TChainTypes); override;
    destructor Destroy; override;

    function GetBlock(Ind: UINT64): TBaseBlock; override;
  end;

implementation

end.
