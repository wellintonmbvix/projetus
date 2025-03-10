unit controller.dto.cliente.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.cliente,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  ICliente = interface
    ['{4CE36D20-45B0-4048-8728-24AC5BC801A1}']

    function id_cliente(value: Integer): ICliente; overload;
    function id_cliente: Integer; overload;

    function nome(value: String): ICliente; overload;
    function nome: String; overload;

    function contato(value: TClientDataSet): ICliente; overload;
    function contato: TClientDataSet; overload;

    function Build: IService<Tcliente>;
  end;

implementation

end.
