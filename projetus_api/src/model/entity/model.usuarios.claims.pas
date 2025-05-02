unit model.usuarios.claims;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  model.usuarios_regras,

  JOSE.Core.JWT,
  JOSE.Types.JSON;

type
  Tusuarios_claims = class(TJWTClaims)
  private
    function GetIdUsuario: Integer;
    procedure SetIdUsuario(const Value: Integer);
    function GetIdPessoa: Integer;
    procedure SetIdPessoa(const Value: Integer);
    function GetNomeUsuario: String;
    procedure SetNomeUsuario(const Value: String);
    function GetRegras: String;
    procedure SetRegras(const Value: String);
  public
    property id_usuario: Integer read GetIdUsuario write SetIdUsuario;
    property id_pessoa: Integer read GetIdPessoa write SetIdPessoa;
    property nome_usuario: String read GetNomeUsuario write SetNomeUsuario;
    property regras: String read GetRegras write SetRegras;
  end;

const JWTPassword = 'suaSenhaMaisFraca';

implementation

{ Tusuarios_claims }

function Tusuarios_claims.GetIdPessoa: Integer;
begin
  Result := TJSONUtils.GetJSONValue('id_pessoa', FJSON).AsInteger;
end;

function Tusuarios_claims.GetIdUsuario: Integer;
begin
  Result := TJSONUtils.GetJSONValue('id_usuario', FJSON).AsInteger;
end;

function Tusuarios_claims.GetNomeUsuario: String;
begin
  Result := TJSONUtils.GetJSONValue('nome_usuario', FJSON).AsString;
end;

function Tusuarios_claims.GetRegras: String;
begin
  Result := TJSONUtils.GetJSONValue('regras', FJSON).AsString;
end;

procedure Tusuarios_claims.SetIdPessoa(const Value: Integer);
begin
  TJSONUtils.SetJSONValueFrom<Integer>('id_pessoa', Value, FJSON);
end;

procedure Tusuarios_claims.SetIdUsuario(const Value: Integer);
begin
  TJSONUtils.SetJSONValueFrom<Integer>('id_usuario', Value, FJSON);
end;

procedure Tusuarios_claims.SetNomeUsuario(const Value: String);
begin
  TJSONUtils.SetJSONValueFrom<String>('nome_usuario', Value, FJSON);
end;

procedure Tusuarios_claims.SetRegras(
  const Value: String);
begin
  TJSONUtils.SetJSONValueFrom<String>('regras', Value, FJSON);
end;

end.
