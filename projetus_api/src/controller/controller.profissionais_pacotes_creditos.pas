unit controller.profissionais_pacotes_creditos;

interface

uses
  Horse,
  Horse.Commons,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  System.StrUtils,
  System.DateUtils,
  System.Math,
  Data.DB,
  DBClient,

  Horse.GBSwagger.Register,
  Horse.GBSwagger.Controller,
  GBSwagger.Path.Attributes,

  uRotinas,

  model.pacotes_creditos,
  model.profissionais_pacotes_creditos,
  model.api.message,
  controller.dto.pacotes_creditos.interfaces,
  controller.dto.pacotes_creditos.interfaces.impl,
  controller.dto.profissionais_pacotes_creditos.interfaces,
  controller.dto.profissionais_pacotes_creditos.interfaces.impl;

type
  [SwagPath('v1', 'Profissionais Pacotes de Créditos')]
  TControllerProfissionalPacoteCredito = class
    class procedure Registry;

    [SwagGet('profissionais-pacotes-creditos', 'Retorna listagem de profissionais e seus pacotes de créditos')]
    [SwagResponse(200, Tprofissionais_pacotes_creditos, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamQuery('profissional', 'Nome do profissional', False, False)]
    [SwagParamQuery('id_pessoa', 'ID do profissional', False, False)]
    [SwagParamQuery('id_pacote_credito', 'ID do pacote de crédito', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('profissionais-pacotes-creditos/:id', 'Retorna dados de um profissional e seu pacote de crédito')]
    [SwagResponse(200, Tprofissionais_pacotes_creditos, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Credit packs professional not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('profissionais-pacotes-creditos', 'Associa um pacote de crédito a um profissional')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Tprofissionais_pacotes_creditos)]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('profissionais-pacotes-creditos/:id', 'Atualiza dados de um profissional e seu pacote de crédito')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Credit packs professional not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('profissionais-pacotes-creditos/:id/delete', 'Apaga registro de um pacote de crédito')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Credit packs professional not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerProfissionalPacoteCredito }

class procedure TControllerProfissionalPacoteCredito.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'id professional credit packs not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IProfissionalPacoteCredito := TIProfissionalPacoteCredito.New;
  var
  ProfissionalPacoteCredito: Tprofissionais_pacotes_creditos;

  ProfissionalPacoteCredito := IProfissionalPacoteCredito.Build.ListById('id_profissional_pacote_credito', id, ProfissionalPacoteCredito).This;

  if ProfissionalPacoteCredito = nil then
    begin
      oJson.AddPair('error', 'service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if ProfissionalPacoteCredito.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'deleted record');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IProfissionalPacoteCredito.Build.Modify(ProfissionalPacoteCredito);
  ProfissionalPacoteCredito.dt_del := now();
  IProfissionalPacoteCredito.Build.Update;

  oJson.AddPair('message', 'professional credit packs successfully deleted');
  Res.Send<TJSONObject>(oJson).Status(404);
end;

class procedure TControllerProfissionalPacoteCredito.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  ProfissionaisPacotesCreditos: TObjectList<Tprofissionais_pacotes_creditos>;
  ProfissionalPacoteCredito: Tprofissionais_pacotes_creditos;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  profissional,id_pessoa,id_pacote_credito,page,perPage,filter,records: String;
  totalPages: Integer;
begin
  Try
    var
    IProfissionalPacoteCredito := TIProfissionalPacoteCredito.New;
    profissional := Req.Query['profissional'];
    id_pessoa := Req.Query['id_pessoa'];
    id_pacote_credito := Req.Query['id_pacote_credito'];
    page := Req.Query['page'];
    perPage := Req.Query['perPage'];

    filter := 'profissionais_pacotes_creditos.dt_del is null';
    if profissional <> EmptyStr then
      filter := filter + ' AND profissional LIKE '+QuotedStr('%'+profissional+'%');

    if id_pessoa <> EmptyStr then
      filter := filter + ' AND id_pessoa = '+id_pessoa;

    if id_pacote_credito <> EmptyStr then
      filter := filter + ' AND id_pacote_credito = '+id_pacote_credito;

    if page = EmptyStr then
      page := '1';

    if perPage = EmptyStr then
      perPage := '10';

    var registros: Integer;
    IProfissionalPacoteCredito.Build.GetRecordsNumber('profissionais_pacotes_creditos', filter, registros);
    totalPages := Ceil(registros / perPage.ToInteger());
    records := IntToStr(registros);

    IProfissionalPacoteCredito.Build.ListPaginate(filter, ProfissionaisPacotesCreditos, 'id_profissional_pacote_credito',
      StrToInt(perPage), (StrToInt(perPage) * (StrToInt(page) - 1)));

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for ProfissionalPacoteCredito in ProfissionaisPacotesCreditos do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id', ProfissionalPacoteCredito.id_profissional_pacote_credito);
        oJson.AddPair('id_profissional', ProfissionalPacoteCredito.id_pessoa);
        oJson.AddPair('profissional', ProfissionalPacoteCredito.profissional);
        oJson.AddPair('id_pacote_credito', ProfissionalPacoteCredito.id_pacote_credito);
        oJson.AddPair('pacote', ProfissionalPacoteCredito.pacote);
        oJson.AddPair('dias_expiracao', ProfissionalPacoteCredito.dias_expirar);
        oJson.AddPair('data_validade', FormatDateTime('dd/mm/YYYY',ProfissionalPacoteCredito.data_validade));

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalPacoteCredito.dt_inc));
        if ProfissionalPacoteCredito.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalPacoteCredito.dt_alt.Value))
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

