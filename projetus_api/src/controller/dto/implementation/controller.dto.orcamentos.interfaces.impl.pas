unit controller.dto.orcamentos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.orcamentos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.orcamentos;

type
  TIOrcamentos = class(TInterfacedObject, IOrcamentos)
    private
      FEntity: Torcamentos;
      FService: IService<Torcamentos>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IOrcamentos;

    function id_orcamento(value: Integer): IOrcamentos; overload;
    function id_orcamento: Integer; overload;

    function id_pessoa(value: Integer): IOrcamentos; overload;
    function id_pessoa: Integer; overload;

    function id_servico(value: Integer): IOrcamentos; overload;
    function id_servico: Integer; overload;

    function info_adicionais(value: String): IOrcamentos; overload;
    function info_adicionais: String; overload;

    function urgente(value: Boolean): IOrcamentos; overload;
    function urgente: Boolean; overload;

    function previsao_inicio(value: TDate): IOrcamentos; overload;
    function previsao_inicio: TDate; overload;

    function dt_alt(value: TDateTime): IOrcamentos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IOrcamentos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Torcamentos>;
  end;

implementation

{ TIOrcamentos }

function TIOrcamentos.Build: IService<Torcamentos>;
begin
  Result := FService;
end;

constructor TIOrcamentos.Create;
begin
  FEntity := Torcamentos.Create;
  FService := TServiceORMBr<Torcamentos>.New(FEntity);
end;

destructor TIOrcamentos.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIOrcamentos.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIOrcamentos.dt_alt(value: TDateTime): IOrcamentos;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIOrcamentos.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIOrcamentos.dt_del(value: TDateTime): IOrcamentos;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIOrcamentos.id_orcamento: Integer;
begin
  Result := FEntity.id_orcamento;
end;

function TIOrcamentos.id_orcamento(value: Integer): IOrcamentos;
begin
  Result := Self;
  FEntity.id_orcamento := value;
end;

function TIOrcamentos.id_pessoa: Integer;
begin
  Result := FEntity.id_pessoa;
end;

function TIOrcamentos.id_pessoa(value: Integer): IOrcamentos;
begin
  Result := Self;
  FEntity.id_pessoa := value;
end;

function TIOrcamentos.id_servico: Integer;
begin
  Result := FEntity.id_servico;
end;

function TIOrcamentos.id_servico(value: Integer): IOrcamentos;
begin
  Result := Self;
  FEntity.id_servico := value;
end;

function TIOrcamentos.info_adicionais(value: String): IOrcamentos;
begin
  Result := Self;
  FEntity.info_adicionais := value;
end;

function TIOrcamentos.info_adicionais: String;
begin
  Result := FEntity.info_adicionais;
end;

class function TIOrcamentos.New: IOrcamentos;
begin
  Result := Self.Create;
end;

function TIOrcamentos.previsao_inicio: TDate;
begin
  Result := FEntity.previsao_inicio;
end;

function TIOrcamentos.previsao_inicio(value: TDate): IOrcamentos;
begin
  Result := Self;
  FEntity.previsao_inicio := value;
end;

function TIOrcamentos.urgente: Boolean;
begin
  Result := FEntity.urgente;
end;

function TIOrcamentos.urgente(value: Boolean): IOrcamentos;
begin
  Result := Self;
  FEntity.urgente := value;
end;

end.
