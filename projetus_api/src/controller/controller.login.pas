unit controller.login;

interface

uses
  Horse,
  Horse.Commons,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  System.StrUtils,
  System.Math,
  Data.DB,
  DBClient,

  BCrypt,
  BCrypt.Types,

  Horse.GBSwagger.Register,
  Horse.GBSwagger.Controller,
  GBSwagger.Path.Attributes,

  model.api.message,
  model.usuarios,

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

implementation

{ TControllerLogin }

class procedure TControllerLogin.Post(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  oJson: TJSONObject;
  passwordRehashNeeded: Boolean;
  Usuarios: TObjectList<Tusuarios>;
  filter: String;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('user data not found');

  oJson := Req.Body<TJSONObject>;
  if (oJson.GetValue<String>('nome_usuario').IsEmpty) Or
  (oJson.GetValue<String>('senha_usuario').IsEmpty) then
    begin
      oJson.SetPairs(TList<TJSONPair>.Create);
      oJson.AddPair('message', 'O nome e senha do usu�rio s�o campos obrigat�rio!');
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

      if not isPasswordValid then // Se senha � ou n�o v�lida
        begin
          oJson.SetPairs(TList<TJSONPair>.Create);
          oJson.AddPair('mesage', 'invalid username or password');
          Res.Send<TJSONObject>(oJson).Status(400);
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
  THorse
    .Group
      .Prefix('api/v1')
      .Post('/login', Post);
end;

end.
