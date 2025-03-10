unit controller.dto.pacotes_creditos.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.pacotes_creditos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IPacoteCreditos = interface
    ['{BCCBE76F-1DD3-42F0-9D36-75B3770CCE58}']

    function id_pacote_credito(value: Integer): IPacoteCreditos; overload;
    function id_pacote_credito: Integer; overload;

    function nome(value: String): IPacoteCreditos; overload;
    function nome: String; overload;

    function creditos(value: Integer): IPacoteCreditos; overload;
    function creditos: Integer; overload;

    function valor_compra(value: Currency): IPacoteCreditos; overload;
    function valor_compra: Currency; overload;

    function dias_expiracao(value: Integer): IPacoteCreditos; overload;
    function dias_expiracao: Integer; overload;

    function dt_alt(value: TDateTime): IPacoteCreditos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IPacoteCreditos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tpacotes_creditos>;
  end;

implementation

end.
