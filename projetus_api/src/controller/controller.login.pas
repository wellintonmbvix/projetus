unit controller.login;

interface

uses
  Horse,
  Horse.Commons,
  Horse.JWT,

  JOSE.Core.JWT,
  JOSE.Core.Builder,

  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  System.StrUtils,
  System.Math,
  System.DateUtils,

  Data.DB,
  DBClient,

  BCrypt,
  BCrypt.Types,

  Horse.GBSwagger.Register,
  Horse.GBSwagger.controller,
  GBSwagger.Path.Attributes,

  model.api.message,
  model.usuarios,

  controller.dto.usuarios.interfaces,
  controller.dto.usuarios.interfaces.impl;

type
  [SwagPath('v1', 'Login')]
  TControllerLogin = class(THorseGBSwagger)
  private
    function CriarToken(usuario: Tusuarios): String;
  public
    class procedure Registry;

    [SwagPost('login', 'Realiza login na API')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(401, TAPIMessage, 'Unauthorized')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

const JWTPassword = 'suaSenhaMaisFraca';

implementation

{ TControllerLogin }

function TControllerLogin.CriarToken(usuario: Tusuarios): String;
var
  LJWT: TJWT;
  LToken: String;
begin
  LJWT := TJWT.Create();
  Try
    LJWT.Claims.Expiration := IncHour(Now, 1);
    LJWT.Claims.JWTId := usuario.id_usuario.ToString();
    LToken := TJOSE.SHA256CompactToken(JWTPassword, LJWT);
  Finally
    FreeAndNil(LJWT);
  End;

  Result := LToken;
end;

class procedure TControllerLogin.Post(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  oJson: TJSONObject;
  passwordRehashNeeded: Boolean;
  usuarios: TObjectList<Tusuarios>;
  filter: String;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('user data not found');

  oJson := Req.Body<TJSONObject>;
  if (oJson.GetValue<String>('nome_usuario').IsEmpty) Or
    (oJson.GetValue<String>('senha_usuario').IsEmpty) then
  begin
    oJson.SetPairs(TList<TJSONPair>.Create);
    oJson.AddPair('message',
      'O nome e senha do usuário são campos obrigatório!');
    Res.Send<TJSONObject>(oJson).Status(401);
    Exit;
  end;

  filter := 'dt_del is null AND nome_usuario=' +
    QuotedStr(oJson.GetValue<String>('nome_usuario'));
  var
  IUsuario := TIUsuario.New;
  IUsuario.Build.ListAll(filter, usuarios, '');

  if usuarios.Count = 0 then
  begin
    oJson.SetPairs(TList<TJSONPair>.Create);
    oJson.AddPair('message', 'Invalid username or password');
    Res.Send<TJSONObject>(oJson).Status(401);
  end
  else
  begin
    var
    isPasswordValid := TBCrypt.CompareHash
      (oJson.GetValue<String>('senha_usuario'), usuarios.Last.senha_hash);

    if not isPasswordValid then // Se senha é ou não válida
    begin
      oJson.SetPairs(TList<TJSONPair>.Create);
      oJson.AddPair('mesage', 'invalid username or password');
      Res.Send<TJSONObject>(oJson).Status(401);
    end
    else
    begin
      oJson.SetPairs(TList<TJSONPair>.Create);
      oJson.AddPair('mesage', 'user is valid');
      Res.Send<TJSONObject>(oJson).Status(200);
    end;

  end;
end;

class procedure TControllerLogin.Registry;
begin
  THorse.Group.Prefix('api/v1').Post('/login', Post);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerLogin)

end.
