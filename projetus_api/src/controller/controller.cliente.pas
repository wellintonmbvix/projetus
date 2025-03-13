unit controller.cliente;

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

  uRotinas,

  model.contatos_emails,
  model.contatos_telefones,
  model.contatos,
  model.dados_pessoais,
  model.endereco,
  model.pessoa,
  controller.dto.pessoa.interfaces,
  controller.dto.pessoa.interfaces.impl,
  controller.dto.contatos.interfaces,
  controller.dto.contatos.interfaces.impl,
  controller.dto.contatos_telefones.interfaces,
  controller.dto.contatos_telefones.interfaces.impl,
  controller.dto.contatos_emails.interfaces,
  controller.dto.contatos_emails.interfaces.impl;

type
  TControllerCliente = class
    class procedure Registry;
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure PostList(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerCliente }

class procedure TControllerCliente.Registry;
begin
  THorse.Get('api/v1/clientes', GetAll)
        .Get('api/v1/clientes/:id', GetOne)
        .Post('api/v1/clientes', Post)
        .Post('api/v1/clientes/lista', PostList)
        .Put('api/v1/clientes/:id', Put)
        .Delete('api/v1/clientes/:id/delete', Delete);
end;

class procedure TControllerCliente.GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);
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

      filter := 'dt_del is null AND tipo = ''C''';
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
          oJson.AddPair('id_cliente', Pessoa.id_pessoa.ToString);
          oJson.AddPair('nome', Pessoa.nome);

            var endereco := TJSONObject.Create;
            endereco.AddPair('cep', Pessoa.endereco.cep);
            endereco.AddPair('logradouro', Pessoa.endereco.logradouro);
            endereco.AddPair('numero', Pessoa.endereco.numero);
            endereco.AddPair('complemento', Pessoa.endereco.complemento);
            endereco.AddPair('bairro', Pessoa.endereco.bairro);
            endereco.AddPair('municipio', Pessoa.endereco.municipio);
            endereco.AddPair('estado', Pessoa.endereco.estado);

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

              var aTelefones := TJSONArray.Create;
              for var i := 0 to Contato.contatos_telefones.Count - 1 do
                begin
                  Telefone := Contato.contatos_telefones[i];

                  aTelefones.Add(Telefone.telefone);

                  if i = Contato.contatos_telefones.Count - 1 then
                    oContatos.AddPair('telefones', aTelefones);
                end;

              var aEmails := TJSONArray.Create;
              for var i := 0 to Contato.contatos_emails.Count - 1 do
                begin
                  Email := Contato.contatos_emails[i];

                  aEmails.Add(Email.email);

                  if i = Contato.contatos_emails.Count - 1 then
                    oContatos.AddPair('emails', aEmails);
                end;

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

class procedure TControllerCliente.GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  id: Integer;
  Contato : Tcontatos;
  Telefone : Tcontatos_telefones;
  Email : Tcontatos_emails;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'Id Cliente not found');
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
        oJson.AddPair('message', 'Cliente not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    if Pessoa.dt_del.HasValue then
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'Cliente not found');
        Res.Send<TJSONObject>(oJson).Status(404);
      end
    else
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('id_cliente', Pessoa.id_pessoa.ToString);
        oJson.AddPair('nome', Pessoa.nome);

            var endereco := TJSONObject.Create;
            endereco.AddPair('id', Pessoa.endereco.id_endereco);
            endereco.AddPair('cep', Pessoa.endereco.cep);
            endereco.AddPair('logradouro', Pessoa.endereco.logradouro);
            endereco.AddPair('numero', Pessoa.endereco.numero);
            endereco.AddPair('complemento', Pessoa.endereco.complemento);
            endereco.AddPair('bairro', Pessoa.endereco.bairro);
            endereco.AddPair('municipio', Pessoa.endereco.municipio);
            endereco.AddPair('estado', Pessoa.endereco.estado);

            var dados_pessoais := TJSONObject.Create;
            dados_pessoais.AddPair('id', Pessoa.dados_pessoais.id_dado_pessoal);
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
              oContatos.AddPair('id', Contato.id_contato);
              if Contato.nome <> Pessoa.nome then
                oContatos.AddPair('nome', Contato.nome);

              var aTelefones := TJSONArray.Create;
              for var i := 0 to Contato.contatos_telefones.Count - 1 do
                begin
                  Telefone := Contato.contatos_telefones[i];

                  aTelefones.Add(Telefone.telefone);

                  if i = Contato.contatos_telefones.Count - 1 then
                    oContatos.AddPair('telefones', aTelefones);
                end;

              var aEmails := TJSONArray.Create;
              for var i := 0 to Contato.contatos_emails.Count - 1 do
                begin
                  Email := Contato.contatos_emails[i];

                  aEmails.Add(Email.email);

                  if i = Contato.contatos_emails.Count - 1 then
                    oContatos.AddPair('emails', aEmails);
                end;

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

