unit controller.usuarios;

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

  model.usuarios,
  model.usuarios_regras,
  model.api.message,
  controller.dto.usuarios.interfaces,
  controller.dto.usuarios.interfaces.impl;

type
  [SwagPath('v1', 'Usuários')]
  TControllerUsuarios = class(THorseGBSwagger)
    class procedure Registry;

    [SwagGet('usuarios', 'Retorna listagem de usuários')]
    [SwagResponse(200, Tusuarios, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamQuery('nome', 'Nome do usuário', False, False)]
    [SwagParamQuery('id_pessoa', 'Id da pessoa', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('usuarios/:id', 'Retorna dados de um usuário')]
    [SwagResponse(200, Tusuarios, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'User not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('usuarios', 'Registra um novo usuário')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Tusuarios)]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('usuarios/:id', 'Atualiza dados de um usuário')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'User not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('usuarios/:id/delete', 'Apaga registro de um usuário')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'User not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerUsuarios }

class procedure TControllerUsuarios.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'id service not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IUsuario := TIUsuario.New;
  var
  Usuario: Tusuarios;

  Usuario := IUsuario.Build.ListById('id_usuario', id, Usuario).This;

  if Usuario = nil then
    begin
      oJson.AddPair('error', 'user not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if Usuario.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'record has already been deleted');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IUsuario.Build.Modify(Usuario);
  Usuario.dt_del := now();
  IUsuario.Build.Update;

  oJson.AddPair('message', 'successfully service deleted');
  Res.Send<TJSONObject>(oJson).Status(200);
end;

class procedure TControllerUsuarios.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  Usuarios: TObjectList<Tusuarios>;
  Usuario: Tusuarios;
  UsuarioRegra: Tusuarios_regras;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,id_pessoa,page,perPage,filter,records: String;
  totalPages: Integer;
begin
  Try
    var
    IUsuario := TIUsuario.New;
    nome := Req.Query['nome'];
    id_pessoa := Req.Query['id_pessoa'];
    page := Req.Query['page'];
    perPage := Req.Query['perPage'];

    filter := 'dt_del is null';
    if nome <> EmptyStr then
      filter := filter + ' AND nome LIKE '+QuotedStr('%'+nome+'%');

    if id_pessoa <> EmptyStr then
      filter := filter + ' AND id_pessoa='+id_pessoa;

    if page = EmptyStr then
      page := '1';

    if perPage = EmptyStr then
      perPage := '10';

    var registros: Integer;
    IUsuario.Build.GetRecordsNumber('usuarios', filter, registros);
    totalPages := Ceil(registros / perPage.ToInteger());
    records := IntToStr(registros);

    IUsuario.Build.ListPaginate(filter, Usuarios, 'id_usuario',
      StrToInt(perPage), (StrToInt(perPage) * (StrToInt(page) - 1)));

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for Usuario in Usuarios do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id', Usuario.id_usuario.ToString);
        oJson.AddPair('nome_usuario', Usuario.nome_usuario);

        for UsuarioRegra In Usuario.usuarios_regras do
          begin
            var aUsuarioRegras := TJSONArray.Create;
            var oUsuarioRegra := TJSONObject.Create;
            oUsuarioRegra.AddPair('id_regra', TJSONNumber.Create(UsuarioRegra.id_regra));
            oUsuarioRegra.AddPair('regra', TJSONString.Create(UsuarioRegra.regra));

            aUsuarioRegras.AddElement(oUsuarioRegra);
            oJson.AddPair('regras', aUsuarioRegras);
          end;

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Usuario.dt_inc));
        if Usuario.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Usuario.dt_alt.Value))
        else
          oJson.AddPair('alterado_em', TJSONNull.Create);

       aJson.AddElement(oJson);
      end;

    oJsonResult.AddPair('data', aJson);
    oJsonResult.AddPair('records', records);
    oJsonResult.AddPair('page', page);
    oJsonResult.AddPair('totalPages', TJSONNumber.Create(totalPages));
    Res.Send<TJSONObject>(oJsonResult);
  Except
    on E: Exception do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('error', E.message);
        Res.Send<TJSONObject>(oJson);
      end;
  End;
end;

class procedure TControllerUsuarios.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
  UsuarioRegra: Tusuarios_regras;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'id user not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IUsuario := TIUsuario.New;
  var
  Usuario: Tusuarios;

  IUsuario.Build.ListById('id_usuario', id, Usuario);
  if Usuario = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'user not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    begin
      if Usuario.dt_del.HasValue then
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('message', 'user not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end
      else
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('id', Usuario.id_usuario.ToString);
          oJson.AddPair('nome_usuario', Usuario.nome_usuario);

          for UsuarioRegra In Usuario.usuarios_regras do
            begin
              var aUsuarioRegras := TJSONArray.Create;
              var oUsuarioRegra := TJSONObject.Create;
              oUsuarioRegra.AddPair('id_regra',
                TJSONNumber.Create(UsuarioRegra.id_regra));
              oUsuarioRegra.AddPair('regra',
                TJSONString.Create(UsuarioRegra.regra));

              aUsuarioRegras.AddElement(oUsuarioRegra);
              oJson.AddPair('regras', aUsuarioRegras);
            end;


          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Usuario.dt_inc));
          if Usuario.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Usuario.dt_alt.Value))
          else
            oJson.AddPair('alterado_em', TJSONNull.Create);

          Res.Send<TJSONObject>(oJson).Status(200);
        end;
    end;
end;

