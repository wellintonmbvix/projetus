unit model.contatos_emails;

interface

uses
  DB, 
  Classes, 
  SysUtils, 
  Generics.Collections, 

  // ormbr
  ormbr.types.blob,
  ormbr.types.lazy,
  ormbr.objects.helper,
  dbcbr.types.mapping,
  ormbr.types.nullable,
  dbcbr.mapping.classes,
  dbcbr.mapping.register,
  dbcbr.mapping.attributes;

type
  [Entity]
  [Table('contatos_emails', '')]
  [PrimaryKey('id', TAutoIncType.NotInc,
                                  TGeneratorType.NoneInc,
                                  TSortingOrder.NoSort,
                                  True, 'Chave prim�ria')]
//  [Sequence('contatos_emails_id_contato_email_seq')]
  [OrderBy('id')]
  Tcontatos_emails = class
  private
    { Private declarations }
    Fid: nullable<String>;
    Fid_contato: Integer;
    Femail: String;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [Column('id', ftString, 38)]
    [Dictionary('id', 'Mensagem de valida��o', '', '', '', taCenter)]
    property id: nullable<String> read Fid write Fid;

    [Restrictions([TRestriction.NotNull])]
    [Column('id_contato', ftInteger)]
    [ForeignKey('fk_contatos_emails_contatos', 'id_contato', 'contatos', 'id_contato', Cascade, Cascade)]
    [Dictionary('id_contato', 'Mensagem de valida��o', '', '', '', taCenter)]
    property id_contato: Integer read Fid_contato write Fid_contato;

    [Column('email', ftString, 120)]
    [Dictionary('email', 'Mensagem de valida��o', '', '', '', taLeftJustify)]
    property email: String read Femail write Femail;

    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('Data Inclus�o', 'Mensagem de valida��o', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [Column('dt_alt', ftDateTime)]
    [Dictionary('Data Altera��o', 'Mensagem de valida��o', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [Column('dt_del', ftDateTime)]
    [Dictionary('Data Dele��o', 'Mensagem de valida��o', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_del: nullable<TDateTime> read Fdt_del write Fdt_del;
  end;

implementation

constructor Tcontatos_emails.Create;
begin
  //
end;

destructor Tcontatos_emails.Destroy;
begin
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Tcontatos_emails)

end.