class procedure TControllerCliente.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  msg: String;
  Endereco: Tenderecos;
  DadoPessoal: Tdados_pessoais;
  Contato: Tcontatos;
  Contatos: TObjectList<Tcontatos>;
  Telefone: Tcontatos_telefones;
  Telefones: TObjectList<Tcontatos_telefones>;
  Email: Tcontatos_emails;
  Emails: TObjectList<Tcontatos_emails>;
  contatosArray, telefonesArray, emailsArray: TJSONArray;
  i, j, k: Integer;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('Cliente data not found');

  oJson := Req.Body<TJSONObject>;

  Try
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

    // Criando os Contatos
    Contatos := TObjectList<Tcontatos>.Create;
    contatosArray := oJson.GetValue<TJSONArray>('contatos');

    for i := 0 to contatosArray.Count - 1 do
    begin
      Contatos.Add(Tcontatos.Create);

      // Acessando os dados de cada contato
      with Contatos.Last do
      begin
        nome := (contatosArray.Items[i] as TJSONObject).GetValue<String>('nome');

        // Criando Telefones
        telefonesArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('telefones');
        if telefonesArray.Count > 0 then
        begin
          Telefones := TObjectList<Tcontatos_telefones>.Create;
          for j := 0 to telefonesArray.Count - 1 do
          begin
            Telefones.Add(Tcontatos_telefones.Create);
            Telefones.Last.telefone := telefonesArray.Items[j].Value;
          end;
          contatos_telefones := Telefones;
          Telefones := nil;
        end;

        // Criando Emails
        emailsArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('emails');
        if emailsArray.Count > 0 then
        begin
          Emails := TObjectList<Tcontatos_emails>.Create;
          for k := 0 to emailsArray.Count - 1 do
          begin
            Emails.Add(Tcontatos_emails.Create);
            Emails.Last.email := emailsArray.Items[k].Value;
          end;
          contatos_emails := Emails;
          Emails := nil;
        end;
      end;
    end;

    // Criando o IPessoa e inserindo os dados no banco
    var IPessoa := TIPessoa.New;
    IPessoa
      .nome(oJson.GetValue<String>('nome'))
      .endereco(Endereco)
      .dados_pessoais(DadoPessoal)
      .tipo('C')
      .suspenso(false)
      .contatos(Contatos)
      .Build.Insert;

    // Respondendo com sucesso
    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'customer created successfully!');
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

class procedure TControllerCliente.PostList(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  jsonObj, oJson: TJSONObject;
  ja: TJSONArray;
  jv: TJSONValue;
begin
  ja:= Req.Body<TJSONArray>;
  var IPessoa := TIPessoa.New;
  for var i := 0 to ja.size - 1 do
    begin
      oJson := (ja.Get(i) as TJSONObject);
      jv := oJson.Get(0).JsonValue;
      IPessoa
              .nome(oJson.GetValue<String>('nome'))
      .Build.Insert;
    end;
    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'procedimento realizado com sucesso!');
    Res.Send<TJSONObject>(oJson).Status(200);