class procedure TControllerUsuarios.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  senhaHash, filter: String;
  usuarioRegrasArray: TJSONArray;
  UsuarioRegra: Tusuarios_regras;
  UsuariosRegras: TObjectList<Tusuarios_regras>;
  Usuarios: TObjectList<Tusuarios>;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('user data not found');

  oJson := Req.Body<TJSONObject>;
  if (oJson.GetValue<String>('nome_usuario').IsEmpty) Or
  (oJson.GetValue<String>('senha_usuario').IsEmpty) then
    begin
      oJson.AddPair('message', 'O nome e senha do usuário são campos obrigatório!');
      Res.Send<TJSONObject>(oJson).Status(400);
      Exit;
    end;

  senhaHash := TBCrypt.GenerateHash(oJson.GetValue<String>('senha_usuario'), 10);

  oJson := Req.Body<TJSONObject>;
  usuarioRegrasArray := oJson.GetValue<TJSONArray>('regras');

  if usuarioRegrasArray.Count > 0 then
    begin
      UsuariosRegras := TObjectList<Tusuarios_regras>.Create;

      for var i := 0 to usuarioRegrasArray.Count - 1 do
        begin
          UsuariosRegras.Add(Tusuarios_regras.Create);
          With UsuariosRegras.Last Do
            begin
              id_regra := (usuarioRegrasArray.Items[i] as TJSONObject).GetValue<Integer>('id_regra');
            end;
        end;

    end;

  Try
    var
    IUsuario := TIUsuario.New;

    filter := 'dt_del is null';
    filter := filter + ' AND nome_usuario='+
      QuotedStr(oJson.GetValue<String>('nome_usuario'));
    IUsuario.Build.ListAll(filter, Usuarios, '');

//    oJson := TJSONObject.Create;
    if Usuarios.Count > 0 then
      begin
        oJson.AddPair('message', 'username already in use');
        Res.Send<TJSONObject>(oJson).Status(400);
      end
    else
      begin
        IUsuario
          .id_pessoa(oJson.GetValue<Integer>('id_pessoa'))
          .nome_usuario(oJson.GetValue<String>('nome_usuario'))
          .senha_hash(senhaHash)
          .usuarios_regras(UsuariosRegras)
         .Build.Insert;
        oJson.SetPairs(TList<TJSONPair>.Create);
        oJson.AddPair('message', 'user registered successfull!');
        Res.Send<TJSONObject>(oJson).Status(200);
      end;
  Except
    on E: Exception Do
    begin
      // Respondendo com erro
      oJson := TJSONObject.Create;
      oJson.AddPair('error', E.Message);
      Res.Send<TJSONObject>(oJson).Status(500);
    end;
  End;
end;

class procedure TControllerUsuarios.Put(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  oJson: TJSONObject;
  usuarioRegrasArray: TJSONArray;
  Usuario: Tusuarios;
  UsuariosRegras: TObjectList<Tusuarios_regras>;
  id: Integer;
  senhaHash: String;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'id user not found');
      Res.Send<TJSONObject>(oJson).Status(500);
    end
  else
    if Req.Body.IsEmpty then
      begin
        oJson.AddPair('error', 'request body not found');
        Res.Send<TJSONObject>(oJson).Status(500);
      end
    else
      begin
        id := Req.Params.Items['id'].ToInteger();
        oJson := Req.Body<TJSONObject>;

        if (oJson.GetValue<String>('nome_usuario').IsEmpty) Or
        (oJson.GetValue<String>('senha_usuario').IsEmpty) then
          begin
            oJson.AddPair('message',
              'O nome e senha do usuário são campos obrigatório!');
            Res.Send<TJSONObject>(oJson).Status(400);
            Exit;
          end;

        Try
          var
          IUsuario := TIUsuario.New;
          Usuario := IUsuario.Build.ListById('id_usuario', id, Usuario).This;

          if (Usuario = nil) Or (Usuario.id_usuario = 0) then
            begin
              oJson.AddPair('error', 'user not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if Usuario.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          senhaHash := TBCrypt
            .GenerateHash(oJson.GetValue<String>('senha_usuario'), 10);

          oJson := Req.Body<TJSONObject>;
          usuarioRegrasArray := oJson.GetValue<TJSONArray>('regras');
          IUsuario.Build.Modify(Usuario);

          if usuarioRegrasArray.Count > 0 then
            begin

              var i := Usuario.usuarios_regras.Count - 1;

              while i >= 0 do
                begin
                  Usuario.usuarios_regras.Delete(i);
                  Dec(i);
                end;

              UsuariosRegras := TObjectList<Tusuarios_regras>.Create;

              for i := 0 to usuarioRegrasArray.Count - 1 do
                begin
                  UsuariosRegras.Add(Tusuarios_regras.Create);
                  With UsuariosRegras.Last Do
                    begin
                      id_usuario := id;
                      id_regra := (usuarioRegrasArray.Items[i] as TJSONObject)
                        .GetValue<Integer>('id_regra');
                    end;
                end;

            end;

          Usuario.nome_usuario := oJson.GetValue<String>('nome_usuario');
          Usuario.senha_hash := senhaHash;
          Usuario.usuarios_regras := UsuariosRegras;
          IUsuario.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'user changed successfull!');
          Res.Send<TJSONObject>(oJson).Status(200);
        Except
          on E: Exception Do
            begin
              oJson := TJSONObject.Create;
              oJson.AddPair('error', E.Message);
              Res.Send<TJSONObject>(oJson).Status(500);
            end;
        End;
      end;
end;

class procedure TControllerUsuarios.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
        .Get('/usuarios', GetAll)
        .Get('/usuarios/:id', GetOne)
        .Post('/usuarios', Post)
        .Put('/usuarios/:id', Put)
        .Delete('/usuarios/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerUsuarios)

end.
