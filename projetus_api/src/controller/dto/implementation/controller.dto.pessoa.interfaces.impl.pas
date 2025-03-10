unit controller.dto.pessoa.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.pessoa.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.pessoa,
  model.endereco;

type
  TIPessoa = class(TInterfacedObject, IPessoa)
  private
    FEntity: Tpessoas;
    FService: IService<Tpessoas>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IPessoa;

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

{ TIPessoa }

function TIPessoa.Build: IService<Tpessoas>;
begin
  Result := FService;
end;

constructor TIPessoa.Create;
begin
  FEntity := Tpessoas.Create;
  FService := TServiceORMBr<Tpessoas>.New(FEntity);
end;

destructor TIPessoa.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIPessoa.dt_alt(value: TDateTime): IPessoa;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIPessoa.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIPessoa.dt_del(value: TDateTime): IPessoa;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIPessoa.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIPessoa.email: String;
begin
  Result := FEntity.email;
end;

function TIPessoa.email(value: String): IPessoa;
begin
  Result := Self;
  FEntity.email := value;
end;

function TIPessoa.endereco(value: Tenderecos): IPessoa;
begin
  Result := Self;
  FEntity.endereco := value;
end;

function TIPessoa.endereco: Tenderecos;
begin
  Result := FEntity.endereco;
end;

function TIPessoa.id_pessoa(value: Integer): IPessoa;
begin
  Result := Self;
  FEntity.id_pessoa := value;
end;

function TIPessoa.id_pessoa: Integer;
begin
  Result := FEntity.id_pessoa;
end;

class function TIPessoa.New: IPessoa;
begin
  Result := Self.Create;
end;

function TIPessoa.nome: String;
begin
  Result := FEntity.nome;
end;

function TIPessoa.nome(value: String): IPessoa;
begin
  Result := Self;
  FEntity.nome := value;
end;

function TIPessoa.suspenso: Boolean;
begin
  Result := FEntity.suspenso;
end;

function TIPessoa.suspenso(value: Boolean): IPessoa;
begin
  Result := Self;
  FEntity.suspenso := value;
end;

function TIPessoa.telefone1: String;
begin
  Result := FEntity.telefone1;
end;

function TIPessoa.telefone1(value: String): IPessoa;
begin
  Result := Self;
  FEntity.telefone1 := value;
end;

function TIPessoa.telefone2(value: String): IPessoa;
begin
  Result := Self;
  FEntity.telefone2 := value;
end;

function TIPessoa.telefone2: String;
begin
  Result := FEntity.telefone2;
end;

end.
