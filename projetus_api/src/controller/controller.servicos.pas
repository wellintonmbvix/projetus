unit controller.servicos;

interface

uses
  Horse,
  Horse.JWT,
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

  model.servicos,
  model.api.message,
  controller.dto.servicos.interfaces,
  controller.dto.servicos.interfaces.impl;

type
  [SwagPath('v1', 'Serviços')]
  TControllerServicos = class(THorseGBSwagger)
    class procedure Registry;

    [SwagGet('servicos', 'Retorna listagem de serviços')]
    [SwagResponse(200, Tservicos, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamQuery('nome', 'Nome do serviço', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('servicos/:id', 'Retorna dados de um serviço')]
    [SwagResponse(200, Tservicos, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Service not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('servicos', 'Registra um novo serviço')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Tservicos)]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('servicos/:id', 'Atualiza dados de um serviço')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Service not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('servicos/:id/delete', 'Apaga registro de um serviço')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Service not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;


implementation

{ TControllerServicos }

class procedure TControllerServicos.Delete(Req: THorseRequest;
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
  IServico := TIServicos.New;
  var
  Servico: Tservicos;

  Servico := IServico.Build.ListById('id_servico', id, Servico).This;

  if Servico = nil then
    begin
      oJson.AddPair('error', 'service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if Servico.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'record has already been deleted');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IServico.Build.Modify(Servico);
  Servico.dt_del := now();
  IServico.Build.Update;

  oJson.AddPair('message', 'successfully service deleted');
  Res.Send<TJSONObject>(oJson).Status(200);
end;

class procedure TControllerServicos.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  Servicos: TObjectList<Tservicos>;
  Servico: Tservicos;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,page,perPage,filter,records: String;
  totalPages: Integer;
begin
  Try
    var
    IServicos := TIServicos.New;
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
    IServicos.Build.GetRecordsNumber('servicos', filter, registros);
    totalPages := Ceil(registros / perPage.ToInteger());
    records := IntToStr(registros);

    IServicos.Build.ListPaginate(filter, Servicos, 'id_servico',
      StrToInt(perPage), (StrToInt(perPage) * (StrToInt(page) - 1)));

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for Servico in Servicos do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id_servico', Servico.id_servico.ToString);
        oJson.AddPair('nome', Servico.nome);

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Servico.dt_inc));
        if Servico.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Servico.dt_alt.Value))
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

class procedure TControllerServicos.GetOne(Req: THorseRequest;
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
  IServicos := TIServicos.New;
  var
  Servico: Tservicos;

  IServicos.Build.ListById('id_servico', id, Servico);
  if Servico = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    begin
      if Servico.dt_del.HasValue then
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('message', 'service not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end
      else
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('id_servico', Servico.id_servico.ToString);
          oJson.AddPair('nome', Servico.nome);
          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Servico.dt_inc));
          if Servico.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', Servico.dt_alt.Value))
          else
            oJson.AddPair('alterado_em', TJSONNull.Create);

          Res.Send<TJSONObject>(oJson).Status(200);
        end;
    end;
end;

class procedure TControllerServicos.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('service data not found');

  oJson := Req.Body<TJSONObject>;
  Try
    var
    IServicos  := TIServicos.New;
    IServicos
      .nome(oJson.GetValue<String>('nome'))
     .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'service registered successfull!');
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

class procedure TControllerServicos.Put(Req: THorseRequest; Res: THorseResponse;
  Next: TProc);
var
  oJson: TJSONObject;
  Servico: Tservicos;
  id: Integer;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'id service not found');
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
          IServicos := TIServicos.New;
          Servico := IServicos.Build.ListById('id_servico', id, Servico).This;

          if (Servico = nil) Or (Servico.id_servico = 0) then
            begin
              oJson.AddPair('error', 'service not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if Servico.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          oJson := Req.Body<TJSONObject>;
          IServicos.Build.Modify(Servico);
          Servico.nome := oJson.GetValue<String>('nome');
          Servico.dt_alt := now();
          IServicos.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'service changed successfull!');
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

class procedure TControllerServicos.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
        .Get('/servicos', GetAll)
        .Get('/servicos/:id', GetOne)
        .Post('/servicos', Post)
        .Put('/servicos/:id', Put)
        .Delete('/servicos/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerServicos)

end.
