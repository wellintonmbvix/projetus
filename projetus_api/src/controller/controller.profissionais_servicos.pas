unit controller.profissionais_servicos;

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

  model.profissionais_servicos,
  controller.dto.profissionais_servicos.interfaces,
  controller.dto.profissionais_servicos.interfaces.impl;

type
  TControllerProfissionaisServicos = class
    class procedure Registry;
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerProfissionaisServicos }

class procedure TControllerProfissionaisServicos.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'professional service id not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IProfissionalServico := TIProfissionalServico.New;
  var
  ProfissionalServico: Tprofissionais_servicos;

  ProfissionalServico := IProfissionalServico.Build
    .ListById('id_profissional_servico', id, ProfissionalServico).This;

  if ProfissionalServico = nil then
    begin
      oJson.AddPair('error', 'professional service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if ProfissionalServico.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'deleted record');
          Res.Send<TJSONObject>(oJson).Status(404);
          Exit;
        end;

  IProfissionalServico.Build.Modify(ProfissionalServico);
  ProfissionalServico.dt_del := now();
  IProfissionalServico.Build.Update;

  oJson.AddPair('message', 'successfully professional service deleted');
  Res.Send<TJSONObject>(oJson).Status(404);
end;

class procedure TControllerProfissionaisServicos.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  ProfissionaisServicos: TObjectList<Tprofissionais_servicos>;
  ProfissionalServico: Tprofissionais_servicos;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  id_profissional,page,perPage,filter,records: String;
  totalPages: Integer;
begin
  Try
    var
    IProfissionalServico := TIProfissionalServico.New;
    id_profissional := Req.Query['id_profissional'];
    page := Req.Query['page'];
    perPage := Req.Query['perPage'];

    filter := 'dt_del is null';
    if id_profissional <> EmptyStr then
      filter := filter + ' AND id_pessoa = '+id_profissional;

    if page = EmptyStr then
      page := '1';

    if perPage = EmptyStr then
      perPage := '10';

    var registros: Integer;
    IProfissionalServico.Build.GetRecordsNumber('profissionais_servicos', filter, registros);
    totalPages := Ceil(registros / perPage.ToInteger());
    records := IntToStr(registros);

    IProfissionalServico.Build.ListPaginate(filter,
      ProfissionaisServicos, 'id_profissional_servico',
      StrToInt(perPage), (StrToInt(perPage) * (StrToInt(page) - 1)));

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for ProfissionalServico in ProfissionaisServicos do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id', ProfissionalServico.id_profissional_servico);
        oJson.AddPair('id_profissional', ProfissionalServico.id_pessoa);
        oJson.AddPair('id_servico', ProfissionalServico.id_servico);

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalServico.dt_inc));
        if ProfissionalServico.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalServico.dt_alt.Value))
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

class procedure TControllerProfissionaisServicos.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'professional service id not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IProfissionalServico := TIProfissionalServico.New;
  var
  ProfissionalServico: Tprofissionais_servicos;

  IProfissionalServico.Build.ListById('id_profissional_servico', id, ProfissionalServico);
  if ProfissionalServico = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'professional service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    begin
      if ProfissionalServico.dt_del.HasValue then
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('message', 'professional service not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end
      else
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('id', ProfissionalServico.id_profissional_servico);
          oJson.AddPair('id_profissional', ProfissionalServico.id_pessoa);
          oJson.AddPair('id_servico', ProfissionalServico.id_servico);
          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalServico.dt_inc));
          if ProfissionalServico.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', ProfissionalServico.dt_alt.Value))
          else
            oJson.AddPair('alterado_em', TJSONNull.Create);

          Res.Send<TJSONObject>(oJson).Status(200);
        end;
    end;
end;

class procedure TControllerProfissionaisServicos.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('professional service data not found');

  oJson := Req.Body<TJSONObject>;
  Try
    var
    IProfissionalServico := TIProfissionalServico.New;
    IProfissionalServico
      .id_pessoa(oJson.GetValue<Integer>('id_profissional'))
      .id_servico(oJson.GetValue<Integer>('id_servico'))
     .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'professional service registered successfull!');
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

class procedure TControllerProfissionaisServicos.Put(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  ProfissionalServico: Tprofissionais_servicos;
  id: Integer;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'professional service id not found');
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
          IProfissionalServico := TIProfissionalServico.New;
          ProfissionalServico := IProfissionalServico.Build
            .ListById('id_profissional_servico', id, ProfissionalServico).This;

          if (ProfissionalServico = nil) Or (ProfissionalServico.id_profissional_servico = 0) then
            begin
              oJson.AddPair('error', 'professional service not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if ProfissionalServico.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          oJson := Req.Body<TJSONObject>;
          IProfissionalServico.Build.Modify(ProfissionalServico);
          ProfissionalServico.id_servico := oJson.GetValue<Integer>('id_servico');
          ProfissionalServico.dt_alt := now();
          IProfissionalServico.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'professional service changed successfull!');
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

class procedure TControllerProfissionaisServicos.Registry;
begin
  THorse.Get('api/v1/profissionais-servicos', GetAll)
        .Get('api/v1/profissionais-servicos/:id', GetOne)
        .Post('api/v1/profissionais-servicos', Post)
        .Put('api/v1/profissionais-servicos/:id', Put)
        .Delete('api/v1/profissionais-servicos/:id/delete', Delete);
end;

end.
