unit controller.historico_creditos;

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

  model.historico_creditos,
  controller.dto.historico_creditos.interfaces,
  controller.dto.historico_creditos.interfaces.impl;

type
  TControllerHistoricoCreditos = class
    class procedure Registry;
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ THistoricoCreditos }

class procedure TControllerHistoricoCreditos.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
begin
   oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
        oJson.AddPair('error', 'credit history id not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IHistoricoCreditos := TIHistoricoCreditos.New;
  var
  HistoricoCreditos: Thistorico_creditos;

  HistoricoCreditos := IHistoricoCreditos.Build.ListById('id_historico_credito',
    id, HistoricoCreditos).This;

  if HistoricoCreditos = nil then
    begin
      oJson.AddPair('error', 'credit history not found');
      Res.Send<TJSONObject>(oJson).Status(404);
      Exit;
    end
    else
      if HistoricoCreditos.dt_del.HasValue then
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'deleted record');
          Res.Send<TJSONObject>(oJson).Status(200);
          Exit;
        end;

  IHistoricoCreditos.Build.Modify(HistoricoCreditos);
  HistoricoCreditos.dt_del := now();
  IHistoricoCreditos.Build.Update;

  oJson.AddPair('message', 'successfully credit history deleted');
  Res.Send<TJSONObject>(oJson).Status(404);
end;

class procedure TControllerHistoricoCreditos.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  HistoricosCreditos: TObjectList<Thistorico_creditos>;
  HistoricoCreditos: Thistorico_creditos;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,page,perPage,filter,records: String;
  totalPages: Integer;
begin
  Try
    var
    IHistoricoCreditos := TIHistoricoCreditos.New;
    nome := Req.Query['pessoa'];
    page := Req.Query['page'];
    perPage := Req.Query['perPage'];

    filter := 'historico_creditos.dt_del is null AND tipo_pessoa="P"';
    if nome <> EmptyStr then
      filter := filter + ' AND pessoa LIKE '+QuotedStr('%'+nome+'%');

    if page = EmptyStr then
      page := '1';

    if perPage = EmptyStr then
      perPage := '10';

    var registros: Integer;
    IHistoricoCreditos.Build.GetRecordsNumber('historico_creditos', filter, registros);
    totalPages := Ceil(registros / perPage.ToInteger());
    records := IntToStr(registros);

    IHistoricoCreditos.Build.ListPaginate(filter, HistoricosCreditos,
    'id_historico_credito', StrToInt(perPage),
      (StrToInt(perPage) * (StrToInt(page) - 1)));

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for HistoricoCreditos in HistoricosCreditos do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id_historico_credito',
          TJSONNumber.Create(HistoricoCreditos.id_historico_credito));
        oJson.AddPair('id_pessoa',
          TJSONNumber.Create(HistoricoCreditos.id_pessoa));
        oJson.AddPair('pessoa',
          TJSONString.Create(HistoricoCreditos.pessoa.Value));
//        oJson.AddPair('tipo_pessoa',
//          TJSONString.Create(HistoricoCreditos.tipo_pessoa.Value));
        oJson.AddPair('credito',
          TJSONNumber.Create(HistoricoCreditos.credito));
        if HistoricoCreditos.status = 'U' then
          oJson.AddPair('status',
            TJSONString.Create('Utilizado'))
        else
          oJson.AddPair('status',
            TJSONString.Create('Obtido'));

        oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz',
          HistoricoCreditos.dt_inc));
        if HistoricoCreditos.dt_alt.HasValue then
          oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', HistoricoCreditos.dt_alt.Value))
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

