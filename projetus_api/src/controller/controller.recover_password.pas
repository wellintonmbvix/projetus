unit controller.recover_password;

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

  model.api.message,

  controller.dto.recover_password.interfaces,
  controller.dto.recover_password.interfaces.impl,

  Horse.GBSwagger.Register,
  Horse.GBSwagger.controller,
  GBSwagger.Path.Attributes;

type

  [SwagPath('v1', 'Recover Password')]
  TControllerRecoverPassword = class(THorseGBSwagger)
    class procedure Registry;

    [SwagGet('usuarios', 'Realiza login na API')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Not Found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerRecoverPassword }

class procedure TControllerRecoverPassword.Get(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  userName, email: String;
begin
  userName := Req.Query['username'];
  if userName.Trim.Length = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'username not found');
      Res.Send<TJSONObject>(oJson).Status(400);
      Exit;
    end;

  try
    var IRecoverPassword := TIRecoverPassword.New;

    if IRecoverPassword.Manufacture.GetEmailByUserName(userName, email) then
      begin
        // Implementar rotina para enviar para o e-mail retornado
        // um código temporário para que de posse deste código,
        // seja informado por outra rota este número e a nova senha
        // para ser validado o código e aí sim alterar a senha do usuário
        // em banco
      end
    else
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('message','username or email not found');
        Res.Send<TJSONObject>(oJson).Status(404);
      end;
  except
    on E: Exception do
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('message', E.Message);
        Res.Send<TJSONObject>(oJson).Status(500);
      end;
  end;
end;

class procedure TControllerRecoverPassword.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
      .Get('/recover-password', Get);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerRecoverPassword)

end.
