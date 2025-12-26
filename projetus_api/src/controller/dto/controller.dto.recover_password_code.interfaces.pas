unit controller.dto.recover_password_code.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.recover_password_codes,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IRecoverPasswordCodes = interface
    ['{A485FEF8-C2C9-4276-8B46-10BF448DCF56}']

    function code(value: String): IRecoverPasswordCodes; overload;
    function code: String; overload;

    function username(value: String): IRecoverPasswordCodes; overload;
    function username: String; overload;

    function date_expiration(value: TDateTime): IRecoverPasswordCodes; overload;
    function date_expiration: TDateTime; overload;

    function Build: IService<Trecover_password_code>;

  end;

implementation

end.
