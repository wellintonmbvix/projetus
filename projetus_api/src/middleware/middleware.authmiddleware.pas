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
      Token, PayloadBase64, PayloadJSON: string;
      JWTParts: TArray<string>;
      JSONObj: TJSONObject;
      NomeRegra: string;
      Regra: string;
      Permitido: Boolean;
    begin
      try
        // Extrai o token do header Authorization
        Token := Req.Headers['Authorization'].Replace('Bearer ', '', [rfIgnoreCase]);

        // Divide o token em 3 partes: Header.Payload.Signature
        JWTParts := Token.Split(['.']);
        if Length(JWTParts) <> 3 then
          raise Exception.Create('Token malformado');

        // Decodifica a parte do payload (segunda parte)
        PayloadBase64 := JWTParts[1];
        PayloadJSON := TNetEncoding.Base64URL.Decode(PayloadBase64);

        // Converte string JSON em objeto
        JSONObj := TJSONObject.ParseJSONValue(PayloadJSON) as TJSONObject;
        try
          if not Assigned(JSONObj) then
            raise Exception.Create('Payload inválido');

          if not JSONObj.TryGetValue<string>('nome_regra', NomeRegra) then
            raise Exception.Create('Campo "nome_regra" não encontrado no token');

          // Valida a regra
          Permitido := False;
          for Regra in RegrasPermitidas do
            if SameText(NomeRegra, Regra) then
            begin
              Permitido := True;
              Break;
            end;

          if Permitido then
            Next()
          else
            begin
              Res.Send<TJSONObject>(
                TJSONObject.Create.AddPair('error', 'Regra não autorizada')
              ).Status(403);
              raise EAccessDenied.Create('Acesso negado para a regra atual');
            end;

        finally
          JSONObj.Free;
        end;

      except
        on E: Exception do
          begin
            Res.Send<TJSONObject>(
              TJSONObject.Create.AddPair('error', 'Erro ao validar token: ' + E.Message)
            ).Status(401);
            raise;
          end;
      end;
    end;
end;

end.
