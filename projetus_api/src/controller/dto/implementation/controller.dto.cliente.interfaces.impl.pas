unit controller.dto.cliente.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.cliente.interfaces,
  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces.impl,
  model.service.interfaces,
  model.cliente,
  model.contato;

type
  TICliente = class(TInterfacedObject, ICliente)
    private
    FEntity: Tcliente;
    FService: IService<Tcliente>;
    public
    constructor Create;
    destructor Destroy; override;
    class function New: ICliente;

    function id_cliente(value: Integer): ICliente; overload;
    function id_cliente: Integer; overload;

    function nome(value: String): ICliente; overload;
    function nome: String; overload;

    function contato(value: TClientDataSet): ICliente; overload;
    function contato: TClientDataSet; overload;

    function Build: IService<Tcliente>;
  end;

implementation

{ TICliente }

function TICliente.Build: IService<Tcliente>;
begin
  Result := FService;
end;

function TICliente.contato: TClientDataSet;
var
  clienteDataSet: TClientDataSet;
begin
  clienteDataSet := TClientDataSet.Create(nil);
  clienteDataSet.FieldDefs.Add('contato_nome', ftString, 60);
  clienteDataSet.CreateDataSet;

  for var i := 0 to FEntity.contato.Count - 1 do
      begin
        clienteDataSet.Append;
        clienteDataSet.FieldByName('contato_nome').AsString := FEntity.contato.Items[i].contato_nome;
        clienteDataSet.Post;
      end;

  Result := clienteDataSet;
end;

function TICliente.contato(value: TClientDataSet): ICliente;
var
  clienteDataSet: TClientDataSet;
begin
  Result := Self;
  FEntity.contato.Add(Tcontato.Create);
  With FEntity.contato.Last Do
    begin
      contato_nome := value.FieldByName('contato_nome').AsString;
    end;
end;

constructor TICliente.Create;
begin
  FEntity := Tcliente.Create;
  FService := TServiceORMBr<Tcliente>.New(FEntity);
end;

destructor TICliente.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TICliente.id_cliente(value: Integer): ICliente;
begin
  Result := Self;
  FEntity.id_cliente := value;
end;

function TICliente.id_cliente: Integer;
begin
  Result := FEntity.id_cliente;
end;

class function TICliente.New: ICliente;
begin
  Result := Self.Create;
end;

function TICliente.nome(value: String): ICliente;
begin
  Result := Self;
  FEntity.nome := value;
end;

function TICliente.nome: String;
begin
  Result := FEntity.nome;
end;

end.
