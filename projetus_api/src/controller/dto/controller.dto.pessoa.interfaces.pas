unit controller.dto.pessoa.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.pessoa,
  model.endereco,
  model.dados_pessoais,
  model.contatos,

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

    function tipo(value: String): IPessoa; overload;
    function tipo: String; overload;

    function suspenso(value: Boolean): IPessoa; overload;
    function suspenso: Boolean; overload;

    function endereco(value: Tenderecos): IPessoa; overload;
    function endereco: Tenderecos; overload;

    function dados_pessoais(value: Tdados_pessoais): IPessoa; overload;
    function dados_pessoais: Tdados_pessoais; overload;

    function contatos(value: TObjectList<Tcontatos>): IPessoa; overload;
    function contatos: TObjectList<Tcontatos>; overload;

    function dt_alt(value: TDateTime): IPessoa; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IPessoa; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tpessoas>;
  end;

implementation

end.
