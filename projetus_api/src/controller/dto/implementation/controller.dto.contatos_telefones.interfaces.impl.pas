unit controller.dto.contatos_telefones.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.contatos_telefones.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,
  ormbr.types.blob,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.contatos_telefones;

type
  TIContatosTelefones = class(TInterfacedObject, IContatosTelefones)
    private
    FEntity: Tcontatos_telefones;
    FService: IService<Tcontatos_telefones>;
    public
    constructor Create;
    destructor Destroy; override;
    class function New: IContatosTelefones;

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

{ TIContatosTelefones }

function TIContatosTelefones.Build: IService<Tcontatos_telefones>;
begin
  Result := FService;
end;

constructor TIContatosTelefones.Create;
begin
  FEntity := Tcontatos_telefones.Create;
  FService := TServiceORMBr<Tcontatos_telefones>.New(FEntity);
end;

destructor TIContatosTelefones.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIContatosTelefones.dt_alt(value: TDateTime): IContatosTelefones;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIContatosTelefones.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIContatosTelefones.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIContatosTelefones.dt_del(value: TDateTime): IContatosTelefones;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIContatosTelefones.id_contato(value: Integer): IContatosTelefones;
begin
  Result := Self;
  FEntity.id_contato := value;
end;

function TIContatosTelefones.id_contato: Integer;
begin
  Result := FEntity.id_contato;
end;

function TIContatosTelefones.id_contato_telefone: Integer;
begin
  Result := FEntity.id_contato_telefone;
end;

function TIContatosTelefones.id_contato_telefone(
  value: Integer): IContatosTelefones;
begin
  Result := Self;
  FEntity.id_contato_telefone := value;
end;

class function TIContatosTelefones.New: IContatosTelefones;
begin
  Result := Self.Create;
end;

function TIContatosTelefones.telefones(value: String): IContatosTelefones;
begin
  Result := Self;
  FEntity.telefones := value;
end;

function TIContatosTelefones.telefones: String;
begin
  Result := FEntity.telefones;
end;

end.
