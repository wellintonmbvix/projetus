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
  System.NetEncoding,
  
  Data.DB,
  DBClient,
  DateUtils,
  JOSE.Core.Base,
  JOSE.Core.JWT,
  JOSE.Core.Builder,
  JOSE.Types.JSON,

  Mail4Delphi,

  BCrypt,
  BCrypt.Types,  

  model.api.message,
  model.configuracao_email,
  model.usuarios,

  model.service.scripts.interfaces,
  model.service.scripts.interfaces.impl,

  controller.dto.recover_password.interfaces,
  controller.dto.recover_password.interfaces.impl,

  controller.dto.recover_password_code.interfaces,
  controller.dto.recover_password_code.interfaces.impl,

  controller.dto.usuarios.interfaces,
  controller.dto.usuarios.interfaces.impl,  

  Horse.GBSwagger.Register,
  Horse.GBSwagger.controller,
  GBSwagger.Path.Attributes;

type
  Trecoverpassword = class
    private
      Fusername: String;
    public

      [SwagRequired]
      [SwagProp('user_name', 'Nome do usuário', True, False)]
      [SwagString(50, 3)]
      property username: String read Fusername write Fusername;
  end;

type
  Tvalidatecode = class
    private
      Fcode: String;
      Fusername: String;
    public
      [SwagIgnore]
      property username: String read Fusername write Fusername;

      [SwagProp('code', 'Código de validação', True, False)]
      [SwagString(4, 4)]
      property code: String read Fcode write Fcode;
  end;

type
  Tchangepassword = class
    private
      Fpassword: String;
    public
      property password: String read Fpassword write Fpassword;
  end;

type
  TRecoverPassClaims = class(TJWTClaims)
    private
    function GetExpiration: TDateTime;
    procedure SetExpiration(const Value: TDateTime);
    function GetUsername: String;
    procedure SetUsername(const Value: String);

    public
      property expiration: TDateTime read GetExpiration write SetExpiration;
      property username: String read GetUsername write SetUsername;
  end;

