unit controller.historico_orcamentos;

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

  model.historico_orcamentos,
  model.api.message,
  controller.dto.historico_orcamentos.interfaces,
  controller.dto.historico_orcamentos.interfaces.impl;

type
  [SwagPath('v1', 'Histórico de Orçamentos')]
  TControllerHistoricoOrcamentos = class(THorseGBSwagger)
    class procedure Registry;

    [SwagGet('historico-orcamentos', 'Retorna listagem de histórico de orçamentos')]
    [SwagResponse(200, Thistorico_orcamentos, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamQuery('nome', 'Nome do cliente', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('historico-orcamentos/:id', 'Retorna dados um único histórico de orçamento')]
    [SwagResponse(200, Thistorico_orcamentos, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('historico-orcamentos', 'Regista um novo histórico')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Thistorico_orcamentos)]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('historico-orcamentos/:id', 'Atualiza dados de um histórico')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('historico-orcamentos/:id/delete', 'Apaga registro de um histórico')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerHistoricoOrcamentos }

class procedure TControllerHistoricoOrcamentos.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'budget history id not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IHistoricoOrcamentos := TIHistoricoOrcamentos.New;
  var
  HistoricoOrcamentos: Thistorico_orcamentos;

  HistoricoOrcamentos := IHistoricoOrcamentos.Build.ListById('id_historico_orcamento',
    id, HistoricoOrcamentos).This;

  if HistoricoOrcamentos = nil then
    begin
      oJson.AddPair('error', 'budget history not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if HistoricoOrcamentos.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('error', 'deleted record');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IHistoricoOrcamentos.Build.Modify(HistoricoOrcamentos);
  HistoricoOrcamentos.dt_del := now();
  IHistoricoOrcamentos.Build.Update;

  oJson.AddPair('success', 'successfully budget history deleted');
  Res.Send<TJSONObject>(oJson).Status(200);
end;

class procedure TControllerHistoricoOrcamentos.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  HistoricosOrcamentos: TObjectList<Thistorico_orcamentos>;
  HistoricoOrcamentos: Thistorico_orcamentos;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,page,perPage,filter,records: String;
  totalPages: Integer;
begin
  Try
    var
    IHistoricoOrcamentos := TIHistoricoOrcamentos.New;
    nome := Req.Query['cliente'];
    page := Req.Query['page'];
    perPage := Req.Query['perPage'];

    filter := 'historico_orcamentos.dt_del is null';
    if nome <> EmptyStr then
      filter := filter + ' AND pessoa LIKE '+QuotedStr('%'+nome+'%');

    if page = EmptyStr then
      page := '1';

    if perPage = EmptyStr then
      perPage := '10';

    var registros: Integer;
    IHistoricoOrcamentos.Build.GetRecordsNumber('historico_orcamentos', filter, registros);
    totalPages := Ceil(registros / perPage.ToInteger());
    records := IntToStr(registros);

    IHistoricoOrcamentos.Build.ListPaginate(filter, HistoricosOrcamentos,
    'id_historico_orcamento', StrToInt(perPage),
      (StrToInt(perPage) * (StrToInt(page) - 1)));

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for HistoricoOrcamentos in HistoricosOrcamentos do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id',
          TJSONNumber.Create(HistoricoOrcamentos.id_historico_orcamento));
        oJson.AddPair('orcamento',
          TJSONNumber.Create(HistoricoOrcamentos.id_orcamento));
        oJson.AddPair('id_cliente',
          TJSONNumber.Create(HistoricoOrcamentos.id_pessoa));
        oJson.AddPair('cliente',
          TJSONString.Create(HistoricoOrcamentos.cliente.Value));
        oJson.AddPair('status',
          TJSONString.Create(HistoricoOrcamentos.status));

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz',
          HistoricoOrcamentos.dt_inc));
        if HistoricoOrcamentos.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', HistoricoOrcamentos.dt_alt.Value))
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

class procedure TControllerHistoricoOrcamentos.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'budget history id not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IHistoricoOrcamentos := TIHistoricoOrcamentos.New;
  var
  HistoricoOrcamentos: Thistorico_orcamentos;

  IHistoricoOrcamentos.Build.ListById('id_historico_orcamento', id,
    HistoricoOrcamentos);
  if HistoricoOrcamentos = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'budget history not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    begin
      if HistoricoOrcamentos.dt_del.HasValue then
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('message', 'budget not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end
      else
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('id',
            TJSONNumber.Create(HistoricoOrcamentos.id_historico_orcamento));
          oJson.AddPair('orcamento',
            TJSONNumber.Create(HistoricoOrcamentos.id_orcamento));
          oJson.AddPair('id_cliente',
            TJSONNumber.Create(HistoricoOrcamentos.id_pessoa));
          oJson.AddPair('cliente',
            TJSONString.Create(HistoricoOrcamentos.cliente.Value));
          oJson.AddPair('status',
            TJSONString.Create(HistoricoOrcamentos.status));

          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz',
            HistoricoOrcamentos.dt_inc));
          if HistoricoOrcamentos.dt_alt.HasValue then
            oJson.AddPair('alterado_em',
              FormatDateTime('YYY-mm-dd hh:mm:ss.zzz',
                HistoricoOrcamentos.dt_alt.Value))
          else
            oJson.AddPair('alterado_em', TJSONNull.Create);

          Res.Send<TJSONObject>(oJson).Status(200);
        end;
    end;
end;

class procedure TControllerHistoricoOrcamentos.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('budget history data not found');

  oJson := Req.Body<TJSONObject>;
  Try
    var
    IHistoricoOrcamentos := TIHistoricoOrcamentos.New;
    IHistoricoOrcamentos
      .id_orcamento(oJson.GetValue<Integer>('id_orcamento'))
      .id_pessoa(oJson.GetValue<Integer>('id_pessoa'))
      .status(oJson.GetValue<String>('status'))
     .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'budget history registered successfull!');
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

class procedure TControllerHistoricoOrcamentos.Put(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  HistoricoOrcamentos: Thistorico_orcamentos;
  id: Integer;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'budget history id not found');
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
          IHistoricoOrcamentos := TIHistoricoOrcamentos.New;
          HistoricoOrcamentos := IHistoricoOrcamentos.Build
            .ListById('id_historico_orcamento', id, HistoricoOrcamentos).This;

          if (HistoricoOrcamentos = nil) Or
            (HistoricoOrcamentos.id_historico_orcamento = 0) then
            begin
              oJson.AddPair('error', 'budget history not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if HistoricoOrcamentos.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          oJson := Req.Body<TJSONObject>;
          IHistoricoOrcamentos.Build.Modify(HistoricoOrcamentos);
          With HistoricoOrcamentos Do
            begin
              id_orcamento := oJson.GetValue<Integer>('id_orcamento');
              id_pessoa := oJson.GetValue<Integer>('id_pessoa');
              status := oJson.GetValue<String>('status');
              dt_alt := now();
            end;
          IHistoricoOrcamentos.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'budget history changed successfull!');
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

class procedure TControllerHistoricoOrcamentos.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
        .Get('/historico-orcamentos', GetAll)
        .Get('/historico-orcamentos/:id', GetOne)
        .Post('/historico-orcamentos', Post)
        .Put('/historico-orcamentos/:id', Put)
        .Delete('/historico-orcamentos/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerHistoricoOrcamentos)

end.
