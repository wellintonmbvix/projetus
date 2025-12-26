unit model.service.scripts.interfaces;

interface

uses
  model.pessoa,
  model.configuracao_email;

type
  IServiceScripts = interface
    ['{ED87BDF7-F628-4924-A30D-1F8686EE6599}']

    function InsertCustomer(Cliente: Tpessoas; var msg: String): Boolean; overload;
    function GetEmailByUserName(userName: String; out email: String): Boolean; overload;
    function GetConfigEmail(host: String; out configEmail: Tconfiguracaoemail): Boolean;
    function ValidateCode(code: String; username: String; out msg: String): Boolean;
  end;

implementation

end.
