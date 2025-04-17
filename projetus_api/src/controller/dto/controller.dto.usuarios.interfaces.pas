unit controller.dto.usuarios.interfaces;

interface

uses
  System.Generics.Collections,

  model.usuarios,
  model.usuarios_regras,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces,
  model.service.scripts.interfaces;

type
  IUsuario = interface
    ['{4983C745-4167-497C-8E23-114E3A3AF560}']

    function id_usuario(value: Integer): IUsuario; overload;
    function id_usuario: Integer; overload;

    function id_pessoa(value: Integer): IUsuario; overload;
    function id_pessoa: Integer; overload;

    function nome_usuario(value: String): IUsuario; overload;
    function nome_usuario: String; overload;

    function senha_hash(value: String): IUsuario; overload;
    function senha_hash: String; overload;

    function dt_alt(value: TDateTime): IUsuario; overload;
    function dt_alt: TDateTime; overload;

    function dt_del(value: TDateTime): IUsuario; overload;
    function dt_del: TDateTime; overload;

    function usuarios_regras(value: TObjectList<Tusuarios_regras>): IUsuario; overload;
    function usuarios_regras: TObjectList<Tusuarios_regras>; overload;

    function Build: IService<Tusuarios>;
  end;

implementation

end.
