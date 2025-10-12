unit controller.dto.historico_creditos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.historico_creditos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.historico_creditos;

type
  TIHistoricoCreditos = class(TInterfacedObject, IHistoricoCreditos)
    private
      FEntity: Thistorico_creditos;
      FService: IService<Thistorico_creditos>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IHistoricoCreditos;

    function id_historico_credito(value: Integer): IHistoricoCreditos; overload;
    function id_historico_credito: Integer;  overload;

    function id_pessoa(value: Integer): IHistoricoCreditos; overload;
    function id_pessoa: Integer;  overload;

    function credito(value: Currency): IHistoricoCreditos; overload;
    function credito: Currency; overload;

    function status(value: String): IHistoricoCreditos; overload;
    function status: String; overload;

    function dt_alt(value: TDateTime): IHistoricoCreditos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IHistoricoCreditos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Thistorico_creditos>;
  end;

implementation

{ TIHistoricoCreditos }

function TIHistoricoCreditos.Build: IService<Thistorico_creditos>;
begin
  Result := FService;
end;

constructor TIHistoricoCreditos.Create;
begin
  FEntity := Thistorico_creditos.Create;
  FService := TServiceORMBr<Thistorico_creditos>.New(FEntity);
end;

function TIHistoricoCreditos.credito: Currency;
begin
  Result := FEntity.credito;
end;

function TIHistoricoCreditos.credito(value: Currency): IHistoricoCreditos;
begin
  Result := Self;
  FEntity.credito := value;
end;

destructor TIHistoricoCreditos.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIHistoricoCreditos.dt_alt(value: TDateTime): IHistoricoCreditos;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIHistoricoCreditos.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIHistoricoCreditos.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIHistoricoCreditos.dt_del(value: TDateTime): IHistoricoCreditos;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIHistoricoCreditos.id_historico_credito: Integer;
begin
  Result := FEntity.id_historico_credito;
end;

function TIHistoricoCreditos.id_historico_credito(
  value: Integer): IHistoricoCreditos;
begin
  Result := Self;
  FEntity.id_historico_credito := value;
end;

function TIHistoricoCreditos.id_pessoa(value: Integer): IHistoricoCreditos;
begin
  Result := Self;
  FEntity.id_pessoa := value;
end;

function TIHistoricoCreditos.id_pessoa: Integer;
begin
  Result := FEntity.id_pessoa;
end;

class function TIHistoricoCreditos.New: IHistoricoCreditos;
begin
  Result := Self.Create;
end;

function TIHistoricoCreditos.status(value: String): IHistoricoCreditos;
begin
  Result := Self;
  FEntity.status := value;
end;

function TIHistoricoCreditos.status: String;
begin
  Result := FEntity.status;
end;

end.
