unit controller.dto.profissionais_servicos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.profissionais_servicos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.profissionais_servicos;

type
  TIProfissionalServico = class(TInterfacedObject, IProfissionalServico)
  private
    FEntity: Tprofissionais_servicos;
    FService: IService<Tprofissionais_servicos>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IProfissionalServico;

    function id_profissional_servico(value: Integer)
      : IProfissionalServico; overload;
    function id_profissional_servico: Integer; overload;

    function id_pessoa(value: Integer): IProfissionalServico; overload;
    function id_pessoa: Integer; overload;

    function id_servico(value: Integer): IProfissionalServico; overload;
    function id_servico: Integer; overload;

    function dt_alt(value: TDateTime): IProfissionalServico; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IProfissionalServico; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tprofissionais_servicos>;
  end;

implementation

{ TIProfissionalServico }

function TIProfissionalServico.Build: IService<Tprofissionais_servicos>;
begin
  Result := FService;
end;

constructor TIProfissionalServico.Create;
begin
  FEntity := Tprofissionais_servicos.Create;
  FService := TServiceORMBr<Tprofissionais_servicos>.New(FEntity);
end;

destructor TIProfissionalServico.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIProfissionalServico.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIProfissionalServico.dt_alt(value: TDateTime): IProfissionalServico;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIProfissionalServico.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIProfissionalServico.dt_del(value: TDateTime): IProfissionalServico;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIProfissionalServico.id_pessoa: Integer;
begin
  Result := FEntity.id_pessoa;
end;

function TIProfissionalServico.id_pessoa(value: Integer): IProfissionalServico;
begin
  Result := Self;
  FEntity.id_pessoa := value;
end;

function TIProfissionalServico.id_profissional_servico: Integer;
begin
  Result := FEntity.id_profissional_servico;
end;

function TIProfissionalServico.id_profissional_servico(
  value: Integer): IProfissionalServico;
begin
  Result := Self;
  FEntity.id_profissional_servico := value;
end;

function TIProfissionalServico.id_servico: Integer;
begin
  Result := FEntity.id_servico;
end;

function TIProfissionalServico.id_servico(value: Integer): IProfissionalServico;
begin
  Result := Self;
  FEntity.id_servico := value;
end;

class function TIProfissionalServico.New: IProfissionalServico;
begin
  Result := Self.Create;
end;

end.
