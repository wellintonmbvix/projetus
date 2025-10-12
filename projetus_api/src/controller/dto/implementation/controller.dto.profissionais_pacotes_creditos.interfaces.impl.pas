unit controller.dto.profissionais_pacotes_creditos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.profissionais_pacotes_creditos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.profissionais_pacotes_creditos;

type
  TIProfissionalPacoteCredito = class(TInterfacedObject, IProfissionalPacoteCredito)
    private
      FEntity: Tprofissionais_pacotes_creditos;
      FService: IService<Tprofissionais_pacotes_creditos>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IProfissionalPacoteCredito;

    function id_profissional_pacote_credito(value: Integer): IProfissionalPacoteCredito; overload;
    function id_profissional_pacote_credito: Integer; overload;

    function id_pessoa(value: Integer): IProfissionalPacoteCredito; overload;
    function id_pessoa: Integer; overload;

    function id_pacote_credito(value: Integer): IProfissionalPacoteCredito; overload;
    function id_pacote_credito: Integer; overload;

    function data_validade(value: TDateTime): IProfissionalPacoteCredito; overload;
    function data_validade: TDateTime; overload;

    function dt_alt(value: TDateTime): IProfissionalPacoteCredito; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IProfissionalPacoteCredito; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tprofissionais_pacotes_creditos>;
  end;

implementation

{ TIProfissionalPacoteCredito }

function TIProfissionalPacoteCredito.Build: IService<Tprofissionais_pacotes_creditos>;
begin
  Result := FService;
end;

constructor TIProfissionalPacoteCredito.Create;
begin
  FEntity := Tprofissionais_pacotes_creditos.Create;
  FService := TServiceORMBr<Tprofissionais_pacotes_creditos>.New(FEntity);
end;

function TIProfissionalPacoteCredito.data_validade(
  value: TDateTime): IProfissionalPacoteCredito;
begin
  Result := Self;
  FEntity.data_validade := value;
end;

function TIProfissionalPacoteCredito.data_validade: TDateTime;
begin
  Result := FEntity.data_validade;
end;

destructor TIProfissionalPacoteCredito.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIProfissionalPacoteCredito.dt_alt(
  value: TDateTime): IProfissionalPacoteCredito;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIProfissionalPacoteCredito.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIProfissionalPacoteCredito.dt_del(
  value: TDateTime): IProfissionalPacoteCredito;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIProfissionalPacoteCredito.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIProfissionalPacoteCredito.id_pacote_credito(
  value: Integer): IProfissionalPacoteCredito;
begin
  Result := Self;
  FEntity.id_pacote_credito := value;
end;

function TIProfissionalPacoteCredito.id_pacote_credito: Integer;
begin
  Result := FEntity.id_pacote_credito;
end;

function TIProfissionalPacoteCredito.id_pessoa(
  value: Integer): IProfissionalPacoteCredito;
begin
  Result := Self;
  FEntity.id_pessoa := value;
end;

function TIProfissionalPacoteCredito.id_pessoa: Integer;
begin
  Result := FEntity.id_pessoa;
end;

function TIProfissionalPacoteCredito.id_profissional_pacote_credito: Integer;
begin
  Result := FEntity.id_profissional_pacote_credito;
end;

function TIProfissionalPacoteCredito.id_profissional_pacote_credito(
  value: Integer): IProfissionalPacoteCredito;
begin
  Result := Self;
  FEntity.id_profissional_pacote_credito := value;
end;

class function TIProfissionalPacoteCredito.New: IProfissionalPacoteCredito;
begin
  Result := Self.Create;
end;

end.
