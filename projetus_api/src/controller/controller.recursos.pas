unit controller.recursos;

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

  model.estados,
  model.municipios,
  model.api.message,

  middleware.authmiddleware,

  controller.dto.estados.interfaces,
  controller.dto.estados.interfaces.impl;

type
  [SwagPath('v1', 'Recursos')]
  TControllerRecursos = class(THorseGBSwagger)
    class procedure Registry;

    [SwagGet('estados', 'Retorna listagem de estados')]
    [SwagResponse(200, Testados, 'Retorno com sucesso', True)]
    [SwagResponse(400, TAPIMessage, 'Bad Request')]
    [SwagResponse(500, TAPIMessage, 'Internal Server Error')]
    [SwagParamQuery('nome', 'Nome do estado', False, False)]
    [SwagParamQuery('sigel', 'Sigla do estado', False, False)]
    class procedure GetEstados(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TControllerRecursos }

class procedure TControllerRecursos.GetEstados(Req: THorseRequest;
  Res: THorseResponse; Next: TProc);
var
  estados: TObjectList<Testados>;
  estado: Testados;
  aJson: TJSONArray;
  oJsonResult,
  oJson: TJSONObject;
  nome,sigla,id,filter,records: String;
begin
  Try
    var
    IEstados := TIEstados.New;
    nome := Req.Query['nome'];
    sigla := Req.Query['sigla'];
    id := Req.Query['id'];

    filter := '1=1';
    if id <> EmptyStr then
      filter := filter + ' AND id_estado = ' + id;

    if nome <> EmptyStr then
      filter := filter + ' AND nome LIKE '+QuotedStr('%'+nome+'%');

    if sigla <> EmptyStr then
      filter := filter + ' AND sigla LIKE '+QuotedStr('%'+sigla+'%');

    IEstados.Build.ListAll(filter,estados,'sigla');

    oJsonResult := TJSONObject.Create;
    aJson := TJSONArray.Create;

    for estado in estados do
      begin
        oJson := TJSONObject.Create;
        oJson.AddPair('id_estado', estado.id_estado);
        oJson.AddPair('nome', estado.nome);
        oJson.AddPair('sigla', estado.sigla);

        var municipio: Tmunicipios;
        var amunicipio := TJSONArray.Create;
        var omunicipio: TJSONObject;

        for municipio in estado.municipios do
          begin
            omunicipio := TJSONObject.Create;
            omunicipio.AddPair('id_municipio', municipio.id_municipio);
            omunicipio.AddPair('municipio', municipio.nome);

            amunicipio.AddElement(omunicipio);
          end;
        oJson.AddPair('municipios', amunicipio);

        aJson.AddElement(oJson);
      end;

    oJsonResult.AddPair('data', aJson);
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

class procedure TControllerRecursos.Registry;
begin
  THorse
    .Group
      .Prefix('api/v1/recursos')
        .Get('/estados', GetEstados);
end;

initialization

THorseGBSwaggerRegister.RegisterPath(TControllerRecursos)

end.
