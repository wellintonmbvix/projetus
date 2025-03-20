unit controller.dto.contatos_telefones.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.contatos_telefones,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IContatosTelefones = interface
    ['{AF25C2E6-C477-451B-906D-95C0C2F579F3}']

    function id_contato_telefone(value: Integer): IContatosTelefones; overload;
    function id_contato_telefone: Integer; overload;

    function id_contato(value: Integer): IContatosTelefones; overload;
    function id_contato: Integer; overload;

    function telefones(value: String): IContatosTelefones; overload;
    function telefones: String; overload;

    function dt_alt(value: TDateTime): IContatosTelefones; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IContatosTelefones; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tcontatos_telefones>;
  end;

implementation

end.