class procedure TControllerHistoricoCreditos.GetOne(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
begin
  if Req.Params.Count = 0 then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('error', 'credit history id not found');
      Res.Send<TJSONObject>(oJson).Status(500);
      Exit;
    end
  else
    id := Req.Params.Items['id'].ToInteger();

  var
  IHistoricoServicos := TIHistoricoCreditos.New;
  var
  HistoricoCreditos: Thistorico_creditos;

  IHistoricoServicos.Build.ListById('id_historico_credito', id, HistoricoCreditos);
  if HistoricoCreditos = nil then
    begin
      var oJson := TJSONObject.Create;
        oJson.AddPair('message', 'service not found');
      Res.Send<TJSONObject>(oJson).Status(404);
    end
  else
    begin
      if HistoricoCreditos.dt_del.HasValue then
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('message', 'service not found');
          Res.Send<TJSONObject>(oJson).Status(404);
        end
      else
        begin
          var oJson := TJSONObject.Create;
          oJson.AddPair('id_historico_credito',
            TJSONNumber.Create(HistoricoCreditos.id_historico_credito));
          oJson.AddPair('id_pessoa',
            TJSONNumber.Create(HistoricoCreditos.id_pessoa));
          oJson.AddPair('pessoa',
            TJSONString.Create(HistoricoCreditos.pessoa.Value));
//          oJson.AddPair('tipo_pessoa',
//            TJSONString.Create(HistoricoCreditos.tipo_pessoa.Value));
          oJson.AddPair('credito',
            TJSONNumber.Create(HistoricoCreditos.credito));
          if HistoricoCreditos.status = 'U' then
            oJson.AddPair('status',
              TJSONString.Create('Utilizado'))
          else
            oJson.AddPair('status',
              TJSONString.Create('Obtido'));

          oJson.AddPair('criado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz',
            HistoricoCreditos.dt_inc));
          if HistoricoCreditos.dt_alt.HasValue then
            oJson.AddPair('alterado_em', FormatDateTime('YYY-mm-dd hh:mm:ss.zzz', HistoricoCreditos.dt_alt.Value))
          else
            oJson.AddPair('alterado_em', TJSONNull.Create);

          Res.Send<TJSONObject>(oJson).Status(200);
        end;
    end;
end;

class procedure TControllerHistoricoCreditos.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('credits history data not found');

  oJson := Req.Body<TJSONObject>;
  Try
    var
    IHistoricoCreditos := TIHistoricoCreditos.New;
    IHistoricoCreditos
      .id_pessoa(oJson.GetValue<Integer>('id_pessoa'))
      .credito(oJson.GetValue<Currency>('credito'))
      .status(IfThen(oJson.GetValue<String>('status') = 'Obtido', 'O', 'U'))
     .Build.Insert;

    oJson := TJSONObject.Create;
    oJson.AddPair('message', 'credits history registered successfull!');
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

class procedure TControllerHistoricoCreditos.Put(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  HistoricoCreditos: Thistorico_creditos;
  id: Integer;
begin
  oJson := TJSONObject.Create;
  if Req.Params.Count = 0 then
    begin
      oJson.AddPair('error', 'credits history id not found');
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
          IHistoricoCreditos := TIHistoricoCreditos.New;
          HistoricoCreditos := IHistoricoCreditos.Build.ListById('id_historico_credito', id, HistoricoCreditos).This;

          if (HistoricoCreditos = nil) Or (HistoricoCreditos.id_historico_credito = 0) then
            begin
              oJson.AddPair('error', 'service not found');
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end
          else
            if HistoricoCreditos.dt_del.HasValue then
              begin
                oJson := TJSONObject.Create;
                oJson.AddPair('message', 'deleted record');
                Res.Send<TJSONObject>(oJson).Status(404);
                Exit;
              end;

          oJson := Req.Body<TJSONObject>;
          IHistoricoCreditos.Build.Modify(HistoricoCreditos);
          With HistoricoCreditos Do
            begin
              id_pessoa := oJson.GetValue<Integer>('id_pessoa');
              credito := oJson.GetValue<Currency>('credito');
              status := IfThen(oJson.GetValue<String>('status') = 'Obtido', 'O', 'U');
              dt_alt := now();
            end;
          IHistoricoCreditos.Build.Update;
          oJson := TJSONObject.Create;
          oJson.AddPair('message', 'credits history changed successfull!');
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

class procedure TControllerHistoricoCreditos.Registry;
begin
  THorse.Get('api/v1/historico-creditos', GetAll)
        .Get('api/v1/historico-creditos/:id', GetOne)
        .Post('api/v1/historico-creditos', Post)
        .Put('api/v1/historico-creditos/:id', Put)
        .Delete('api/v1/historico-creditos/:id/delete', Delete);
end;

end.
