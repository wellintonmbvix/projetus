unit controller.dto.usuarios.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.usuarios.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.usuarios,
  model.usuarios_regras;

type
  TIUsuario = class(TInterfacedObject, IUsuario)
  private
    FEntity: Tusuarios;
    FService: IService<Tusuarios>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IUsuario;

    function id_usuario(value: Integer): IUsuario; overload;
    function id_usuario: Integer; overload;

    function id_pessoa(value: Integer): IUsuario; overload;
    function id_pessoa: Integer; overload;

    function nome_usuario(value: String): IUsuario; overload;
    function nome_usuario: String; overload;

    function senha_hash(value: String): IUsuario; overload;
    function senha_hash: String; overload;

    function dt_alt(value: TDateTime): IUsuario; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IUsuario; overload;
    function dt_del: TDateTime; overload;

    function usuarios_regras(value: TObjectList<Tusuarios_regras>)
      : IUsuario; overload;
    function usuarios_regras: TObjectList<Tusuarios_regras>; overload;

    function Build: IService<Tusuarios>;
  end;

implementation

{ TIUsuario }

function TIUsuario.Build: IService<Tusuarios>;
begin
  Result := FService;
end;

constructor TIUsuario.Create;
begin
  FEntity := Tusuarios.Create;
  FService := TServiceORMBr<Tusuarios>.New(FEntity);
end;

destructor TIUsuario.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIUsuario.dt_alt(value: TDateTime): IUsuario;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIUsuario.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIUsuario.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIUsuario.dt_del(value: TDateTime): IUsuario;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIUsuario.id_pessoa: Integer;
begin
  Result := FEntity.id_pessoa;
end;

function TIUsuario.id_pessoa(value: Integer): IUsuario;
begin
  Result := Self;
  FEntity.id_pessoa := value;
end;

function TIUsuario.id_usuario: Integer;
begin
  Result := FEntity.id_usuario;
end;

function TIUsuario.id_usuario(value: Integer): IUsuario;
begin
  Result := Self;
  FEntity.id_usuario := value;
end;

class function TIUsuario.New: IUsuario;
begin
  Result := Self.Create;
end;

function TIUsuario.nome_usuario(value: String): IUsuario;
begin
  Result := Self;
  FEntity.nome_usuario := value;
end;

function TIUsuario.nome_usuario: String;
begin
  Result := FEntity.nome_usuario;
end;

function TIUsuario.senha_hash: String;
begin
  Result := FEntity.senha_hash;
end;

function TIUsuario.senha_hash(value: String): IUsuario;
begin
  Result := Self;
  FEntity.senha_hash := value;
end;

function TIUsuario.usuarios_regras(value: TObjectList<Tusuarios_regras>)
  : IUsuario;
begin
  Result := Self;
  FEntity.usuarios_regras := value;
end;

function TIUsuario.usuarios_regras: TObjectList<Tusuarios_regras>;
begin
  Result := FEntity.usuarios_regras;
end;

end.
