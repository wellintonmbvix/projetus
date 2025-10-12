unit controller.dto.pessoa.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.pessoa.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.service.scripts.interfaces,
  model.service.scripts.interfaces.impl,
  model.pessoa,
  model.usuarios,
  model.dados_pessoais,
  model.contatos,
  model.endereco;

type
  TIPessoa = class(TInterfacedObject, IPessoa)
  private
    FEntity: Tpessoas;
    FService: IService<Tpessoas>;
    FServiceScript: IServiceScripts;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IPessoa;

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

    function usuario(value: Tusuarios): IPessoa; overload;
    function usuario: Tusuarios; overload;

    function dt_alt(value: TDateTime): IPessoa; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IPessoa; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tpessoas>;
    function Manufactory: IServiceScripts;
  end;

implementation

{ TIPessoa }

function TIPessoa.Build: IService<Tpessoas>;
begin
  Result := FService;
end;

function TIPessoa.contatos(value: TObjectList<Tcontatos>): IPessoa;
begin
  Result := Self;
  FEntity.contatos := value;
end;

function TIPessoa.contatos: TObjectList<Tcontatos>;
begin
  Result := FEntity.contatos;
end;

constructor TIPessoa.Create;
begin
  FEntity := Tpessoas.Create;
  FService := TServiceORMBr<Tpessoas>.New(FEntity);
  FServiceScript := TServiceScripts.New;
end;

function TIPessoa.dados_pessoais(value: Tdados_pessoais): IPessoa;
begin
  Result := Self;
  FEntity.dados_pessoais := value;
end;

function TIPessoa.dados_pessoais: Tdados_pessoais;
begin
  Result := FEntity.dados_pessoais;
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

function TIPessoa.Manufactory: IServiceScripts;
begin
  Result := FServiceScript;
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

function TIPessoa.tipo(value: String): IPessoa;
begin
  Result := Self;
  FEntity.tipo := value;
end;

function TIPessoa.tipo: String;
begin
  Result := FEntity.tipo;
end;

function TIPessoa.usuario: Tusuarios;
begin
  Result := FEntity.usuario;
end;

function TIPessoa.usuario(value: Tusuarios): IPessoa;
begin
  Result := Self;
  FEntity.usuario := value;
end;

function TIPessoa.suspenso(value: Boolean): IPessoa;
begin
  Result := Self;
  FEntity.suspenso := value;
end;

end.
