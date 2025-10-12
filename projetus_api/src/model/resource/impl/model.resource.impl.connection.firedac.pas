unit model.resource.impl.connection.firedac;

interface

uses
  System.SysUtils,

  firedac.UI.Intf,

  firedac.Stan.Intf,
  firedac.Stan.Option,
  firedac.Stan.Error,
  firedac.Stan.Def,
  firedac.Stan.Pool,
  firedac.Stan.Async,
  firedac.Stan.ExprFuncs,
  firedac.Stan.Param,

  firedac.Phys,
  firedac.Phys.Intf,
  firedac.Phys.PG,
  firedac.Phys.PGDef,
  firedac.Phys.PGWrapper,

//  firedac.Phys.MySQL,
//  firedac.Phys.MySQLDef,
//  firedac.Phys.MySQLWrapper,

  firedac.DatS,

  {$IF Defined(HAS_VCL)}
  firedac.VCLUI.Wait,
  {$ENDIF}

  firedac.Comp.Client,
  firedac.Comp.UI,
  firedac.Comp.DataSet,

  firedac.DApt,
  firedac.DApt.Intf,

  Data.DB,
  model.resource.interfaces;

type
  TConnection = class(TInterfacedObject, IConnection)
  private
    FConfiguration: IConfiguration;
    FConn: TFDConnection;
    FDPhysPGDriverLink: TFDPhysPGDriverLink;
//    FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
  public
    constructor Create(Configuration: IConfiguration);
    destructor Destroy; override;
    class function New(Configuration: IConfiguration): IConnection;

    function Connect: TCustomConnection;
  end;

implementation

{ TConnection }

function TConnection.Connect: TCustomConnection;
begin
  try
    FConn.Params.DriverID := FConfiguration.DriverID;
    FConn.Params.Database := FConfiguration.Database;
    FConn.Params.UserName := FConfiguration.UserName;
    FConn.Params.Password := FConfiguration.Password;
    FConn.Params.Add('Port=' + FConfiguration.Port);
    FConn.Params.Add('Server=' + FConfiguration.Server);

    if not FConfiguration.Schema.IsEmpty then
    begin
      FConn.Params.Add('MetaCurSchema=' + FConfiguration.Schema);
      FConn.Params.Add('MetaDefSchema=' + FConfiguration.Schema);
    end;

    FConn.Connected := True;
    Result := FConn;
  except
    On e: Exception do
      raise Exception.Create(#13'Não foi possível realizar a conexão. ' +
        e.Message);
  end;
end;

constructor TConnection.Create(Configuration: IConfiguration);
begin
  FConn := TFDConnection.Create(nil);
  FDPhysPGDriverLink := TFDPhysPGDriverLink.Create(nil);
//  FDPhysMySQLDriverLink := TFDPhysMySQLDriverLink.Create(nil);
{$IFDEF MSWINDOWS}
  FDPhysPGDriverLink.VendorLib := GetCurrentDir + '\libpq.dll';
//  FDPhysMySQLDriverLink.VendorLib := GetCurrentDir + '\libmysql.dll';
{$ENDIF}
  FConfiguration := Configuration;
end;

destructor TConnection.Destroy;
begin
  FreeAndNil(FDPhysPGDriverLink);
//  FreeAndNil(FDPhysMySQLDriverLink);
  FreeAndNil(FConn);
  inherited;
end;

class function TConnection.New(Configuration: IConfiguration): IConnection;
begin
  Result := Self.Create(Configuration);
end;

end.
