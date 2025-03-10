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
  model.endereco,
  model.pessoa,
  controller.dto.pessoa.interfaces,
  controller.dto.pessoa.interfaces.impl;

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
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,
  email,
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
      email := Req.Query['email'];
      page := Req.Query['page'];
      perPage := Req.Query['perPage'];

      filter := 'dt_del is null';
      if nome <> EmptyStr then
        filter := filter + ' AND nome LIKE '+QuotedStr('%'+nome+'%');

      if email <> EmptyStr then
        filter := filter + ' AND email LIKE '+QuotedStr('%'+email+'%');

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
          oJson.AddPair('telefone1', Pessoa.telefone1);
          if Not Pessoa.telefone2.HasValue then
            oJson.AddPair('telefone2', TJSONNull.Create)
          else
            oJson.AddPair('telefone2', Pessoa.telefone2);
          oJson.AddPair('email', Pessoa.email);
            var endereco := TJSONObject.Create;
            endereco.AddPair('cep', Pessoa.endereco.cep);
            endereco.AddPair('logradouro', Pessoa.endereco.logradouro);
            endereco.AddPair('numero', Pessoa.endereco.numero);
            endereco.AddPair('complemento', Pessoa.endereco.complemento);
            endereco.AddPair('bairro', Pessoa.endereco.bairro);
            endereco.AddPair('municipio', Pessoa.endereco.municipio);
            endereco.AddPair('estado', Pessoa.endereco.estado);
          oJson.AddPair('endereco', endereco);
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
    FreeAndNil(Pessoas);
  End;
end;

class procedure TControllerCliente.GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  id: Integer;
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
        oJson.AddPair('telefone1', Pessoa.telefone1);
        if Not Pessoa.telefone2.HasValue then
          oJson.AddPair('telefone2', TJSONNull.Create)
        else
          oJson.AddPair('telefone2', Pessoa.telefone2);
        oJson.AddPair('email', Pessoa.email);
          var endereco := TJSONObject.Create;
          endereco.AddPair('cep', Pessoa.endereco.cep);
          endereco.AddPair('logradouro', Pessoa.endereco.logradouro);
          endereco.AddPair('numero', Pessoa.endereco.numero);
          endereco.AddPair('complemento', Pessoa.endereco.complemento);
          endereco.AddPair('bairro', Pessoa.endereco.bairro);
          endereco.AddPair('municipio', Pessoa.endereco.municipio);
          endereco.AddPair('estado', Pessoa.endereco.estado);
        oJson.AddPair('endereco', endereco);
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
  oJson : TJSONObject;
  msg: String;
  Endereco: Tenderecos;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('Cliente data not found');
  oJson := Req.Body<TJSONObject>;

  Try
    Endereco := Tenderecos.Create;

    With Endereco Do
      begin
        cep := oJson.GetValue<String>('endereco.cep');
        logradouro := oJson.GetValue<String>('endereco.logradouro');
        numero := oJson.GetValue<String>('endereco.numero');
        complemento := oJson.GetValue<String>('endereco.complemento');
        bairro := oJson.GetValue<String>('endereco.bairro');
        id_municipio := oJson.GetValue<Integer>('endereco.id_municipio');
        id_estado := oJson.GetValue<Integer>('endereco.id_estado');
      end;

    var IPessoa := TIPessoa.New;
    IPessoa
           .nome(oJson.GetValue<String>('nome'))
           .telefone1(oJson.GetValue<String>('telefone1'))
           .telefone2(oJson.GetValue<String>('telefone2'))
           .email(oJson.GetValue<String>('email'))
           .endereco(Endereco)
    .Build.Insert;
    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'cliente criado com sucesso!');
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
              .telefone1(oJson.GetValue<String>('telefone'))
              .email(oJson.GetValue<String>('email'))
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
  Endereco: Tenderecos;
  id: Integer;
begin
  oJson := TJSONObject.Create;

  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'Id Cliente not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  if Req.Body.IsEmpty then
    begin
      oJson.AddPair('error', 'Cliente data not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    oJson := Req.Body<TJSONObject>;

  Try
    Endereco := Tenderecos.Create;

    With Endereco Do
      begin
        cep := oJson.GetValue<String>('endereco.cep');
        logradouro := oJson.GetValue<String>('endereco.logradouro');
        numero := oJson.GetValue<String>('endereco.numero');
        complemento := oJson.GetValue<String>('endereco.complemento');
        bairro := oJson.GetValue<String>('endereco.bairro');
        id_municipio := oJson.GetValue<Integer>('endereco.id_municipio');
        id_estado := oJson.GetValue<Integer>('endereco.id_estado');
      end;

    var IPessoa := TIPessoa.New;
    var Pessoa: Tpessoas;

    Pessoa := IPessoa.Build.ListById('id_pessoa', id, Pessoa).This;

    if Pessoa = nil then
      begin
        oJson.AddPair('error', 'Cliente not found');
        Res.Send<TJSONObject>(oJson).Status(404);
        Exit;
      end
    else
      if Pessoa.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'Cliente not found');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

    IPessoa.Build.Modify(Pessoa);
    With Pessoa Do
      begin
        nome := oJson.GetValue<String>('nome');
        telefone1 := oJson.GetValue<String>('telefone1');
        telefone2 := oJson.GetValue<String>('telefone2');
        email := oJson.GetValue<String>('email');
        endereco := Endereco;
      end;
    IPessoa.Build.Update;
    FreeAndNil(Pessoa);
    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'cliente alterado com sucesso!');
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

class procedure TControllerCliente.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  msg: String;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'Id Cliente not found');
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
      oJson.AddPair('error', 'Cliente not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if Pessoa.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'Cliente not found');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IPessoa.Build.Modify(Pessoa);
  Pessoa.dt_del := now();
  IPessoa.Build.Update;

  oJson.AddPair('message', 'Cliente successfully deleted');
  Res.Send<TJSONObject>(oJson).Status(404);
end;

end.
