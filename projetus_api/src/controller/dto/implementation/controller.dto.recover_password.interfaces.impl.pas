unit controller.dto.recover_password.interfaces.impl;

interface

uses
  controller.dto.recover_password.interfaces,

  model.service.scripts.interfaces,
  model.service.scripts.interfaces.impl,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper;

type
  TIRecoverPassword = class(TInterfacedObject, IRecoverPassword)
  private
    FServiceScript: IServiceScripts;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IRecoverPassword;

    function Manufacture: IServiceScripts;
  end;

implementation

{ TIRecoverPassword }

constructor TIRecoverPassword.Create;
begin
  FServiceScript := TServiceScripts.New;
end;

destructor TIRecoverPassword.Destroy;
begin
  inherited;
end;

function TIRecoverPassword.Manufacture: IServiceScripts;
begin
  Result := FServiceScript;
end;

class function TIRecoverPassword.New: IRecoverPassword;
begin
  Result := Self.Create;
end;

end.
