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
  LOGIN_ERROR_TEXT = 'Incorrect login or password';
  SIGN_UP_ERROR_TEXT = 'Registration error. Try later';

implementation

end.
