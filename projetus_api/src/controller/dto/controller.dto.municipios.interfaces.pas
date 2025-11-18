unit controller.dto.municipios.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.municipios,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IMunicipios = interface
    ['{593DB5E5-9E9D-488B-B1C4-35326754FD97}']

    function Build: IService<Tmunicipios>;
  end;

implementation

end.