type

  [SwagPath('v1', 'Recover Password')]
  TControllerRecoverPassword = class(THorseGBSwagger)
    class procedure Registry;

    [SwagPost('recover-password', 'Retorna código para recuperação de senha')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Not Found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Trecoverpassword)]
    class procedure ReturnCode(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('recover-password/validate-code', 'Valida o código retornado pela rota "recover-password"')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Not Found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Tvalidatecode)]
    class procedure ValidateCode(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('recover-password/change-password', 'Altera a senha do usuário do token retornado na rota "validate-code"')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Not Found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Tchangepassword)]
    class procedure ChangePassword(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

const
  C_SECRET_JWT = 'SuaSenhaMaisFraca@2025';

implementation

{ TControllerRecoverPassword }

class procedure TControllerRecoverPassword.ReturnCode(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
function GerarCodigoAlfanumerico4: string;
const
  LETRAS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  NUMEROS = '0123456789';
  TODOS = LETRAS + NUMEROS;
var
  I, PosNumero: Integer;
begin
  Result := '';
  Randomize;

  // Define aleatoriamente a posição que terá obrigatoriamente um número (1 a 4)
  PosNumero := Random(4) + 1;

  for I := 1 to 4 do
  begin
    if I = PosNumero then
      Result := Result + NUMEROS[Random(Length(NUMEROS)) + 1]
    else
      Result := Result + TODOS[Random(Length(TODOS)) + 1];
  end;
end;

function MaskEmail(const Email: string): string;
var
  LocalPart, DomainPart: string;
  AtPos, DotPos: Integer;
  I: Integer;
  MaskedLocal, MaskedDomain: string;
  SpecialChars: set of Char;
begin
  Result := Email;

  SpecialChars := ['-', '_', '.'];

  AtPos := Pos('@', Email);

  if AtPos <= 1 then
    Exit; // Email inválido

  LocalPart := Copy(Email, 1, AtPos - 1);
  DomainPart := Copy(Email, AtPos + 1, Length(Email) - AtPos);

  MaskedLocal := '';
  for I := 1 to Length(LocalPart) do
  begin
    if I = 1 then
      MaskedLocal := MaskedLocal + LocalPart[I]
    else if CharInSet(LocalPart[I], SpecialChars) then
      MaskedLocal := MaskedLocal + LocalPart[I]
    else if (I > 1) and CharInSet(LocalPart[I - 1], SpecialChars) then
      MaskedLocal := MaskedLocal + LocalPart[I]
    else
      MaskedLocal := MaskedLocal + '*';
  end;

  DotPos := Pos('.', DomainPart);

  if DotPos > 0 then
  begin
    MaskedDomain := '';

    for I := 1 to DotPos - 1 do
    begin
      if CharInSet(DomainPart[I], SpecialChars) then
        MaskedDomain := MaskedDomain + DomainPart[I]
      else if (I > 1) and CharInSet(DomainPart[I - 1], SpecialChars) then
        MaskedDomain := MaskedDomain + DomainPart[I]
      else
        MaskedDomain := MaskedDomain + '*';
    end;

    MaskedDomain := MaskedDomain + Copy(DomainPart, DotPos, Length(DomainPart) - DotPos + 1);
  end
  else
    MaskedDomain := DomainPart; // Se não houver ponto, mantém o domínio original

  Result := MaskedLocal + '@' + MaskedDomain;
end;

var
  userName, email, code: String;
  oJson: TJSONObject;
  bodyHtml: TStringBuilder;
begin
  oJson := Req.Body<TJSONObject>;
  if Req.Body.IsEmpty then
    begin
       oJson.AddPair('message', 'username not found');
      Res.Send<TJSONObject>(oJson).Status(400);
      Exit;
    end;

  try
    try
      userName := oJson.GetValue<String>('username');
      var IRecoverPassword := TIRecoverPassword.New;

      if IRecoverPassword.Manufacture.GetEmailByUserName(userName, email) then
        begin
          var IServiceScripts := TServiceScripts.New;
          var configEmail := TconfiguracaoEmail.Create;
          var IRecoverPasswordCodes := TIRecoverPasswordCodes.New;
          try
            bodyHtml := TStringBuilder.Create;
            if IServiceScripts.GetConfigEmail('smtp.gmail.com', configEmail) then
              begin
                try
                  code := GerarCodigoAlfanumerico4;
                  bodyHtml.Append('<!DOCTYPE html>')
                          .Append('<html lang="pt-BR">')
                          .Append('<head>')
                          .Append('  <meta charset="UTF-8">')
                          .Append('  <meta name="viewport" content="width=device-width, initial-scale=1.0">')
                          .Append('  <title>Recuperação de Senha</title>')
                          .Append('</head>')
                          .Append('<body>')
                          .Append('  <p>Prezado(a) <strong>' + userName + '</strong>,</p>')
                          .Append('  <p>Recebemos sua solicitação de recuperação de senha. Para continuar com o processo, por favor, utilize o código de validação abaixo no nosso aplicativo mobile:</p>')
                          .Append('  <p><strong>Código de Validação: ' + code + '</strong></p>')
                          .Append('  <p>Este código é necessário para confirmar sua identidade e permitir a recuperação da sua senha. Lembre-se de inseri-lo diretamente no aplicativo na seção de recuperação de senha.</p>')
                          .Append('  <p>Caso não tenha solicitado essa recuperação de senha, por favor, desconsidere esta mensagem.</p>')
                          .Append('  <p>Se precisar de ajuda adicional, nossa equipe de suporte está à disposição para assisti-lo.</p>')
                          .Append('  <p>Atenciosamente, <br>')
                          .Append('  <strong>Equipe Projetus</strong></p>')
                          .Append('</body>')
                          .Append('</html>');

                  TMail.New
                      .From(configEmail.userName, 'Projetus')
                      .SSL(configEmail.criptografiaSSL)
                      .Host(configEmail.host)
                      .Port(configEmail.port)
                      .Auth(configEmail.requerAutenticacao)
                      .UserName(configEmail.userName)
                      .Password(configEmail.password)
                      .ReceiptRecipient(configEmail.confirmarRecebimento)
                      .AddTo(email, email)
                      // .AddCC('cc', 'name')
                      // .AddBCC('cco', 'name')
                      .Subject('Recuperação de Senha - Código de Validação')
                      .AddBody(bodyHtml.ToString)
                      // .AddAttachment('path filename')
                      .ContentType('text/html')
                      .SendMail;

                  IRecoverPasswordCodes
                      .code(code)
                      .username(userName)
                      .date_expiration(IncMinute(Now(), 1))
                    .Build.Insert;

                  oJson := TJSONObject.Create;
                  oJson.AddPair('message', 'Um código de recuperação foi enviado para: ' +
                  MaskEmail(email) + ', este código tem a validade de 60s.');
                  Res.Send<TJSONObject>(oJson).Status(200);
                except
                  on E: Exception do
                    begin
                      oJson := TJSONObject.Create;
                      oJson.AddPair('message','Failed to send email to ' +
                        QuotedStr(email) + '.' + #13 + E.Message);
                      Res.Send<TJSONObject>(oJson).Status(500);
                    end;
                end;
              end
            else
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'Config not existent of email');
                Res.Send<TJSONObject>(oJson).Status(500);
              end;
          finally
            bodyHtml.Free;
            FreeAndNil(configEmail);
          end;
        end
      else
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message','username or email not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end;
    except
      on E: Exception do
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', E.Message);
          Res.Send<TJSONObject>(oJson).Status(500);
        end;
    end;
  finally
//    oJson.Free;
  end;
end;

class procedure TControllerRecoverPassword.ValidateCode(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  code,username, Token, msg: String;
  LToken: TJWT;
  LClaims: TRecoverPassClaims;
  LExpiration: TDateTime;
begin
  oJson := Req.Body<TJSONObject>;
  if Req.Body.IsEmpty then
    begin
       oJson.AddPair('message', 'code not found');
      Res.Send<TJSONObject>(oJson).Status(400);
      Exit;
    end;

  code := oJson.GetValue('code').ToString;
  username := oJson.GetValue('username').ToString;

  try
    oJson := TJSONObject.Create;
    if TIRecoverPassword.New.Manufacture.ValidateCode(code,username, msg) then
      begin
        LToken := TJWT.Create(TRecoverPassClaims);
        LClaims := TRecoverPassClaims(LToken.Claims);
        LExpiration := IncMinute(now(), 60); // Voltar o incremento de 1 minuto
        LClaims.username := username;
        LClaims.expiration := LExpiration;
        Token := TJOSE.SHA256CompactToken(C_SECRET_JWT, LToken);
        oJson.SetPairs(TList<TJSONPair>.Create);
        oJson.AddPair('Expiration', FormatDateTime('DD/MM/YYYY hh:mm:ss.nnn', LExpiration));
        oJson.AddPair('Token', Token);
        Res.Send<TJSONObject>(oJson).Status(200);
      end
    else
      begin
        oJson.AddPair('message', msg);
        Res.Send<TJSONObject>(oJson).Status(401);
      end;

  except
    on E: Exception do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('message', E.Message);
        Res.Send<TJSONObject>(oJson).Status(500);
      end;
  end;
end;

class procedure TControllerRecoverPassword.ChangePassword(Req: THorseRequest;
 Res: THorseResponse; Next: TProc);
function DecodeBase64URL(const Input: string): string;
var
  Base64: string;
  Bytes: TBytes;
begin
  // Converte Base64URL para Base64 padrão
  Base64 := StringReplace(Input, '-', '+', [rfReplaceAll]);
  Base64 := StringReplace(Base64, '_', '/', [rfReplaceAll]);
  
  // Adiciona padding se necessário
  case Length(Base64) mod 4 of
    2: Base64 := Base64 + '==';
    3: Base64 := Base64 + '=';
  end;
  
  // Decodifica Base64
  Bytes := TNetEncoding.Base64.DecodeStringToBytes(Base64);
  Result := TEncoding.UTF8.GetString(Bytes);
end;

function DecodeJWT(const Token: string): TJSONObject;
var
  Parts: TArray<string>;
  PayloadJSON: string;
begin
  Result := nil;
  
  try
    // Divide o token em suas três partes
    Parts := Token.Split(['.']);
    
    if Length(Parts) <> 3 then
      raise Exception.Create('Token JWT inválido');
    
    // Decodifica o payload (segunda parte)
    PayloadJSON := DecodeBase64URL(Parts[1]);
    
    // Converte para objeto JSON
    Result := TJSONObject.ParseJSONValue(PayloadJSON) as TJSONObject;
    
  except
    on E: Exception do
    begin
      if Assigned(Result) then
        Result.Free;
      Result := nil;
      raise Exception.Create('Erro ao decodificar JWT: ' + E.Message);
    end;
  end;
end;

function GetExpiration(const Token: string): Int64;
var
  Payload: TJSONObject;
  ExpirationValue: TJSONValue;
begin
  Result := 0;
  Payload := DecodeJWT(Token);
  
  try
    if Assigned(Payload) then
    begin
      ExpirationValue := Payload.GetValue('expiration');
      if Assigned(ExpirationValue) then
        Result := ExpirationValue.AsType<Int64>;
    end;
  finally
    if Assigned(Payload) then
      Payload.Free;
  end;
end;

function GetUserName(const Token: string): String;
var
  Payload: TJSONObject;
  UsernameValue: TJSONValue;  
begin
  Result := '';
  Payload := DecodeJWT(Token);

  try
    if Assigned(Payload) then
      UsernameValue := Payload.GetValue('username');
      if Assigned(UsernameValue) then
        Result := UsernameValue.AsType<string>.Replace('"','');
  finally
    if Assigned(Payload) then
      Payload.Free;
  end;
end;

function IsTokenValid(const Token: string; MinutesThreshold: Integer = 1): Boolean;
var
  Payload: TJSONObject;
  ExpirationTime: Int64;
  CurrentTime: Int64;
  DiffInSeconds: Int64;
begin
  Result := False;
  Payload := DecodeJWT(Token);
  
  try
    if not Assigned(Payload) then
      Exit;
    
    // Pega o tempo de expiração
    ExpirationTime := GetExpiration(Token);
    
    if ExpirationTime = 0 then
      Exit;
    
    // Tempo atual em Unix timestamp (segundos desde 1970)
    CurrentTime := DateTimeToUnix(Now, False);
    
    // Calcula a diferença em segundos
    DiffInSeconds := ExpirationTime - CurrentTime;
    
    // Verifica se tem mais que o threshold especificado (padrão: 1 minuto = 60 segundos)
    Result := DiffInSeconds > (MinutesThreshold * 60);
    
  finally
    if Assigned(Payload) then
      Payload.Free;
  end;
end;

var
  oJson: TJSONObject;
  LToken: TJWT;
  AuthHeader: string;
  BearerToken: string;
  username: string;
  senhaHash: string;
  Payload: TJSONObject;
  IsValid: Boolean;
  Expiration: Int64;  
  ExpDate: TDateTime;
  Usuario: Tusuarios;
  Usuarios: TObjectList<Tusuarios>;
begin
  AuthHeader := Req.Headers.Field('Authorization').AsString;
  if (AuthHeader <> '') and (Pos('Bearer ', AuthHeader) = 1) then
    begin
      BearerToken := Copy(AuthHeader, 8, Length(AuthHeader) - 7);
      LToken := TJOSE.Verify(C_SECRET_JWT	, BearerToken);
      try
        if not Assigned(LToken) then
          begin
            oJson := TJSONObject.Create;
            oJson.AddPair('error', 'Erro ao verificar o Token!');
            Res.Send<TJSONObject>(oJson).Status(401);
            Exit;
          end;

        if not LToken.Verified then
          begin
            oJson := TJSONObject.Create;
            oJson.AddPair('error', 'Assinatura do Token Inválida ou Token Alterado!');
            Res.Send<TJSONObject>(oJson).Status(401);
            Exit;
          end;

        try
          Payload := DecodeJWT(BearerToken);
          Expiration := GetExpiration(BearerToken);
          IsValid := IsTokenValid(BearerToken);

          if not IsValid then
            begin
              oJson := TJSONObject.Create;
              oJson.AddPair('error', 'Token expirado!');
              Res.Send<TJSONObject>(oJson).Status(401);
              Exit;
            end
          else
            begin
              oJson := Req.Body<TJSONObject>;
              username := GetUserName(BearerToken);
              senhaHash := TBCrypt
                .GenerateHash(oJson.GetValue<String>('password'), 10);

              var
              IUsuario := TIUsuario.New;
              Usuario := IUsuario.Build.ListByGuid('nome_usuario',
                username, Usuarios).This;
              IUsuario.Build.Modify(Usuario);
              Usuario.senha_hash := senhaHash;
              Usuario.dt_alt := now();
              IUsuario.Build.Update;
              
              oJson := TJSONObject.Create;
              oJson.AddPair('message', 'password changed successfull!');
              Res.Send<TJSONObject>(oJson).Status(200);              
            end;
        except
          on E: Exception do
            begin
              oJson := TJSONObject.Create;
              oJson.AddPair('error', e.Message);
              Res.Send<TJSONObject>(oJson).Status(500);
            end;
        end;
      finally
        LToken.Free;
      end;
    end
  else
    begin
      oJson := TJSONObject.Create;
      oJson.AddPair('error', 'Bearer token não encontrado');
      Res.Send<TJSONObject>(oJson).Status(401);
    end;
end;

class procedure TControllerRecoverPassword.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
      .Post('/recover-password', ReturnCode)
      .Post('/recover-password/validate-code', ValidateCode)
      .Post('/recover-password/change-password', ChangePassword);
end;

{ TRecoverPassClaims }

function TRecoverPassClaims.GetExpiration: TDateTime;
begin
  Result := StrToDateTime(TJSONUtils.GetJSONValue('expiration', FJSON).AsString);
end;

function TRecoverPassClaims.GetUsername: String;
begin
  Result := TJSONUtils.GetJSONValue('username', FJSON).AsString;
end;

procedure TRecoverPassClaims.SetExpiration(const Value: TDateTime);
begin
  TJSONUtils.SetJSONValueFrom<TDateTime>('expiration', Value, FJSON);
end;

procedure TRecoverPassClaims.SetUsername(const Value: String);
begin
  TJSONUtils.SetJSONValueFrom<string>('username', Value, FJSON);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerRecoverPassword)

end.
