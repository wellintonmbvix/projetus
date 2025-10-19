unit middleware.errorHandlerMiddleware;

interface

uses
  System.SysUtils, System.JSON, Horse;

  procedure ErrorHandlerMiddleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

type
  EAccessDenied = class(Exception);

procedure ErrorHandlerMiddleware(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  try
    Next();
  except
    on E: EAccessDenied do
    begin
      Res.Status(403).Send<TJSONObject>(
        TJSONObject.Create.AddPair('error', E.Message));
    end;
    on E: Exception do
    begin
      Res.Status(500).Send<TJSONObject>(
        TJSONObject.Create.AddPair('error', 'Erro interno: ' + E.Message));
    end;
  end;
end;

end.
