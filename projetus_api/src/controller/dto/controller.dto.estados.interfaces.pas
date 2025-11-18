unit controller.dto.estados.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.estados,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IEstados = interface
    ['{25238EBC-60D1-4743-A946-335AE67054EA}']

    function Build: IService<Testados>;
  end;

implementation

end.
