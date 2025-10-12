unit controller.dto.pacotes_creditos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.pacotes_creditos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.pacotes_creditos;

type
  TIPacoteCreditos = class(TInterfacedObject, IPacoteCreditos)
  private
    FEntity: Tpacotes_creditos;
    FService: IService<Tpacotes_creditos>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IPacoteCreditos;

    function id_pacote_credito(value: Integer): IPacoteCreditos; overload;
    function id_pacote_credito: Integer; overload;

    function nome(value: String): IPacoteCreditos; overload;
    function nome: String; overload;

    function creditos(value: Integer): IPacoteCreditos; overload;
    function creditos: Integer; overload;

    function valor_compra(value: Currency): IPacoteCreditos; overload;
    function valor_compra: Currency; overload;

    function dias_expiracao(value: Integer): IPacoteCreditos; overload;
    function dias_expiracao: Integer; overload;

    function dt_alt(value: TDateTime): IPacoteCreditos; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IPacoteCreditos; overload;
    function dt_del: TDateTime; overload;

    function Build: IService<Tpacotes_creditos>;
  end;

implementation

{ TIPacoteCreditos }

function TIPacoteCreditos.Build: IService<Tpacotes_creditos>;
begin
  Result := FService;
end;

constructor TIPacoteCreditos.Create;
begin
  FEntity := Tpacotes_creditos.Create;
  FService := TServiceORMBr<Tpacotes_creditos>.New(FEntity);
end;

function TIPacoteCreditos.creditos: Integer;
begin
  Result := FEntity.creditos;
end;

function TIPacoteCreditos.creditos(value: Integer): IPacoteCreditos;
begin
  Result := Self;
  FEntity.creditos := value;
end;

destructor TIPacoteCreditos.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIPacoteCreditos.dias_expiracao: Integer;
begin
  Result := FEntity.dias_expiracao;
end;

function TIPacoteCreditos.dias_expiracao(value: Integer): IPacoteCreditos;
begin
  Result := Self;
  FEntity.dias_expiracao := value;
end;

function TIPacoteCreditos.dt_alt(value: TDateTime): IPacoteCreditos;
begin
  Result := Self;
  FEntity.dt_alt := value;
end;

function TIPacoteCreditos.dt_alt: TDateTime;
begin
  Result := FEntity.dt_alt;
end;

function TIPacoteCreditos.dt_del: TDateTime;
begin
  Result := FEntity.dt_del;
end;

function TIPacoteCreditos.dt_del(value: TDateTime): IPacoteCreditos;
begin
  Result := Self;
  FEntity.dt_del := value;
end;

function TIPacoteCreditos.id_pacote_credito: Integer;
begin
  Result := FEntity.id_pacote_credito;
end;

function TIPacoteCreditos.id_pacote_credito(value: Integer): IPacoteCreditos;
begin
  Result := Self;
  FEntity.id_pacote_credito := value;
end;

class function TIPacoteCreditos.New: IPacoteCreditos;
begin
  Result := Self.Create;
end;

function TIPacoteCreditos.nome(value: String): IPacoteCreditos;
begin
  Result := Self;
  FEntity.nome := value;
end;

function TIPacoteCreditos.nome: String;
begin
  Result := FEntity.nome;
end;

function TIPacoteCreditos.valor_compra: Currency;
begin
  Result := FEntity.valor_compra;
end;

function TIPacoteCreditos.valor_compra(value: Currency): IPacoteCreditos;
begin
  Result := Self;
  FEntity.valor_compra := value;
end;

end.
