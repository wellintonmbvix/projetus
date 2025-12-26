unit model.recover_password_codes;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,

  GBSwagger.model.Attributes,

  // ormbr
  ormbr.types.blob,
  ormbr.types.lazy,
  ormbr.objects.helper,
  dbcbr.types.mapping,
  ormbr.types.nullable,
  dbcbr.mapping.Classes,
  dbcbr.mapping.register,
  dbcbr.mapping.Attributes;

type

  [Entity]
  [Table('recover_password_codes', '')]
  [PrimaryKey('code;username', TAutoIncType.NotInc,
                               TGeneratorType.NoneInc,
                               TSortingOrder.NoSort,
                               True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('username;code')]
  Trecover_password_code = class
  private
    Fcode: String;
    Fdate_expiration: TDateTime;
    Fusername: String;
  public
    constructor Create;
    destructor Destroy; override;

    [SwagString(5, 1)]
    [SwagRequired]
    [Column('code', ftString, 5)]
    [Dictionary('code', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property code: String read Fcode write Fcode;

    [SwagString(4, 1)]
    [SwagRequired]
    [Column('username', ftString, 40)]
    [Dictionary('username', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property userName: String read Fusername write Fusername;

    [SwagProp('date_expiration', '', False, True)]
    [SwagDate('YYYY-mm-dd hh:mm:ss')]
    [Column('date_expiration', ftDateTime)]
    [Dictionary('date_expiration', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property date_expiration: TDateTime read Fdate_expiration write Fdate_expiration;
  end;

implementation

{ Trequest_password_code }

constructor Trecover_password_code.Create;
begin
  //
end;

destructor Trecover_password_code.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Trecover_password_code)

end.
