unit controller.dto.contatos_emails.interfaces;

interface

uses
  System.Generics.Collections,
  DBClient,

  model.contatos_emails,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IContatosEmails = interface
    ['{860A39D4-8B23-413E-AACD-A77028FB9918}']

    function id_contato_email(value: String): IContatosEmails; overload;
    function id_contato_email: String; overload;

    function id_contato(value: Integer): IContatosEmails; overload;
    function id_contato: Integer; overload;

    function email(value: String): IContatosEmails; overload;
    function email: String; overload;

    function dt_alt(value: TDateTime): IContatosEmails; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IContatosEmails; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tcontatos_emails>;
  end;

implementation

end.
