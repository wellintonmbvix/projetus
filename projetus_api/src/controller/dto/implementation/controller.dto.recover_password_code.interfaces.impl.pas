unit controller.dto.recover_password_code.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  DBClient,

  controller.dto.recover_password_code.interfaces,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.recover_password_codes;

type
  TIRecoverPasswordCodes = class(TInterfacedObject, IRecoverPasswordCodes)
  private
    FEntity: Trecover_password_code;
    FService: IService<Trecover_password_code>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IRecoverPasswordCodes;

    function code(value: String): IRecoverPasswordCodes; overload;
    function code: String; overload;

    function username(value: String): IRecoverPasswordCodes; overload;
    function username: String; overload;

    function date_expiration(value: TDateTime): IRecoverPasswordCodes; overload;
    function date_expiration: TDateTime; overload;

    function Build: IService<Trecover_password_code>;
  end;

implementation

{ TIRecoverPasswordCodes }

function TIRecoverPasswordCodes.Build: IService<Trecover_password_code>;
begin
  Result := FService;
end;

function TIRecoverPasswordCodes.code(value: String): IRecoverPasswordCodes;
begin
  Result := Self;
  FEntity.code := value;
end;

function TIRecoverPasswordCodes.code: String;
begin
  Result := FEntity.code;
end;

constructor TIRecoverPasswordCodes.Create;
begin
  FEntity := Trecover_password_code.Create;
  FService := TServiceORMBr<Trecover_password_code>.New(FEntity);
end;

function TIRecoverPasswordCodes.date_expiration(
  value: TDateTime): IRecoverPasswordCodes;
begin
  Result := Self;
  FEntity.date_expiration := value;
end;

function TIRecoverPasswordCodes.date_expiration: TDateTime;
begin
  Result := FEntity.date_expiration;
end;

destructor TIRecoverPasswordCodes.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

class function TIRecoverPasswordCodes.New: IRecoverPasswordCodes;
begin
  Result := Self.Create;
end;

function TIRecoverPasswordCodes.username(value: String): IRecoverPasswordCodes;
begin
  Result := Self;
  FEntity.username := value;
end;

function TIRecoverPasswordCodes.username: String;
begin
  Result := FEntity.username;
end;

end.
