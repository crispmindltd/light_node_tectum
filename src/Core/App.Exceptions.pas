unit App.Exceptions;

interface

uses
  SysUtils;

type
  EReceiveTimeout = class(Exception);
  EUnknownError = class(Exception);
  ENotFoundError = class(Exception);
  ENotSupportedError = class(Exception);
  EValidError = class(Exception);
  EAccAlreadyExistsError = class(Exception);
  EAuthError = class(Exception);
  EKeyExpiredError = class(Exception);
  EAddressNotExistsError = class(Exception);
  EInsufficientFundsError = class(Exception);
  ETokenAlreadyExists = class(Exception);
  ESameAddressesError = class(Exception);
  ESmartNotExistsError = class(Exception);
  ENoInfoForThisSmartError = class(Exception);
  EValidatorDidNotAnswerError = class(Exception);
  ENoInfoForThisAccountError = class(Exception);
  EFileNotExistsError = class(Exception);
  EDownloadingNotFinished = class(Exception);
  EInvalidSignError = class(Exception);
  ERequestInProgressError = class(Exception);

const
  LogInErrorText = 'Incorrect login or password';
  SignUpErrorText = 'Registration error. Try later';
  KeyExpiredErrorText = 'Session key expired. Please relogin';
  AddressNotExistsErrorText = 'Address does not exists';
  InsufficientFundsErrorText = 'Insufficient funds';
  UnableSendToTyourselfErrorText = 'Unable to send to yourself';
  TokenAlreadyExistsErrorText = 'Token already exists';

implementation

end.
