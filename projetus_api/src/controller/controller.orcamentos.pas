unit controller.orcamentos;

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

  uRotinas,

  model.orcamentos,
  model.api.sucess,
  model.api.error,
  controller.dto.orcamentos.interfaces,
  controller.dto.orcamentos.interfaces.impl;

type
  [SwagPath('v1', 'Orçamentos')]
  TControllerOrcamentos = class(THorseGBSwagger)
    private
    public
    class procedure Registry;

    [SwagGet('prcamentos', 'Retorna listagem de orçamentos')]
    [SwagResponse(200, Torcamentos, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    [SwagParamQuery('Cliente', 'Nome do cliente que solitar o orçamento', False, False)]
    [SwagParamQuery('Serviço', 'Nome do serviço que deseja orçamento', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('orcamentos/:id', 'Retorna dados de um orçamento')]
    [SwagResponse(200, Torcamentos, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('orcamentos', 'Regista um novo orçamento')]
    [SwagResponse(200, TAPISuccess)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('orcamentos/:id', 'Atualiza dados de um orçamento')]
    [SwagResponse(200, TAPISuccess)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('orcamentos/:id/delete', 'Apaga registro de um orçamento')]
    [SwagResponse(200, TAPISuccess)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerOrcamentos }

class procedure TControllerOrcamentos.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'id budgets not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IOrcamentos := TIOrcamentos.New;
  var
  Orcamento: Torcamentos;

  Orcamento := IOrcamentos.Build.ListById('id_orcamento', id, Orcamento).This;

  if Orcamento = nil then
    begin
      oJson.AddPair('error', 'service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if Orcamento.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'record has already been deleted');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IOrcamentos.Build.Modify(Orcamento);
  Orcamento.dt_del := now();
  IOrcamentos.Build.Update;

  oJson.AddPair('message', 'successfully budget deleted');
  Res.Send<TJSONObject>(oJson).Status(200);
end;

class procedure TControllerOrcamentos.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  Orcamentos: TObjectList<Torcamentos>;
  Orcamento: Torcamentos;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  cliente,servico,page,perPage,filter,records: String;
  totalPages: Integer;
begin
  Try
    var
    IOrcamentos := TIOrcamentos.New;
    cliente := Req.Query['cliente'];
    servico := Req.Query['servico'];
    page := Req.Query['page'];
    perPage := Req.Query['perPage'];

    filter := 'orcamentos.dt_del is null';
    if cliente <> EmptyStr then
      filter := filter + ' AND cliente LIKE '+QuotedStr('%'+cliente+'%');

    if servico <> EmptyStr then
      filter := filter + ' AND servico LIKE '+QuotedStr('%'+servico+'%');

    if page = EmptyStr then
      page := '1';

    if perPage = EmptyStr then
      perPage := '10';

    var registros: Integer;
    IOrcamentos.Build.GetRecordsNumber('orcamentos', filter, registros);
    totalPages := Ceil(registros / perPage.ToInteger());
    records := IntToStr(registros);

    IOrcamentos.Build.ListPaginate(filter, Orcamentos, 'id_orcamento',
      StrToInt(perPage), (StrToInt(perPage) * (StrToInt(page) - 1)));

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for Orcamento in Orcamentos do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id', TJSONNumber.Create(Orcamento.id_orcamento));
        oJson.AddPair('id_cliente', TJSONNumber.Create(Orcamento.id_pessoa));
        oJson.AddPair('cliente', TJSONString.Create(Orcamento.cliente.Value));
        oJson.AddPair('id_servico', TJSONNumber.Create(Orcamento.id_servico));
        oJson.AddPair('servico', TJSONString.Create(Orcamento.servico.Value));
        oJson.AddPair('info_adicionais', TJSONString.Create(Orcamento.info_adicionais));
        oJson.AddPair('urgente', TJSONBool.Create(Orcamento.urgente));
        oJson.AddPair('previsao_inicio', FormatDateTime('YYY-mm-dd', Orcamento.previsao_inicio));

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Orcamento.dt_inc));
        if Orcamento.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Orcamento.dt_alt.Value))
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

class procedure TControllerOrcamentos.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'id service not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IOrcamentos := TIOrcamentos.New;
  var
  Orcamento: Torcamentos;

  IOrcamentos.Build.ListById('id_orcamento', id, Orcamento);
  if Orcamento = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    begin
      if Orcamento.dt_del.HasValue then
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('message', 'service not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end
      else
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('id', TJSONNumber.Create(Orcamento.id_orcamento));
          oJson.AddPair('id_cliente', TJSONNumber.Create(Orcamento.id_pessoa));
          oJson.AddPair('cliente', TJSONString.Create(Orcamento.cliente.Value));
          oJson.AddPair('id_servico', TJSONNumber.Create(Orcamento.id_servico));
          oJson.AddPair('servico', TJSONString.Create(Orcamento.servico.Value));
          oJson.AddPair('info_adicionais', TJSONString.Create(Orcamento.info_adicionais));
          oJson.AddPair('urgente', TJSONBool.Create(Orcamento.urgente));
          oJson.AddPair('previsao_inicio', FormatDateTime('YYY-mm-dd', Orcamento.previsao_inicio));

          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Orcamento.dt_inc));
          if Orcamento.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Orcamento.dt_alt.Value))
          else
            oJson.AddPair('alterado_em', TJSONNull.Create);

          Res.Send<TJSONObject>(oJson).Status(200);
        end;
    end;
end;

class procedure TControllerOrcamentos.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('budget data not found');

  oJson := Req.Body<TJSONObject>;
  Try
    var
    IOrcamentos  := TIOrcamentos.New;
    IOrcamentos
      .id_pessoa(oJson.GetValue<Integer>('id_cliente'))
      .id_servico(oJson.GetValue<Integer>('id_servico'))
      .info_adicionais(oJson.GetValue<String>('info_adicionais'))
      .urgente(oJson.GetValue<Boolean>('urgente'))
      .previsao_inicio(oJson.GetValue<TDate>('previsao_inicio'))
     .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'budget registered successfull!');
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

class procedure TControllerOrcamentos.Put(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  Orcamento: Torcamentos;
  id: Integer;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'id budget not found');
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
          var
          IOrcamentos := TIOrcamentos.New;
          Orcamento := IOrcamentos.Build.ListById('id_orcamento', id,
            Orcamento).This;

          if (Orcamento = nil) Or (Orcamento.id_orcamento = 0) then
            begin
              oJson.AddPair('error', 'budget not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if Orcamento.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          oJson := Req.Body<TJSONObject>;
          IOrcamentos.Build.Modify(Orcamento);
          Orcamento.id_pessoa := oJson.GetValue<Integer>('id_cliente');
          Orcamento.id_servico := oJson.GetValue<Integer>('id_servico');
          Orcamento.info_adicionais := oJson.GetValue<String>('info_adicionais');
          Orcamento.urgente := oJson.GetValue<Boolean>('urgente');
          Orcamento.previsao_inicio := oJson.GetValue<TDate>('previsao_inicio');
          Orcamento.dt_alt := now();
          IOrcamentos.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'budget changed successfull!');
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

class procedure TControllerOrcamentos.Registry;
begin
  THorse.Get('api/v1/orcamentos', GetAll)
        .Get('api/v1/orcamentos/:id', GetOne)
        .Post('api/v1/orcamentos', Post)
        .Put('api/v1/orcamentos/:id', Put)
        .Delete('api/v1/orcamentos/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerOrcamentos)

end.
