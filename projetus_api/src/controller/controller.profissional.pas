unit controller.profissional;

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

  Horse.GBSwagger.Register,
  Horse.GBSwagger.Controller,
  GBSwagger.Path.Attributes,

  BCrypt,
  BCrypt.Types,

  model.contatos_emails,
  model.contatos_telefones,
  model.contatos,
  model.dados_pessoais,
  model.endereco,
  model.usuarios_regras,
  model.usuarios,
  model.pessoa,
  model.api.message,

  controller.dto.pessoa.interfaces,
  controller.dto.pessoa.interfaces.impl,
  controller.dto.contatos.interfaces,
  controller.dto.contatos.interfaces.impl,
  controller.dto.contatos_telefones.interfaces,
  controller.dto.contatos_telefones.interfaces.impl,
  controller.dto.contatos_emails.interfaces,
  controller.dto.contatos_emails.interfaces.impl,
  controller.dto.usuarios.interfaces,
  controller.dto.usuarios.interfaces.impl;

type
  [SwagPath('v1', 'Profissionais')]
  TControllerProfissional = class(THorseGBSwagger)
    private
    public
    class procedure Registry;

    [SwagGet('profissionais', 'Retorna listagem de profissionais')]
    [SwagResponse(200, Tpessoas, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamQuery('nome', 'Nome do profissional', False, False)]
    [SwagParamQuery('email', 'Email do profissional', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('profissionais/:id', 'Retorna dados de um profissional')]
    [SwagResponse(200, Tpessoas, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Professional not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('profissionais', 'Regista um novo profissional')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('profissionais', Tpessoas)]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('profissionais/:id', 'Atualiza dados de um profissional')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Professional not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('profissionais/:id/delete', 'Apaga registro e os créditos de um profissional')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Professional not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerProfissional }

class procedure TControllerProfissional.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  msg: String;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'id professional not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var IPessoa := TIPessoa.New;
  var Pessoa: Tpessoas;

  Pessoa := IPessoa.Build.ListById('id_pessoa', id, Pessoa).This;

  if Pessoa = nil then
    begin
      oJson.AddPair('error', 'professional not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if Pessoa.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'deleted record');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IPessoa.Build.Modify(Pessoa);
  Pessoa.dt_del := now();
  IPessoa.Build.Update;

  oJson.AddPair('message', 'successfully professional deleted');
  Res.Send<TJSONObject>(oJson).Status(404);
end;

class procedure TControllerProfissional.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  Pessoas: TObjectList<Tpessoas>;
  Pessoa: Tpessoas;
  Contato: Tcontatos;
  Telefone: Tcontatos_telefones;
  Email: Tcontatos_emails;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,
  vemail,
  page,
  records,
  perPage,
  filter: String;
  totalPages: Integer;
  clienteDataSet: TClientDataSet;
begin
  Try
    Try
      var
      IPessoa := TIPessoa.New;
      nome := Req.Query['nome'];
      vemail := Req.Query['email'];
      page := Req.Query['page'];
      perPage := Req.Query['perPage'];

      filter := 'dt_del is null AND tipo = ''P''';
      if nome <> EmptyStr then
        filter := filter + ' AND nome LIKE '+QuotedStr('%'+nome+'%');

      if vemail <> EmptyStr then
        filter := filter + ' AND email LIKE '+QuotedStr('%'+vemail+'%');

      if page = EmptyStr then
        page := '1';

      if perPage = EmptyStr then
        perPage := '10';

      var registros: Integer;
      IPessoa.Build.GetRecordsNumber('pessoas', filter, registros);
      totalPages := Ceil(registros / perPage.ToInteger());
      records := IntToStr(registros);

      IPessoa.Build.ListPaginate(filter, Pessoas, 'id_pessoa',
        StrToInt(perPage), (StrToInt(perPage) * (StrToInt(page) - 1)));

      oJsonResult := TJSONObject.Create;
      aJson := TJSONArray.Create;
      for Pessoa in Pessoas do
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('id_profissional', Pessoa.id_pessoa.ToString);
          oJson.AddPair('nome', Pessoa.nome);

            var endereco := TJSONObject.Create;

            if Pessoa.endereco.cep.HasValue then
              endereco.AddPair('cep', Pessoa.endereco.cep)
            else
              endereco.AddPair('cep', TJSONNull.Create);

            if Pessoa.endereco.logradouro.HasValue then
              endereco.AddPair('logradouro', Pessoa.endereco.logradouro)
            else
              endereco.AddPair('logradouro', TJSONNull.Create);

            if Pessoa.endereco.numero.HasValue then
              endereco.AddPair('numero', Pessoa.endereco.numero)
            else
              endereco.AddPair('numero', TJSONNull.Create);

            if Pessoa.endereco.complemento.HasValue then
              endereco.AddPair('complemento', Pessoa.endereco.complemento)
            else
              endereco.AddPair('complemento', TJSONNull.Create);

            if Pessoa.endereco.bairro.HasValue then
              endereco.AddPair('bairro', Pessoa.endereco.bairro)
            else
              endereco.AddPair('bairro', TJSONNull.Create);

            if Pessoa.endereco.municipio.HasValue then
              endereco.AddPair('municipio', Pessoa.endereco.municipio)
            else
              endereco.AddPair('municipio', TJSONNull.Create);

            if Pessoa.endereco.estado.HasValue then
              endereco.AddPair('estado', Pessoa.endereco.estado)
            else
              endereco.AddPair('estado', TJSONNull.Create);

            var dados_pessoais := TJSONObject.Create;
            if Pessoa.dados_pessoais.cpf.HasValue then
              dados_pessoais.AddPair('cpf', Pessoa.dados_pessoais.cpf.Value)
            else
              dados_pessoais.AddPair('cpf', TJSONNull.Create);

            if Pessoa.dados_pessoais.identidade.HasValue then
              dados_pessoais.AddPair('identidade', Pessoa.dados_pessoais.identidade.Value)
            else
              dados_pessoais.AddPair('identidade', TJSONNull.Create);

            if Pessoa.dados_pessoais.data_nascimento.HasValue then
              dados_pessoais.AddPair('data_nascimento',
                FormatDateTime('YYYY-mm-dd', Pessoa.dados_pessoais.data_nascimento.Value))
            else
              dados_pessoais.AddPair('data_nascimento', TJSONNull.Create);

          oJson.AddPair('endereco', endereco);
          oJson.AddPair('dados_pessoas', dados_pessoais);

          for Contato in Pessoa.contatos do
            begin
              var aContatos := TJSONArray.Create;
              var oContatos := TJSONObject.Create;
              if Contato.nome <> Pessoa.nome then
                oContatos.AddPair('nome', Contato.nome);

              oContatos.AddPair('telefones',
              TJSONObject.ParseJSONValue(Contato.contatos_telefones.telefones) as TJSONArray);
              oContatos.AddPair('emails',
              TJSONObject.ParseJSONValue(Contato.contatos_emails.emails) as TJSONArray);

              aContatos.AddElement(oContatos);
              oJson.AddPair('contatos', aContatos);
            end;

          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Pessoa.dt_inc));
          if Pessoa.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Pessoa.dt_alt.Value))
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
  Finally
    Pessoas.Clear;
    if Assigned(Telefone) then
      Telefone := nil;
    if Assigned(Email) then
      Email := nil;

    FreeAndNil(Pessoas);
  End;
