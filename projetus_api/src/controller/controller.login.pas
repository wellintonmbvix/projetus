unit controller.login;

interface

uses
  Horse,
  Horse.Commons,
  Horse.Jhonson,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  System.StrUtils,
  System.Math,
  Data.DB,
  DBClient,
  DateUtils,
  JOSE.Core.JWT,
  JOSE.Core.Builder,

  BCrypt,
  BCrypt.Types,

  Horse.GBSwagger.Register,
  Horse.GBSwagger.Controller,
  GBSwagger.Path.Attributes,

  model.api.message,
  model.usuarios,
  model.usuario.claims,

  controller.dto.usuarios.interfaces,
  controller.dto.usuarios.interfaces.impl;

type
  [SwagPath('v1', 'Login')]
  TControllerLogin = class(THorseGBSwagger)
    class procedure Registry;

    [SwagPost('usuarios', 'Realiza login na API')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

const
  C_SECRET_JWT = 'SuaSenhaMaisFraca@2025';

implementation

{ TControllerLogin }

class procedure TControllerLogin.Post(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  oJson: TJSONObject;
  passwordRehashNeeded: Boolean;
  Usuarios: TObjectList<Tusuarios>;
  filter: String;
  LToken: TJWT;
  LExpiration: TDateTime;
  LCompactToken: String;
  LIdUsuario: Integer;
  LClaims: TUsuarioClaims;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('user data not found');

  oJson := Req.Body<TJSONObject>;
  if (oJson.GetValue<String>('nome_usuario').IsEmpty) Or
  (oJson.GetValue<String>('senha_usuario').IsEmpty) then
    begin
      oJson.SetPairs(TList<TJSONPair>.Create);
      oJson.AddPair('message', 'O nome e senha do usuário são campos obrigatório!');
      Res.Send<TJSONObject>(oJson).Status(400);
      Exit;
    end;

  filter := 'dt_del is null AND nome_usuario='+
    QuotedStr(oJson.GetValue<String>('nome_usuario'));
  var
  IUsuario := TIUsuario.New;
  IUsuario.Build.ListAll(filter, Usuarios, '');

  if Usuarios.Count = 0 then
    begin
      oJson.SetPairs(TList<TJSONPair>.Create);
      oJson.AddPair('message', 'Invalid username or password');
      Res.Send<TJSONObject>(oJson).Status(400);
    end
  else
    begin
      var isPasswordValid := TBCrypt.CompareHash(
      oJson.GetValue<String>('senha_usuario'), Usuarios.Last.senha_hash);

      if not isPasswordValid then // Se senha é ou não válida
        begin
          oJson.SetPairs(TList<TJSONPair>.Create);
          oJson.AddPair('mesage', 'invalid username or password');
          Res.Send<TJSONObject>(oJson).Status(400);
        end
      else
        begin
          try
            LToken := TJWT.Create(TUsuarioClaims);
            LClaims := TUsuarioClaims(LToken.Claims);
            LClaims.Issuer := 'Wellinton Mattos Brozeghini';
            LClaims.id_usuario := Usuarios.Last.id_usuario;
            LClaims.nome_usuario := Usuarios.Last.nome_usuario;
            LClaims.id_regra := Usuarios.Last.usuarios_regras.Last.id_regra;
            LClaims.nome_regra := Usuarios.Last.usuarios_regras.Last.regra;
            LExpiration := IncMinute(Now, 60);
            LClaims.Expiration := LExpiration;
            LCompactToken := TJOSE.SHA256CompactToken(C_SECRET_JWT, LToken);

            oJson.SetPairs(TList<TJSONPair>.Create);
            oJson.AddPair('Expiration', FormatDateTime('DD/MM/YYYY hh:mm:ss.nnn', LExpiration));
            oJson.AddPair('Token', LCompactToken);
            Res.Send<TJSONObject>(oJson).Status(200);
          finally
           LToken.Free;
          end;
        end;

    end;
end;

class procedure TControllerLogin.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
      .Post('/login', Post);
end;

end.
