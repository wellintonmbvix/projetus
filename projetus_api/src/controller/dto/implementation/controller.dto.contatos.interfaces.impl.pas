unit controller.dto.contatos.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  uRotinas,

  controller.dto.contatos.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.contatos;

type
  TIContatos = class(TInterfacedObject, IContatos)
  private
    FEntity: Tcontatos;
    FService: IService<Tcontatos>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IContatos;

    function Build: IService<Tcontatos>;
  end;

implementation

{ TIContatos }

function TIContatos.Build: IService<Tcontatos>;
begin
  Result := FService;
end;

constructor TIContatos.Create;
begin
  FEntity := Tcontatos.Create;
  FService := TServiceORMBr<Tcontatos>.New(FEntity);
end;

destructor TIContatos.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

class function TIContatos.New: IContatos;
begin
  Result := Self.Create;
end;

end.
