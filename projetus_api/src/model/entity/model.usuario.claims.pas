unit model.usuario.claims;

interface

uses
  System.StrUtils,
  System.SysUtils,
  System.Classes,

  JOSE.Core.JWT,
  JOSE.Types.JSON;

type
  TUsuarioClaims = class(TJWTClaims)
    private
    function GetIdRegra: Integer;
    function GetIdUsuario: Integer;
    function GetNomeUsuario: String;
    procedure SetIdRegra(const Value: Integer);
    procedure SetIdUsuario(const Value: Integer);
    procedure SetNomeUsuario(const Value: String);

    public
      property id_usuario: Integer read GetIdUsuario write SetIdUsuario;
      property nome_usuario: String read GetNomeUsuario write SetNomeUsuario;
      property id_regra: Integer read GetIdRegra write SetIdRegra;
  end;

implementation

{ TUsuarioClaims }

function TUsuarioClaims.GetIdRegra: Integer;
begin
  Result := TJSONUtils.GetJSONValueInt('id_regra', FJSON).AsInteger;
end;

function TUsuarioClaims.GetIdUsuario: Integer;
begin
  Result := TJSONUtils.GetJSONValueInt('id_usuario', FJSON).AsInteger;
end;

function TUsuarioClaims.GetNomeUsuario: String;
begin
  Result := TJSONUtils.GetJSONValueInt('nome_usuario', FJSON).AsString;
end;

procedure TUsuarioClaims.SetIdRegra(const Value: Integer);
begin
  TJSONUtils.SetJSONValueFrom<integer>('id_regra', Value, FJSON);
end;

procedure TUsuarioClaims.SetIdUsuario(const Value: Integer);
begin
  TJSONUtils.SetJSONValueFrom<integer>('id_usuario', Value, FJSON);
end;

procedure TUsuarioClaims.SetNomeUsuario(const Value: String);
begin
  TJSONUtils.SetJSONValueFrom<string>('nome_usuario', Value, FJSON);
end;

end.