end;

class procedure TControllerProfissional.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
  Contato : Tcontatos;
  Telefone : Tcontatos_telefones;
  Email : Tcontatos_emails;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'id professional not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IPessoa := TIPessoa.New;
  var
  Pessoa: Tpessoas;

  IPessoa.Build.ListById('id_pessoa', id, Pessoa);
  if Pessoa = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'customer not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    if Pessoa.dt_del.HasValue then
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'customer not found');
        Res.Send<TJSONObject>(oJson).Status(404);
      end
    else
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('id_profissional', Pessoa.id_pessoa.ToString);
        oJson.AddPair('nome', Pessoa.nome);

            var endereco := TJSONObject.Create;

            if Pessoa.endereco.cep.HasValue then
              endereco.AddPair('cep', Pessoa.endereco.cep)
            else
              endereco.AddPair('cep', TJSONNull.Create);

            if Pessoa.endereco.logradouro.HasValue then
              endereco.AddPair('logradouro', Pessoa.endereco.logradouro)
            else
              endereco.AddPair('logradouro', TJSONNull.Create);

            if Pessoa.endereco.numero.HasValue then
              endereco.AddPair('numero', Pessoa.endereco.numero)
            else
              endereco.AddPair('numero', TJSONNull.Create);

            if Pessoa.endereco.complemento.HasValue then
              endereco.AddPair('complemento', Pessoa.endereco.complemento)
            else
              endereco.AddPair('complemento', TJSONNull.Create);

            if Pessoa.endereco.bairro.HasValue then
              endereco.AddPair('bairro', Pessoa.endereco.bairro)
            else
              endereco.AddPair('bairro', TJSONNull.Create);

            if Pessoa.endereco.municipio.HasValue then
              endereco.AddPair('municipio', Pessoa.endereco.municipio)
            else
              endereco.AddPair('municipio', TJSONNull.Create);

            if Pessoa.endereco.estado.HasValue then
              endereco.AddPair('estado', Pessoa.endereco.estado)
            else
              endereco.AddPair('estado', TJSONNull.Create);

            var dados_pessoais := TJSONObject.Create;
            dados_pessoais.AddPair('id', Pessoa.dados_pessoais.id_dado_pessoal.ToString());
            if Pessoa.dados_pessoais.cpf.HasValue then
              dados_pessoais.AddPair('cpf', Pessoa.dados_pessoais.cpf.Value)
            else
              dados_pessoais.AddPair('cpf', TJSONNull.Create);

            if Pessoa.dados_pessoais.identidade.HasValue then
              dados_pessoais.AddPair('identidade', Pessoa.dados_pessoais.identidade.Value)
            else
              dados_pessoais.AddPair('identidade', TJSONNull.Create);

            if Pessoa.dados_pessoais.data_nascimento.HasValue then
              dados_pessoais.AddPair('data_nascimento',
                FormatDateTime('YYYY-mm-dd', Pessoa.dados_pessoais.data_nascimento.Value))
            else
              dados_pessoais.AddPair('data_nascimento', TJSONNull.Create);

          oJson.AddPair('endereco', endereco);
          oJson.AddPair('dados_pessoais', dados_pessoais);

          for Contato in Pessoa.contatos do
            begin
              var aContatos := TJSONArray.Create;
              var oContatos := TJSONObject.Create;
              oContatos.AddPair('id', Contato.id_contato.ToString());
              if Contato.nome <> Pessoa.nome then
                oContatos.AddPair('nome', Contato.nome);

              oContatos.AddPair('telefones',
              TJSONObject.ParseJSONValue(Contato.contatos_telefones.telefones) as TJSONArray);
              oContatos.AddPair('emails',
              TJSONObject.ParseJSONValue(Contato.contatos_emails.emails) as TJSONArray);

              aContatos.AddElement(oContatos);
              oJson.AddPair('contatos', aContatos);
            end;

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Pessoa.dt_inc));
        if Pessoa.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Pessoa.dt_alt.Value))
        else
          oJson.AddPair('alterado_em', TJSONNull.Create);

        Res.Send<TJSONObject>(oJson).Status(200);
      end;