class procedure TControllerProfissionalPacoteCredito.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'id professional credit packs not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IProfissionalPacoteCredito := TIProfissionalPacoteCredito.New;
  var
  ProfissionalPacoteCredito: Tprofissionais_pacotes_creditos;

  IProfissionalPacoteCredito.Build.ListById('id_profissional_pacote_credito',
    id, ProfissionalPacoteCredito);
  if ProfissionalPacoteCredito = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'professional credit packs not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    begin
      if ProfissionalPacoteCredito.dt_del.HasValue then
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('message', 'professional credit packs not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end
      else
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('id', ProfissionalPacoteCredito.id_profissional_pacote_credito);
          oJson.AddPair('id_profissional', ProfissionalPacoteCredito.id_pessoa);
          oJson.AddPair('profissional', ProfissionalPacoteCredito.profissional);
          oJson.AddPair('id_pacote_credito', ProfissionalPacoteCredito.id_pacote_credito);
          oJson.AddPair('pacote', ProfissionalPacoteCredito.pacote);
          oJson.AddPair('dias_expiracao', ProfissionalPacoteCredito.dias_expirar);
          oJson.AddPair('data_validade', FormatDateTime('dd/mm/YYYY',ProfissionalPacoteCredito.data_validade));

          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalPacoteCredito.dt_inc));
          if ProfissionalPacoteCredito.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalPacoteCredito.dt_alt.Value))
          else
            oJson.AddPair('alterado_em', TJSONNull.Create);

          Res.Send<TJSONObject>(oJson).Status(200);
        end;
    end;
end;

class procedure TControllerProfissionalPacoteCredito.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  PacoteCredito: Tpacotes_creditos;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('credit packs data not found');

  oJson := Req.Body<TJSONObject>;
  Try
    var
    IPacoteCreditos := TIPacoteCreditos.New;
    PacoteCredito := IPacoteCreditos.Build.ListById('id_pacote_credito',
    oJson.GetValue<Integer>('id_pacote_credito'), PacoteCredito).This;

    var
    IProfissionalPacoteCredito := TIProfissionalPacoteCredito.New;
    IProfissionalPacoteCredito
      .id_pessoa(oJson.GetValue<Integer>('id_profissional'))
      .id_pacote_credito(oJson.GetValue<Integer>('id_pacote_credito'))
      .data_validade(IncDay(now,PacoteCredito.dias_expiracao))
     .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'professional credit packs registered successfull!');
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

class procedure TControllerProfissionalPacoteCredito.Put(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  ProfissionalPacoteCredito: Tprofissionais_pacotes_creditos;
  id: Integer;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'id professional credit packs not found');
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
          IProfissionalPacoteCredito := TIProfissionalPacoteCredito.New;
          ProfissionalPacoteCredito := IProfissionalPacoteCredito
            .Build.ListById('id_profissional_pacote_credito',
              id, ProfissionalPacoteCredito).This;

          if (ProfissionalPacoteCredito = nil) Or
            (ProfissionalPacoteCredito.id_profissional_pacote_credito = 0) then
            begin
              oJson.AddPair('error', 'professional credit packs not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if ProfissionalPacoteCredito.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          oJson := Req.Body<TJSONObject>;
          IProfissionalPacoteCredito.Build.Modify(ProfissionalPacoteCredito);
          With ProfissionalPacoteCredito do
            Begin
              id_pacote_credito := oJson.GetValue<Integer>('id_pacote_credito');
              data_validade := StrToDate(oJson.GetValue<String>('data_validade'));
              dt_alt := now();
            End;
          IProfissionalPacoteCredito.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'professional credit packs changed successfull!');
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

class procedure TControllerProfissionalPacoteCredito.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
        .Get('/profissionais-pacotes-creditos', GetAll)
        .Get('/profissionais-pacotes-creditos/:id', GetOne)
        .Post('/profissionais-pacotes-creditos', Post)
        .Put('/profissionais-pacotes-creditos/:id', Put)
        .Delete('/profissionais-pacotes-creditos/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerProfissionalPacoteCredito)

end.
