unit controller.dto.profissionais_pacotes_creditos.interfaces;

interface

uses
  System.Generics.Collections,

  model.profissionais_pacotes_creditos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces,
  model.service.scripts.interfaces;

type
  IProfissionalPacoteCredito = interface
    ['{5A1F29BC-E02B-40FA-9471-2A72415BE556}']

    function id_profissional_pacote_credito(value: Integer): IProfissionalPacoteCredito; overload;
    function id_profissional_pacote_credito: Integer; overload;

    function id_pessoa(value: Integer): IProfissionalPacoteCredito; overload;
    function id_pessoa: Integer; overload;

    function id_pacote_credito(value: Integer): IProfissionalPacoteCredito; overload;
    function id_pacote_credito: Integer; overload;

    function data_validade(value: TDateTime): IProfissionalPacoteCredito; overload;
    function data_validade: TDateTime; overload;

    function dt_alt(value: TDateTime): IProfissionalPacoteCredito; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IProfissionalPacoteCredito; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tprofissionais_pacotes_creditos>;
  end;

implementation

end.
