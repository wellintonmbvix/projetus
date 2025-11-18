unit controller.dto.estados.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.estados.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.estados;

type
  TIEstados = class(TInterfacedObject, IEstados)
  private
    FEntity: Testados;
    FService: IService<Testados>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IEstados;

    function Build: IService<Testados>;
  end;

implementation

{ TIEstados }

function TIEstados.Build: IService<Testados>;
begin
  Result := FService;
end;

constructor TIEstados.Create;
begin
  FEntity := Testados.Create;
  FService := TServiceORMBr<Testados>.New(FEntity);
end;

destructor TIEstados.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

class function TIEstados.New: IEstados;
begin
  Result := Self.Create;
end;

end.
