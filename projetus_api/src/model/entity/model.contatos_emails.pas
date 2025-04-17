unit model.contatos_emails;

interface

uses
  DB, 
  Classes, 
  SysUtils, 
  Generics.Collections,

  GBSwagger.Model.Attributes,

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
  [PrimaryKey('id_contato_email', TAutoIncType.AutoInc,
                                  TGeneratorType.NoneInc,
                                  TSortingOrder.NoSort,
                                  True, 'Chave primária')]
  [Sequence('contatos_emails_id_contato_email_seq')]
  [OrderBy('id_contato_email')]
  Tcontatos_emails = class
  private
    { Private declarations }
    Fid_contato_email: nullable<Integer>;
    Fid_contato: Integer;
    Femails: String;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [SwagIgnore]
    [Column('id_contato_email', ftInteger)]
    [Dictionary('id_contato_email', 'Mensagem de validação', '', '', '', taCenter)]
    property id_contato_email: nullable<Integer> read Fid_contato_email write Fid_contato_email;

    [SwagIgnore]
    [Restrictions([TRestriction.NotNull])]
    [Column('id_contato', ftInteger)]
    [ForeignKey('fk_contatos_emails_contatos', 'id_contato', 'contatos', 'id_contato', Cascade, Cascade)]
    [Dictionary('id_contato', 'Mensagem de validação', '', '', '', taCenter)]
    property id_contato: Integer read Fid_contato write Fid_contato;

    [SwagProp('emails', 'StringArray ex.: ["***@***"]', False, False)]
    [Column('emails', ftMemo)]
    [Dictionary('Emails', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property emails: String read Femails write Femails;

    [SwagIgnore]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('Data Inclusão', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [SwagIgnore]
    [Column('dt_alt', ftDateTime)]
    [Dictionary('Data Alteração', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [SwagIgnore]
    [Column('dt_del', ftDateTime)]
    [Dictionary('Data Deleção', 'Mensagem de validação', 'Now', '',
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
