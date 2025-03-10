unit controller.dto.pessoa.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.pessoa,
  model.endereco,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IPessoa = interface
    ['{57A6B374-E682-4AD2-B95D-772009C6C00B}']

    function id_pessoa(value: Integer): IPessoa; overload;
    function id_pessoa: Integer; overload;

    function nome(value: String): IPessoa; overload;
    function nome: String; overload;

    function telefone1(value: String): IPessoa; overload;
    function telefone1: String; overload;

    function telefone2(value: String): IPessoa; overload;
    function telefone2: String; overload;

    function email(value: String): IPessoa; overload;
    function email: String; overload;

    function suspenso(value: Boolean): IPessoa; overload;
    function suspenso: Boolean; overload;

    function endereco(value: Tenderecos): IPessoa; overload;
    function endereco: Tenderecos; overload;

    function dt_alt(value: TDateTime): IPessoa; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IPessoa; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tpessoas>;
  end;

implementation

end.
