unit controller.dto.regras.interfaces;

interface

uses
  System.Generics.Collections,

  model.regras,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces,
  model.service.scripts.interfaces;

type
  IRegra = interface
    ['{3C485EA0-A0B6-41A7-8422-03469CDBB4A7}']

    function id_regra(value: Integer): IRegra; overload;
    function id_regra: Integer; overload;

    function nome_regra(value: String): IRegra; overload;
    function nome_regra: String; overload;

    function dt_alt(value: TDateTime): IRegra; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IRegra; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tregras>;
  end;

implementation

end.
