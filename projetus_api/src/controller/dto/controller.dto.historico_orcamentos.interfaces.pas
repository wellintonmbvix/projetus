unit controller.dto.historico_orcamentos.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.historico_orcamentos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IHistoricoOrcamentos = interface
    ['{ABB0125A-CCE9-4078-86C2-F1224C1C2B64}']

    function id_historico_orcamento(value: Integer): IHistoricoOrcamentos; overload;
    function id_historico_orcamento: Integer; overload;

    function id_orcamento(value: Integer): IHistoricoOrcamentos; overload;
    function id_orcamento: Integer; overload;

    function id_pessoa(value: Integer): IHistoricoOrcamentos; overload;
    function id_pessoa: Integer; overload;

    function status(value: String): IHistoricoOrcamentos; overload;
    function status: String; overload;

    function dt_alt(value: TDateTime): IHistoricoOrcamentos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IHistoricoOrcamentos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Thistorico_orcamentos>;
  end;

implementation

end.
