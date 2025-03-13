unit controller.dto.contatos.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.contatos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IContatos = interface
    ['{BC78572A-01DF-4E24-9893-F3A8CEBBB228}']

    function Build: IService<Tcontatos>;
  end;

implementation

end.
