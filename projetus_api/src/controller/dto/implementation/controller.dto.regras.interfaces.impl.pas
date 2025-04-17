unit controller.dto.regras.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.regras.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.regras;

type
  TIRegra = class(TInterfacedObject, IRegra)
  private
    FEntity: Tregras;
    FService: IService<Tregras>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IRegra;

    function id_regra(value: Integer): IRegra; overload;
    function id_regra: Integer; overload;

    function nome_regra(value: String): IRegra; overload;
    function nome_regra: String; overload;

    function dt_alt(value: TDateTime): IRegra; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IRegra; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tregras>;
  end;

implementation

{ TIRegras }

function TIRegra.Build: IService<Tregras>;
begin
  Result := FService;
end;

constructor TIRegra.Create;
begin
  FEntity := Tregras.Create;
  FService := TServiceORMBr<Tregras>.New(FEntity);
end;

destructor TIRegra.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIRegra.dt_alt(value: TDateTime): IRegra;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIRegra.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIRegra.dt_del(value: TDateTime): IRegra;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIRegra.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIRegra.id_regra(value: Integer): IRegra;
begin
  Result := Self;
  FEntity.id_regra := value;
end;

function TIRegra.id_regra: Integer;
begin
  Result := FEntity.id_regra;
end;

class function TIRegra.New: IRegra;
begin
  Result := Self.Create;
end;

function TIRegra.nome_regra: String;
begin
  Result := FEntity.nome_regra;
end;

function TIRegra.nome_regra(value: String): IRegra;
begin
  Result := Self;
  FEntity.nome_regra := value;
end;

end.
