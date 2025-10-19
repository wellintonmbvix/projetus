unit middleware.authmiddleware;

interface

uses
  Horse, System.SysUtils, System.Classes, System.JSON, System.NetEncoding;

  function MiddlewarePorRegras(const RegrasPermitidas: TArray<string>): THorseCallback;

implementation

type
  EAccessDenied = class(Exception);

function MiddlewarePorRegras(const RegrasPermitidas: TArray<string>): THorseCallback;
begin
  Result :=
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LClaims: TUsuarioClaims;
      Permissao: Boolean;
      Regra: string;
    begin
      try
        LClaims := Req.Session<TUsuarioClaims>;
        if not Assigned(LClaims) then
        begin
          Res.Status(401).Send<TJSONObject>(
            TJSONObject.Create.AddPair('error', 'Token inválido ou não informado'));
          raise EAccessDenied.Create('Token inválido ou não informado');
        end;

        Permissao := False;
        for Regra in RegrasPermitidas do
          if SameText(LClaims.nome_regra, Regra) then
          begin
            Permissao := True;
            Break;
          end;

        if Permissao then
          Next()
        else
        begin
          Res.Status(403).Send<TJSONObject>(
            TJSONObject.Create.AddPair('error', 'Acesso negado para a regra atual'));
          raise EAccessDenied.Create('Acesso negado para a regra atual');
        end;
      except
        on E: EAccessDenied do
          ; // apenas interrompe o fluxo, resposta já enviada
        on E: Exception do
        begin
          Res.Status(500).Send<TJSONObject>(
            TJSONObject.Create.AddPair('error', 'Erro interno: ' + E.Message));
          raise; // relança exceção para o Horse lidar
        end;
      end;
    end;
end;

end.
