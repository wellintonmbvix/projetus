unit controller.dto.historico_orcamentos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.historico_orcamentos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.historico_orcamentos;

type
  TIHistoricoOrcamentos = class(TInterfacedObject, IHistoricoOrcamentos)
    private
      FEntity: Thistorico_orcamentos;
      FService: IService<Thistorico_orcamentos>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IHistoricoOrcamentos;

    function id_historico_orcamento(value: Integer): IHistoricoOrcamentos; overload;
    function id_historico_orcamento: Integer; overload;

    function id_orcamento(value: Integer): IHistoricoOrcamentos; overload;
    function id_orcamento: Integer; overload;

    function id_pessoa(value: Integer): IHistoricoOrcamentos; overload;
    function id_pessoa: Integer; overload;

    function status(value: String): IHistoricoOrcamentos; overload;
    function status: String; overload;

    function dt_alt(value: TDateTime): IHistoricoOrcamentos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IHistoricoOrcamentos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Thistorico_orcamentos>;
  end;

implementation

{ TIHistoricoOrcamentos }

function TIHistoricoOrcamentos.Build: IService<Thistorico_orcamentos>;
begin
  Result := FService;
end;

constructor TIHistoricoOrcamentos.Create;
begin
  FEntity := Thistorico_orcamentos.Create;
  FService := TServiceORMBr<Thistorico_orcamentos>.New(FEntity);
end;

destructor TIHistoricoOrcamentos.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIHistoricoOrcamentos.dt_alt(value: TDateTime): IHistoricoOrcamentos;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIHistoricoOrcamentos.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIHistoricoOrcamentos.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIHistoricoOrcamentos.dt_del(value: TDateTime): IHistoricoOrcamentos;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIHistoricoOrcamentos.id_historico_orcamento: Integer;
begin
  Result := FEntity.id_historico_orcamento;
end;

function TIHistoricoOrcamentos.id_historico_orcamento(
  value: Integer): IHistoricoOrcamentos;
begin
  Result := Self;
  FEntity.id_historico_orcamento := value;
end;

function TIHistoricoOrcamentos.id_orcamento(
  value: Integer): IHistoricoOrcamentos;
begin
  Result := Self;
  FEntity.id_orcamento := value;
end;

function TIHistoricoOrcamentos.id_orcamento: Integer;
begin
  Result := FEntity.id_orcamento;
end;

function TIHistoricoOrcamentos.id_pessoa: Integer;
begin
  Result := FEntity.id_pessoa;
end;

function TIHistoricoOrcamentos.id_pessoa(value: Integer): IHistoricoOrcamentos;
begin
  Result := Self;
  FEntity.id_pessoa := value;
end;

class function TIHistoricoOrcamentos.New: IHistoricoOrcamentos;
begin
  Result := Self.Create;
end;

function TIHistoricoOrcamentos.status: String;
begin
  Result := FEntity.status;
end;

function TIHistoricoOrcamentos.status(value: String): IHistoricoOrcamentos;
begin
  Result := Self;
  FEntity.status := value;
end;

end.
