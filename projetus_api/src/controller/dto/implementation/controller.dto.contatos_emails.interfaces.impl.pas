unit controller.dto.contatos_emails.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.contatos_emails.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,
  ormbr.types.blob,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.contatos_emails;

type
  TIContatosEmails = class(TInterfacedObject, IContatosEmails)
  private
    FEntity: Tcontatos_emails;
    FService: IService<Tcontatos_emails>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IContatosEmails;

    function id_contato_email(value: Integer): IContatosEmails; overload;
    function id_contato_email: Integer; overload;

    function id_contato(value: Integer): IContatosEmails; overload;
    function id_contato: Integer; overload;

    function emails(value: String): IContatosEmails; overload;
    function emails: String; overload;

    function dt_alt(value: TDateTime): IContatosEmails; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IContatosEmails; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tcontatos_emails>;
  end;

implementation

{ TIContatosEmails }

function TIContatosEmails.Build: IService<Tcontatos_emails>;
begin
  Result := FService;
end;

constructor TIContatosEmails.Create;
begin
  FEntity := Tcontatos_emails.Create;
  FService := TServiceORMBr<Tcontatos_emails>.New(FEntity);
end;

destructor TIContatosEmails.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIContatosEmails.dt_alt(value: TDateTime): IContatosEmails;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIContatosEmails.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIContatosEmails.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIContatosEmails.emails: String;
begin
  Result := FEntity.emails;
end;

function TIContatosEmails.emails(value: String): IContatosEmails;
begin
  Result := Self;
  FEntity.emails := value;
end;

function TIContatosEmails.dt_del(value: TDateTime): IContatosEmails;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIContatosEmails.id_contato(value: Integer): IContatosEmails;
begin
  Result := Self;
  FEntity.id_contato := value;
end;

function TIContatosEmails.id_contato: Integer;
begin
  Result := FEntity.id_contato;
end;

function TIContatosEmails.id_contato_email(value: Integer): IContatosEmails;
begin
  Result := Self;
  FEntity.id_contato_email := value;
end;

function TIContatosEmails.id_contato_email: Integer;
begin
  Result := FEntity.id_contato_email;
end;

class function TIContatosEmails.New: IContatosEmails;
begin
  Result := Self.Create;
end;

end.