end;

class procedure TControllerProfissional.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  JSONBytes: TBytes;
  JSONString: string;
  msg: String;
  senhaHash, filter: String;
  Pessoa: Tpessoas;
  Usuario: Tusuarios;
  UsuarioRegra: Tusuarios_regras;
  Usuarios: TObjectList<Tusuarios>;
  UsuariosRegras: TObjectList<Tusuarios_regras>;
  Endereco: Tenderecos;
  DadoPessoal: Tdados_pessoais;
  Contato: Tcontatos;
  Contatos: TObjectList<Tcontatos>;
  Telefone: Tcontatos_telefones;
  Telefones: TObjectList<Tcontatos_telefones>;
  Email: Tcontatos_emails;
  Emails: TObjectList<Tcontatos_emails>;
  contatosArray, telefonesArray, emailsArray: TJSONArray;
  jsonValue: TJSONValue;
  MemoryStream: TMemoryStream;
  i, j, k: Integer;
  BlobField: TBlobField;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('customer data not found');

  oJson := Req.Body<TJSONObject>;

  Try
    // Criando o Usuário
    if (oJson.GetValue<String>('usuario.nome_usuario').IsEmpty) Or
    (oJson.GetValue<String>('usuario.senha_usuario').IsEmpty) then
      begin
        oJson.AddPair('message', 'O nome e senha do usuário são campos obrigatório!');
        Res.Send<TJSONObject>(oJson).Status(400);
        Exit;
      end;

    senhaHash := TBCrypt.GenerateHash(oJson.GetValue<String>('usuario.senha_usuario'), 10);

    var
    IUsuario := TIUsuario.New;

    filter := 'dt_del is null';
    filter := filter + ' AND nome_usuario='+
      QuotedStr(oJson.GetValue<String>('usuario.nome_usuario'));
    IUsuario.Build.ListAll(filter, Usuarios, '');

    if Usuarios.Count > 0 then
      begin
        oJson.AddPair('message', 'username already in use');
        Res.Send<TJSONObject>(oJson).Status(400);
        Exit;
      end;

    UsuariosRegras := TObjectList<Tusuarios_regras>.Create;
    UsuariosRegras.Add(Tusuarios_regras.Create);
    with UsuariosRegras.Last do
    begin
      id_regra := 2; // Regras: 1 - Administrador; 2 - Profissionais; 3 - Clientes;
    end;

    Usuario := Tusuarios.Create;
    with Usuario do
    begin
      nome_usuario := oJson.GetValue<String>('usuario.nome_usuario');
      senha_hash := senhaHash;
      usuarios_regras := UsuariosRegras;
    end;

    // Criando o Endereço
    Endereco := Tenderecos.Create;
    with Endereco do
    begin
      cep := oJson.GetValue<String>('endereco.cep');
      logradouro := oJson.GetValue<String>('endereco.logradouro');
      numero := oJson.GetValue<String>('endereco.numero');
      complemento := oJson.GetValue<String>('endereco.complemento');
      bairro := oJson.GetValue<String>('endereco.bairro');
      id_municipio := oJson.GetValue<Integer>('endereco.id_municipio');
      id_estado := oJson.GetValue<Integer>('endereco.id_estado');
    end;

    // Criando os Dados Pessoais
    DadoPessoal := Tdados_pessoais.Create;
    with DadoPessoal do
    begin
      cpf := oJson.GetValue<String>('dados_pessoais.cpf');
      identidade := oJson.GetValue<String>('dados_pessoais.identidade');
      data_nascimento := StrToDate(oJson.GetValue<String>('dados_pessoais.data_nascimento'));
    end;

    contatosArray := oJson.GetValue<TJSONArray>('contatos');

    if contatosArray.Count > 0 then
      begin
        // Criando os Contatos
        Contatos := TObjectList<Tcontatos>.Create;

        for i := 0 to contatosArray.Count - 1 do
        begin
          Contatos.Add(Tcontatos.Create);

          // Acessando os dados de cada contato
          with Contatos.Last do
          begin
            nome :=  (contatosArray.Items[i] as TJSONObject).GetValue<String>('nome');

            telefonesArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('telefones');
            if telefonesArray.Count > 0 then
              begin
                contatos_telefones.telefones := telefonesArray.ToString;
                contatos_telefones.dt_inc := now();
              end;

            emailsArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('emails');
            if emailsArray.Count > 0 then
            begin
              contatos_emails.emails := emailsArray.ToString;
              contatos_emails.dt_inc := now();
            end;
          end;
        end;
      end;

    // Criando o IPessoa e inserindo os dados no banco
    var IPessoa := TIPessoa.New;
    IPessoa
      .nome(oJson.GetValue<String>('nome'))
      .tipo('P')
      .suspenso(false)
      .endereco(Endereco)
      .dados_pessoais(DadoPessoal)
      .contatos(Contatos)
      .usuario(Usuario)
    .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'professional registered successfull!');
    Res.Send<TJSONObject>(oJson).Status(200);
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

