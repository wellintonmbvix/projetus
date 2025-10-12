unit controller.dto.servicos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.servicos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.servicos;

type
  TIServicos = class(TInterfacedObject, IServicos)
  private
    FEntity: Tservicos;
    FService: IService<Tservicos>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IServicos;

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

{ TIServicos }

function TIServicos.Build: IService<Tservicos>;
begin
  Result := FService;
end;

constructor TIServicos.Create;
begin
  FEntity := Tservicos.Create;
  FService := TServiceORMBr<Tservicos>.New(FEntity);
end;

destructor TIServicos.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIServicos.dt_alt(value: TDateTime): IServicos;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIServicos.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIServicos.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIServicos.dt_del(value: TDateTime): IServicos;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIServicos.id_servico(value: Integer): IServicos;
begin
  Result := Self;
  FEntity.id_servico := value;
end;

function TIServicos.id_servico: Integer;
begin
  Result := FEntity.id_servico;
end;

class function TIServicos.New: IServicos;
begin
  Result := Self.Create;
end;

function TIServicos.nome: String;
begin
  Result := FEntity.nome;
end;

function TIServicos.nome(value: String): IServicos;
begin
  Result := Self;
  FEntity.nome := value;
end;

end.
