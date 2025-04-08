unit controller.dto.historico_creditos.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.historico_creditos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IHistoricoCreditos = interface
    ['{E52E2C37-34FA-4BB9-9D7C-E1E794BF2BEC}']

    function id_historico_credito(value: Integer): IHistoricoCreditos; overload;
    function id_historico_credito: Integer; overload;

    function id_pessoa(value: Integer): IHistoricoCreditos; overload;
    function id_pessoa: Integer;  overload;

    function credito(value: Currency): IHistoricoCreditos; overload;
    function credito: Currency; overload;

    function status(value: String): IHistoricoCreditos; overload;
    function status: String; overload;

    function dt_alt(value: TDateTime): IHistoricoCreditos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IHistoricoCreditos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Thistorico_creditos>;
  end;

implementation

end.
