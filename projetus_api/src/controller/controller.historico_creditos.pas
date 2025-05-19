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

  Horse.JWT,
  Horse.GBSwagger.Register,
  Horse.GBSwagger.Controller,
  GBSwagger.Path.Attributes,

  uRotinas,

  model.historico_creditos,
  model.usuarios.claims,
  model.api.message,
  controller.dto.historico_creditos.interfaces,
  controller.dto.historico_creditos.interfaces.impl;

type
  [SwagPath('v1', 'Histórico de Créditos')]
  TControllerHistoricoCreditos = class(THorseGBSwagger)
    private
    public
    class procedure Registry;

    [SwagGet('historico-creditos', 'Retorna listagem de movimentações de créditos obtidos e utilizados')]
    [SwagResponse(200, Thistorico_creditos, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamQuery('nome', 'Nome do profissional', False, False)]
    class procedure GetAll(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagGet('historico-creditos/:id', 'Retorna dados de uma única movimentação')]
    [SwagResponse(200, Thistorico_creditos, 'Retorno com sucesso', False)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Credit history not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure GetOne(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPost('historico-creditos', 'Regista uma nova movimentação')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamBody('body', Thistorico_creditos)]
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagPut('historico-creditos/:id', 'Atualiza dados de uma movimentação de crédito')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Credit history not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    [SwagDelete('historico-creditos/:id/delete', 'Apaga registro de uma movimentação')]
    [SwagResponse(200, TAPIMessage)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(404, TAPIMessage, 'Credit history not found')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamPath('id', 'ID do Registro', True)]
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ THistoricoCreditos }

class procedure TControllerHistoricoCreditos.Delete(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  oJson : TJSONObject;
  id: Integer;
  Limpo: String;
  LClaims: Tusuarios_claims;
  regras: TStringList;
  regra_permitida: Boolean;
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

  LClaims := Req.Session<Tusuarios_claims>;
  Limpo := LClaims.regras;
  Limpo := StringReplace(Limpo, '[', '', [rfReplaceAll]);
  Limpo := StringReplace(Limpo, ']', '', [rfReplaceAll]);
  Limpo := StringReplace(Limpo, '"', '', [rfReplaceAll]);

  regras := TStringList.Create;
  regras.StrictDelimiter := True;
  regras.Delimiter := ',';
  regras.DelimitedText := Limpo;

  for var i := 0 to regras.Count - 1 do
    begin
      if regras[i] = 'administrador' then
        begin
          regra_permitida := True;
          break;
        end
      else if regras[i] = 'profissional' then
        begin
          regra_permitida := True;
          if LClaims.id_pessoa <> Req.Params.Items['id'] then
            id := StrToInt(LClaims.id_pessoa);
          break;
        end
      else
        regra_permitida := False;
    end;

  if regra_permitida then
    begin
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
              Res.Send<TJSONObject>(oJson).Status(404);
              Exit;
            end;

      IHistoricoCreditos.Build.Modify(HistoricoCreditos);
      HistoricoCreditos.dt_del := now();
      IHistoricoCreditos.Build.Update;

      oJson.AddPair('message', 'successfully credit history deleted');
      Res.Send<TJSONObject>(oJson).Status(200);
    end
  else
    begin
      oJson.AddPair('message',TJSONString.Create('invalid rule for this resource'));
      Res.Send<TJSONObject>(oJson).Status(403);
    end;
end;

class procedure TControllerHistoricoCreditos.GetAll(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  HistoricosCreditos: TObjectList<Thistorico_creditos>;
  HistoricoCreditos: Thistorico_creditos;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,page,perPage,filter,records,Limpo: String;
  totalPages: Integer;
  LClaims: Tusuarios_claims;
  regras: TStringList;
  regra_permitida: Boolean;
begin
  Try
    var
    IHistoricoCreditos := TIHistoricoCreditos.New;
    nome := Req.Query['pessoa'];
    page := Req.Query['page'];
    perPage := Req.Query['perPage'];

    LClaims := Req.Session<Tusuarios_claims>;
    Limpo := LClaims.regras;
    Limpo := StringReplace(Limpo, '[', '', [rfReplaceAll]);
    Limpo := StringReplace(Limpo, ']', '', [rfReplaceAll]);
    Limpo := StringReplace(Limpo, '"', '', [rfReplaceAll]);

    regras := TStringList.Create;
    regras.StrictDelimiter := True;
    regras.Delimiter := ',';
    regras.DelimitedText := Limpo;

    for var i := 0 to regras.Count - 1 do
      if (regras[i] = 'administrador') then
        begin
          regra_permitida := True;
          break;
        end
      else
        regra_permitida := False;

    if regra_permitida then
      begin
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
      end
    else
      begin
        oJsonResult := TJSONObject.Create;
        oJsonResult.AddPair('message',TJSONString.Create('invalid rule for this resource'));
        Res.Send<TJSONObject>(oJsonResult).Status(403);
      end;
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
  Limpo: String;
  LClaims: Tusuarios_claims;
  regras: TStringList;
  regra_permitida: Boolean;
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

  LClaims := Req.Session<Tusuarios_claims>;
  Limpo := LClaims.regras;
  Limpo := StringReplace(Limpo, '[', '', [rfReplaceAll]);
  Limpo := StringReplace(Limpo, ']', '', [rfReplaceAll]);
  Limpo := StringReplace(Limpo, '"', '', [rfReplaceAll]);

  regras := TStringList.Create;
  regras.StrictDelimiter := True;
  regras.Delimiter := ',';
  regras.DelimitedText := Limpo;

  for var i := 0 to regras.Count - 1 do
    begin
      if regras[i] = 'administrador' then
        begin
          regra_permitida := True;
          break;
        end
      else if regras[i] = 'profissional' then
        begin
          regra_permitida := True;
          if LClaims.id_pessoa <> Req.Params.Items['id'] then
            id := StrToInt(LClaims.id_pessoa);
          break;
        end
      else
        regra_permitida := False;
    end;

  if regra_permitida then
    begin
      var
      IHistoricoCreditos := TIHistoricoCreditos.New;
      var
      HistoricoCreditos: Thistorico_creditos;

      IHistoricoCreditos.Build.ListById('id_historico_credito', id, HistoricoCreditos);
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
    end
  else
    begin
      var oJson := TJSONObject.Create;
      oJson.AddPair('message',TJSONString.Create('invalid rule for this resource'));
      Res.Send<TJSONObject>(oJson).Status(403);
    end;
end;

class procedure TControllerHistoricoCreditos.Post(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  id: Integer;
  oJson: TJSONObject;
  filter,
  status,
  Limpo: String;
  LClaims: Tusuarios_claims;
  regras: TStringList;
  regra_permitida: Boolean;
  credito,
  saldo: Currency;
begin
  if Req.Body.IsEmpty then
    raise Exception.Create('credits history data not found');

  oJson := Req.Body<TJSONObject>;
  Try
    id := oJson.GetValue<Integer>('id_pessoa');

    LClaims := Req.Session<Tusuarios_claims>;
    Limpo := LClaims.regras;
    Limpo := StringReplace(Limpo, '[', '', [rfReplaceAll]);
    Limpo := StringReplace(Limpo, ']', '', [rfReplaceAll]);
    Limpo := StringReplace(Limpo, '"', '', [rfReplaceAll]);

    regras := TStringList.Create;
    regras.StrictDelimiter := True;
    regras.Delimiter := ',';
    regras.DelimitedText := Limpo;

    for var i := 0 to regras.Count - 1 do
      begin
        if regras[i] = 'administrador' then
          begin
            regra_permitida := True;
            break;
          end
        else if regras[i] = 'profissional' then
          begin
            regra_permitida := True;
            if LClaims.id_pessoa <> id.ToString then
              id := StrToInt(LClaims.id_pessoa);
            break;
          end
        else
          regra_permitida := False;
      end;

    if regra_permitida then
      begin
        var
        IHistoricoCreditos := TIHistoricoCreditos.New;
        var
        HistoricoCreditos: TObjectList<Thistorico_creditos>;
        var
        HistoricoCredito: Thistorico_creditos;

        filter := 'historico_creditos.dt_del is null AND historico_creditos.id_pessoa='+id.ToString;
        IHistoricoCreditos.Build.ListAll(filter,HistoricoCreditos,'id_historico_credito');

        for HistoricoCredito In HistoricoCreditos do
          begin
            if HistoricoCredito.status = 'O' then
              saldo := saldo + HistoricoCredito.credito
            else
              saldo := saldo + (HistoricoCredito.credito * -1)
          end;

        status := IfThen(oJson.GetValue<String>('status') = 'Obtido', 'O', 'U');
        credito := oJson.GetValue<Currency>('credito');

        if (status = 'U') And ((saldo < oJson.GetValue<Currency>('credito')) Or
        (saldo <= 0)) then
          begin
            oJson := TJSONObject.Create;
            oJson.AddPair('message', 'insufficient balance to complete the transaction.');
            oJson.AddPair('required_balance',TJSONNumber.Create(credito));
            oJson.AddPair('current_balance',TJSONNumber.Create(saldo));
            Res.Send<TJSONObject>(oJson).Status(400);
          end
        else
          begin
            IHistoricoCreditos
              .id_pessoa(id)
              .credito(credito)
              .status(status)
             .Build.Insert;

            oJson := TJSONObject.Create;
            oJson.AddPair('message', 'credits history registered successfull!');
            Res.Send<TJSONObject>(oJson).Status(200);
          end;
      end
    else
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('message',TJSONString.Create('invalid rule for this resource'));
        Res.Send<TJSONObject>(oJson).Status(403);
      end;
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
  filter,
  Limpo: String;
  LClaims: Tusuarios_claims;
  regras: TStringList;
  regra_permitida: Boolean;
  saldo: Currency;
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

        LClaims := Req.Session<Tusuarios_claims>;
        Limpo := LClaims.regras;
        Limpo := StringReplace(Limpo, '[', '', [rfReplaceAll]);
        Limpo := StringReplace(Limpo, ']', '', [rfReplaceAll]);
        Limpo := StringReplace(Limpo, '"', '', [rfReplaceAll]);

        regras := TStringList.Create;
        regras.StrictDelimiter := True;
        regras.Delimiter := ',';
        regras.DelimitedText := Limpo;

        for var i := 0 to regras.Count - 1 do
          begin
            if regras[i] = 'administrador' then
              begin
                regra_permitida := True;
                break;
              end
            else if regras[i] = 'profissional' then
              begin
                regra_permitida := True;
                if LClaims.id_pessoa <> Req.Params.Items['id'] then
                  id := StrToInt(LClaims.id_pessoa);
                break;
              end
            else
              regra_permitida := False;
          end;

        if regra_permitida then
          begin
            Try
              var
              IHistoricoCreditos := TIHistoricoCreditos.New;
              var
              HistoricosCreditos: TObjectList<Thistorico_creditos>;
              filter := 'historico_creditos.dt_del is null and historico_creditos.id_pessoa='+id.ToString;
              IHistoricoCreditos.Build.ListAll(filter,HistoricosCreditos,'');

              for HistoricoCreditos In HistoricosCreditos do
                begin
                  if HistoricoCreditos.status = 'U' then
                    saldo := saldo + (HistoricoCreditos.credito * -1)
                  else
                    saldo := saldo + HistoricoCreditos.credito;
                end;

              if (oJson.GetValue<String>('status') = 'Utilizado')
                And ((saldo < oJson.GetValue<Currency>('credito')) Or
                (saldo <= 0)) then
                  begin
                    oJson := TJSONObject.Create;
                    oJson.AddPair('message', 'insufficient balance to complete the transaction.');
                    oJson.AddPair('required_balance',TJSONNumber.Create(oJson.GetValue<Currency>('credito')));
                    oJson.AddPair('current_balance',TJSONNumber.Create(saldo));
                    Res.Send<TJSONObject>(oJson).Status(400);
                  end
                else
                  begin
                    HistoricoCreditos := IHistoricoCreditos.Build
                      .ListById('id_historico_credito', id,
                        HistoricoCreditos).This;

                    if (HistoricoCreditos = nil) Or
                      (HistoricoCreditos.id_historico_credito = 0) then
                      begin
                        oJson.AddPair('error', 'credits history not found');
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
                  end;
            Except
              on E: Exception Do
                begin
                  oJson := TJSONObject.Create;
                  oJson.AddPair('error', E.Message);
                  Res.Send<TJSONObject>(oJson).Status(500);
                end;
            End;
          end
        else
          begin
            oJson := TJSONObject.Create;
            oJson.AddPair('message',TJSONString.Create('invalid rule for this resource'));
            Res.Send<TJSONObject>(oJson).Status(403);
          end;
      end;
end;

class procedure TControllerHistoricoCreditos.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1')
        .AddCallback(HorseJWT(JWTPassword, THorseJWTConfig.New.SessionClass(Tusuarios_claims)))
          .Get('/historico-creditos', GetAll)
        .AddCallback(HorseJWT(JWTPassword, THorseJWTConfig.New.SessionClass(Tusuarios_claims)))
          .Get('/historico-creditos/:id', GetOne)
        .AddCallback(HorseJWT(JWTPassword, THorseJWTConfig.New.SessionClass(Tusuarios_claims)))
          .Post('/historico-creditos', Post)
        .AddCallback(HorseJWT(JWTPassword, THorseJWTConfig.New.SessionClass(Tusuarios_claims)))
          .Put('/historico-creditos/:id', Put)
        .AddCallback(HorseJWT(JWTPassword, THorseJWTConfig.New.SessionClass(Tusuarios_claims)))
          .Delete('/historico-creditos/:id/delete', Delete);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerHistoricoCreditos)

end.