class procedure TControllerProfissional.Put(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  msg: String;
  Pessoa: Tpessoas;
  Endereco: Tenderecos;
  DadoPessoal: Tdados_pessoais;
  oContatos: TObjectList<Tcontatos>;
  oTelefone:Tcontatos_telefones;
  Telefones: TObjectList<Tcontatos_telefones>;
  oEmail: Tcontatos_emails;
  Emails: TObjectList<Tcontatos_emails>;
  contatosArray, telefonesArray, emailsArray: TJSONArray;
  id, i, j, k: Integer;
begin
  oJson := TJSONObject.Create;

if Req.Params.Count = 0 then
  begin
    oJson.AddPair('error', 'id professional not found');
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

      Try
        var IPessoa := TIPessoa.New;

        Pessoa := IPessoa.Build.ListById('id_pessoa', id, Pessoa).This;

        if (Pessoa = nil) Or (Pessoa.id_pessoa = 0) then
          begin
            oJson.AddPair('error', 'professional not found');
            Res.Send<TJSONObject>(oJson).Status(404);
            Exit;
          end
        else
          if Pessoa.dt_del.HasValue then
            begin
              oJson := TJSONObject.Create;
              oJson.AddPair('message', 'deleted record');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end;

        oJson := Req.Body<TJSONObject>;

        Endereco := Tenderecos.Create;
        With Endereco Do
          begin
            id_endereco := oJson.GetValue<Integer>('endereco.id');
            cep := oJson.GetValue<String>('endereco.cep');
            logradouro := oJson.GetValue<String>('endereco.logradouro');
            numero := oJson.GetValue<String>('endereco.numero');
            complemento := oJson.GetValue<String>('endereco.complemento');
            bairro := oJson.GetValue<String>('endereco.bairro');
            id_municipio := oJson.GetValue<Integer>('endereco.id_municipio');
            id_estado := oJson.GetValue<Integer>('endereco.id_estado');
          end;

        // Criando os Dados Pessoais
        DadoPessoal := Tdados_pessoais.Create;
        with DadoPessoal do
        begin
          id_dado_pessoal := oJson.GetValue<Integer>('dados_pessoais.id');
          cpf := oJson.GetValue<String>('dados_pessoais.cpf');
          identidade := oJson.GetValue<String>('dados_pessoais.identidade');
          data_nascimento := StrToDate(oJson.GetValue<String>('dados_pessoais.data_nascimento'));
        end;

        // Criando os Contatos
        contatosArray := oJson.GetValue<TJSONArray>('contatos');

        if contatosArray.Count > 0 then
          begin
            // Criando os Contatos
            oContatos := TObjectList<Tcontatos>.Create;

            for i := 0 to contatosArray.Count - 1 do
            begin
              oContatos.Add(Tcontatos.Create);

              // Acessando os dados de cada contato
              with oContatos.Last do
              begin
                id_contato := (contatosArray.Items[i] as TJSONObject).GetValue<Integer>('id');
                nome :=  (contatosArray.Items[i] as TJSONObject).GetValue<String>('nome');

                telefonesArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('telefones');
                if telefonesArray.Count > 0 then
                  begin
                    contatos_telefones.telefones := telefonesArray.ToString;
                    contatos_telefones.dt_inc := now();
                  end;

                emailsArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('emails');
                if emailsArray.Count > 0 then
                begin
                  contatos_emails.emails := emailsArray.ToString;
                  contatos_emails.dt_inc := now();
                end;
              end;
            end;
          end;

        IPessoa.Build.Modify(Pessoa);
        With Pessoa Do
          begin
            nome := oJson.GetValue<String>('nome');
            suspenso := oJson.GetValue<Boolean>('suspenso');
            dt_alt := now();

            endereco.cep := oJson.GetValue<String>('endereco.cep');
            endereco.logradouro := oJson.GetValue<String>('endereco.logradouro');
            endereco.numero := oJson.GetValue<String>('endereco.numero');
            endereco.complemento := oJson.GetValue<String>('endereco.complemento');
            endereco.bairro := oJson.GetValue<String>('endereco.bairro');
            endereco.id_municipio := oJson.GetValue<Integer>('endereco.id_municipio');
            endereco.id_estado := oJson.GetValue<Integer>('endereco.id_estado');

            dados_pessoais.cpf := oJson.GetValue<String>('dados_pessoais.cpf');
            dados_pessoais.identidade := oJson.GetValue<String>('dados_pessoais.identidade');
            dados_pessoais.data_nascimento := StrToDate(oJson.GetValue<String>('dados_pessoais.data_nascimento'));

            for i := 0 to contatos.Count - 1 do
              begin
                for j := 0 to oContatos.Count - 1 do
                  begin
                    if contatos[i].id_contato = oContatos[j].id_contato then
                      begin
                        contatos[i].nome := oContatos[j].nome;
                        contatos[i].contatos_telefones.telefones := oContatos[j].contatos_telefones.telefones;
                        contatos[i].contatos_emails.emails := oContatos[j].contatos_emails.emails;
                        contatos[i].dt_alt := dt_alt;
                      end;
                  end;
              end;

          end;
        IPessoa.Build.Update;
        oJson := TJSONObject.Create;
        oJson.AddPair('message', 'professional changed successfull!');
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

class procedure TControllerProfissional.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
        .Get('/profissionais', GetAll)
        .Get('/profissionais/:id', GetOne)
        .Post('/profissionais', Post)
        .Put('/profissionais/:id', Put)
        .Delete('/profissionais/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerProfissional)

end.
