unit controller.dto.profissionais_servicos.interfaces;

interface

uses
  System.Generics.Collections,

  model.profissionais_servicos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces,
  model.service.scripts.interfaces;

type
  IProfissionalServico = interface
    ['{AEB05A87-FFDA-41BF-8D29-68537A3EABDF}']

    function id_profissional_servico(value: Integer): IProfissionalServico; overload;
    function id_profissional_servico: Integer; overload;

    function id_pessoa(value: Integer): IProfissionalServico; overload;
    function id_pessoa: Integer; overload;

    function id_servico(value: Integer): IProfissionalServico; overload;
    function id_servico: Integer; overload;

    function dt_alt(value: TDateTime): IProfissionalServico; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IProfissionalServico; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tprofissionais_servicos>;
  end;

implementation

end.
