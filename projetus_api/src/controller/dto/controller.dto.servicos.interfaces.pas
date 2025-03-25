unit controller.dto.servicos.interfaces;

interface

uses
  System.Generics.Collections,

  model.servicos,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces,
  model.service.scripts.interfaces;

type
  IServicos = interface
    ['{0F0E454C-68D2-4C2D-94D8-AABDDD64331C}']

    function id_servico(value: Integer): IServicos; overload;
    function id_servico: Integer; overload;

    function nome(value: String): IServicos; overload;
    function nome: String; overload;

    function dt_alt(value: TDateTime): IServicos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IServicos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tservicos>;
  end;

implementation

end.