end;

class procedure TControllerCliente.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  msg: String;
  Pessoa: Tpessoas;
  Endereco: Tenderecos;
  DadoPessoal: Tdados_pessoais;
  Contatos: TObjectList<Tcontatos>;
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
    oJson.AddPair('error', 'id customer not found');
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
            oJson.AddPair('error', 'customer not found');
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
        Endereco := Pessoa.endereco;
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
        DadoPessoal := Pessoa.dados_pessoais;
        with DadoPessoal do
        begin
          id_dado_pessoal := oJson.GetValue<Integer>('dados_pessoais.id');
          cpf := oJson.GetValue<String>('dados_pessoais.cpf');
          identidade := oJson.GetValue<String>('dados_pessoais.identidade');
          data_nascimento := StrToDate(oJson.GetValue<String>('dados_pessoais.data_nascimento'));
        end;

        var IContato := TIContatos.New;
        var IContatoTelefone := TIContatosTelefones.New;
        var IContatoEmail := TIContatosEmails.New;

        // Criando os Contatos
        Contatos := TObjectList<Tcontatos>.Create;
        contatosArray := oJson.GetValue<TJSONArray>('contatos');

        for i := 0 to contatosArray.Count - 1 do
        begin
          Contatos.Add(Tcontatos.Create);

          // Acessando os dados de cada contato
          with Contatos.Last do
          begin
            id_contato := (contatosArray.Items[i] as TJSONObject).GetValue<Integer>('id');
            nome := (contatosArray.Items[i] as TJSONObject).GetValue<String>('nome');

            // Criando Telefones
            telefonesArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('telefones');
            if telefonesArray.Count > 0 then
            begin

              for j := 0 to telefonesArray.Count - 1 do
              begin
                oTelefone := IContatoTelefone.Build.ListById('id_contato',
                Contatos.Last.id_contato).This;
                IContatoTelefone.Build.Modify(oTelefone);
                IContatoTelefone.Build.Delete;
              end;

              for j := 0 to telefonesArray.Count - 1 do
              begin
                var contato_id := Contatos.Last.id_contato;
                var telefone := telefonesArray.Items[j].Value;
                IContatoTelefone
                  .id_contato(Contatos.Last.id_contato)
                  .telefone(telefonesArray.Items[j].Value)
                  .Build.Insert;
              end;
            end;

            // Criando Emails
            emailsArray := (contatosArray.Items[i] as TJSONObject).GetValue<TJSONArray>('emails');
            if emailsArray.Count > 0 then
            begin

              for k := 0 to emailsArray.Count - 1 do
              begin
                oEmail := IContatoEmail.Build.ListById('id_contato',
                id_contato).This;
                IContatoEmail.Build.Modify(oEmail);
                IContatoEmail.Build.Delete;
              end;

              for k := 0 to emailsArray.Count - 1 do
              begin
                IContatoEmail
                  .id_contato(id_contato)
                  .email(emailsArray.Items[k].Value)
                  .Build.Insert;
              end;
            end;
          end;
        end;

        IPessoa.Build.Modify(Pessoa);
        With Pessoa Do
          begin
            nome := oJson.GetValue<String>('nome');
            suspenso := oJson.GetValue<Boolean>('suspenso');
            endereco := Endereco;
            dados_pessoais := DadoPessoal;
            contatos := Contatos;
            dt_alt := now();
          end;
        IPessoa.Build.Update;
        oJson := TJSONObject.Create;
        oJson.AddPair('message', 'customer changed successfull!');
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

class procedure TControllerCliente.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  msg: String;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'id customer not found');
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
      oJson.AddPair('error', 'customer not found');
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

  oJson.AddPair('message', 'successfully customer deleted');
  Res.Send<TJSONObject>(oJson).Status(404);
end;

end.
