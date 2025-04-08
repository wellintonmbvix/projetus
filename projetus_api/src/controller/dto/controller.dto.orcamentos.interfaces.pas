unit controller.dto.orcamentos.interfaces;

interface

uses
  System.Generics.Collections,

  model.orcamentos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces,
  model.service.scripts.interfaces;

type
  IOrcamentos = interface
    ['{38FEBCFA-38E1-45B2-9C82-6546C7635778}']

    function id_orcamento(value: Integer): IOrcamentos; overload;
    function id_orcamento: Integer; overload;

    function id_pessoa(value: Integer): IOrcamentos; overload;
    function id_pessoa: Integer; overload;

    function id_servico(value: Integer): IOrcamentos; overload;
    function id_servico: Integer; overload;

    function info_adicionais(value: String): IOrcamentos; overload;
    function info_adicionais: String; overload;

    function urgente(value: Boolean): IOrcamentos; overload;
    function urgente: Boolean; overload;

    function previsao_inicio(value: TDate): IOrcamentos; overload;
    function previsao_inicio: TDate; overload;

    function dt_alt(value: TDateTime): IOrcamentos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IOrcamentos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Torcamentos>;
  end;

implementation

end.
