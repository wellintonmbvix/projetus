unit model.service.scripts.interfaces;

interface

uses
  model.pessoa;

type
  IServiceScripts = interface
    ['{ED87BDF7-F628-4924-A30D-1F8686EE6599}']

    function InsertCustomer(Cliente: Tpessoas; var msg: String): Boolean; overload;
  end;

implementation

end.
