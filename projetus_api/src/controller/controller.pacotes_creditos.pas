unit controller.pacotes_creditos;

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

  controller.dto.pacotes_creditos.interfaces,
  controller.dto.pacotes_creditos.interfaces.impl,

  model.pacotes_creditos,
  model.api.sucess,
  model.api.error;

type
  [SwagPath('v1', 'Pacote de Créditos')]
  TControllerPacotesCreditos = class(THorseGBSwagger)
    private
    public
    class procedure Registry;

    [SwagGet('pacotes-creditos', 'Retorna listagem de pacotes de créditos')]
    [SwagResponse(200, Tpacotes_creditos, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    [SwagParamQuery('nome', 'Nome do pacote de crédito', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('pacotes-creditos/:id', 'Retorna dados de um pacote de crédito')]
    [SwagResponse(200, Tpacotes_creditos, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(404, TAPIError, 'Credit packs not found')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('pacotes-creditos', 'Regista um novo pacote de créditos')]
    [SwagResponse(200, TAPISuccess)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    [SwagParamBody('pacotes-creditos', Tpacotes_creditos)]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('pacotes-creditos/:id', 'Atualiza dados de um pacote de créditos')]
    [SwagResponse(200, TAPISuccess)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(404, TAPIError, 'Credit packs not found')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('pacotes-creditos/:id/delete', 'Apaga registro de um pacote de crédito')]
    [SwagResponse(200, TAPISuccess)]
    [SwagResponse(400, TAPIError, 'Bad Request')]
    [SwagResponse(404, TAPIError, 'Credit packs not found')]
    [SwagResponse(500, TAPIError, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerPacotesCreditos }

class procedure TControllerPacotesCreditos.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'id credit packs not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IPacoteCredito := TIPacoteCreditos.New;
  var
  PacoteCredito: Tpacotes_creditos;

  PacoteCredito := IPacoteCredito.Build.ListById('id_pacote_credito',
    id, PacoteCredito).This;

  if PacoteCredito = nil then
    begin
      oJson.AddPair('error', 'credit packs not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if PacoteCredito.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'deleted record');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IPacoteCredito.Build.Modify(PacoteCredito);
  PacoteCredito.dt_del := now();
  IPacoteCredito.Build.Update;

  oJson.AddPair('message', 'successfully credit packs deleted');
  Res.Send<TJSONObject>(oJson).Status(404);
end;

class procedure TControllerPacotesCreditos.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  pacotes_creditos: TObjectList<Tpacotes_creditos>;
  pacote_credito: Tpacotes_creditos;
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
  pacotes: TClientDataSet;
begin
  Try
    Try
      var
      IPacoteCreditos := TIPacoteCreditos.New;
      nome := Req.Query['nome'];
      page := Req.Query['page'];
      perPage := Req.Query['perPage'];

      filter := 'dt_del is null';
      if nome <> EmptyStr then
        filter := filter + ' AND nome LIKE '+QuotedStr('%'+nome+'%');

      if page = EmptyStr then
        page := '1';

      if perPage = EmptyStr then
        perPage := '10';

      var registros: Integer;
      IPacoteCreditos.Build.GetRecordsNumber('pacotes_creditos', filter, registros);
      totalPages := Ceil(registros / perPage.ToInteger());
      records := IntToStr(registros);

      IPacoteCreditos.Build.ListPaginate(filter, pacotes_creditos,
      'id_pacote_credito', StrToInt(perPage), (StrToInt(perPage) *
        (StrToInt(page) - 1)));

      oJsonResult := TJSONObject.Create;
      aJson := TJSONArray.Create;
      for pacote_credito in pacotes_creditos do
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('id_pacote_credito', pacote_credito.id_pacote_credito.ToString);
          oJson.AddPair('nome', pacote_credito.nome);
          oJson.AddPair('creditos', pacote_credito.creditos.ToString);
          oJson.AddPair('valor_compra', FormatFloat('###,##0.00',pacote_credito.valor_compra));
          oJson.AddPair('dias_expiracao', pacote_credito.dias_expiracao.ToString());
          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', pacote_credito.dt_inc));
          if pacote_credito.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', pacote_credito.dt_alt.Value))
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
    pacotes_creditos.Clear;
    FreeAndNil(pacotes_creditos);
  End;
end;

class procedure TControllerPacotesCreditos.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'Id Pacote not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IPacoteCreditos := TIPacoteCreditos.New;
  var
  PacoteCredito: Tpacotes_creditos;

  IPacoteCreditos.Build.ListById('id_pacote_credito', id, PacoteCredito);

  if PacoteCredito = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'Pacote not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    if PacoteCredito.dt_del.HasValue then
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'Pacote not found');
        Res.Send<TJSONObject>(oJson).Status(404);
      end
    else
      begin
        var oJson := TJSONObject.Create;
        oJson.AddPair('id_pacote_credito', PacoteCredito.id_pacote_credito.ToString);
        oJson.AddPair('nome', PacoteCredito.nome);
        oJson.AddPair('creditos', PacoteCredito.creditos.ToString);
        oJson.AddPair('valor_compra', FormatFloat('###,##0.00',PacoteCredito.valor_compra));
        oJson.AddPair('dias_expiracao', PacoteCredito.dias_expiracao.ToString());
        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', PacoteCredito.dt_inc));
        if PacoteCredito.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', PacoteCredito.dt_alt.Value))
        else
          oJson.AddPair('alterado_em', TJSONNull.Create);

        Res.Send<TJSONObject>(oJson).Status(200);
      end;
end;

class procedure TControllerPacotesCreditos.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  msg: String;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('credit packs data not found');
  oJson := Req.Body<TJSONObject>;

  Try
    var IPacoteCreditos := TIPacoteCreditos.New;
    IPacoteCreditos
      .nome(oJson.GetValue<String>('nome'))
      .creditos(oJson.GetValue<Integer>('creditos'))
      .valor_compra(oJson.GetValue<Currency>('valor_compra'))
      .dias_expiracao(oJson.GetValue<Integer>('dias_expiracao'))
    .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'credit packs created successfully!');
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

class procedure TControllerPacotesCreditos.Put(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  PacoteCredito: Tpacotes_creditos;
  id: Integer;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'credit packs id not found');
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
          IPacoteCreditos := TIPacoteCreditos.New;
          PacoteCredito := IPacoteCreditos.Build.ListById('id_pacote_credito', id, PacoteCredito).This;

          if (PacoteCredito = nil) Or (PacoteCredito.id_pacote_credito = 0) then
            begin
              oJson.AddPair('error', 'credit packs not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if PacoteCredito.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          oJson := Req.Body<TJSONObject>;
          IPacoteCreditos.Build.Modify(PacoteCredito);
          With PacoteCredito Do
            begin
              nome := oJson.GetValue<String>('nome');
              creditos := oJson.GetValue<Integer>('creditos');
              valor_compra := oJson.GetValue<Currency>('valor_compra');
              dias_expiracao := oJson.GetValue<Integer>('dias_expiracao');
              dt_alt := now();
            end;

          IPacoteCreditos.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'credit packs changed successfull!');
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

class procedure TControllerPacotesCreditos.Registry;
begin
  THorse.Get('api/v1/pacotes-creditos', GetAll)
        .Get('api/v1/pacotes-creditos/:id', GetOne)
        .Post('api/v1/pacotes-creditos', Post)
        .Put('api/v1/pacotes-creditos/:id', Put)
        .Delete('api/v1/pacotes-creditos/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerPacotesCreditos)

end.
