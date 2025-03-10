unit model.resource.interfaces;

interface

uses
  Data.DB;

type
  IConnection = interface
    function Connect: TCustomConnection;
  end;

  IConfiguration = interface
    ['{64038F35-65D6-4C3C-ADD5-A1C9F579106E}']

    function DriverID(Value: String): IConfiguration; overload;
    function DriverID: String; overload;

    function Database(Value: String): IConfiguration; overload;
    function Database: String; overload;

    function Username(Value: String): IConfiguration; overload;
    function Username: String; overload;

    function Password(Value: String): IConfiguration; overload;
    function Password: String; overload;

    function Port(Value: String): IConfiguration; overload;
    function Port: String; overload;

    function Server(Value: String): IConfiguration; overload;
    function Server: String; overload;

    function Schema(Value: String): IConfiguration; overload;
    function Schema: String; overload;
  end;

  IResource = interface
    ['{A3CDCD21-E872-4345-9B3C-B86E3384A60F}']

    function Connection: IConnection;
    function Configuration: IConfiguration;
  end;

implementation

end.
