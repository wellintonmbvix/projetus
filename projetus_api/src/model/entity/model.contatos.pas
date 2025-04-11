unit model.contatos;

interface

uses
  DB, 
  Classes, 
  SysUtils, 
  Generics.Collections,

  GBSwagger.Model.Attributes,

  model.contatos_emails,
  model.contatos_telefones,

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
  [Table('contatos', '')]
  [PrimaryKey('id_contato',TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('contatos_id_contato_seq')]
  [OrderBy('id_pessoa')]
  Tcontatos = class
  private
    { Private declarations } 
    Fid_contato: Integer;
    Fid_pessoa: Integer;
    Fnome: String;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
    Fcontatos_telefones: Tcontatos_telefones;
    Fcontatos_emails: Tcontatos_emails;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [SwagIgnore]
    [Column('id_contato', ftInteger)]
    [Dictionary('id_contato', 'Mensagem de validação', '', '', '', taCenter)]
    property id_contato: Integer read Fid_contato write Fid_contato;

    [SwagIgnore]
    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_contatos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [SwagString(60, 1)]
    [SwagRequired]
    [Column('nome', ftString, 60)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: String read Fnome write Fnome;

    [SwagIgnore]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('dt_inc', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [SwagIgnore]
    [Column('dt_alt', ftDateTime)]
    [Dictionary('dt_alt', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [SwagIgnore]
    [Column('dt_del', ftDateTime)]
    [Dictionary('dt_del', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_del: nullable<TDateTime> read Fdt_del write Fdt_del;

    [Association(TMultiplicity.OneToOne, 'id_contato', 'contatos_telefones', 'id_contato')]
    [CascadeActions([TCascadeAction.CascadeAutoInc,
                     TCascadeAction.CascadeInsert,
                     TCascadeAction.CascadeUpdate,
                     TCascadeAction.CascadeDelete])]
    property contatos_telefones: Tcontatos_telefones read Fcontatos_telefones write Fcontatos_telefones;

    [Association(TMultiplicity.OneToOne, 'id_contato', 'contatos_emails', 'id_contato')]
    [CascadeActions([TCascadeAction.CascadeAutoInc,
                     TCascadeAction.CascadeInsert,
                     TCascadeAction.CascadeUpdate,
                     TCascadeAction.CascadeDelete])]
    property contatos_emails: Tcontatos_emails read Fcontatos_emails write Fcontatos_emails;
  end;

implementation

constructor Tcontatos.Create;
begin
  Fcontatos_telefones := Tcontatos_telefones.Create;
  Fcontatos_emails := Tcontatos_emails.Create;
end;

destructor Tcontatos.Destroy;
begin
  FreeAndNil(Fcontatos_telefones);
  FreeAndNil(Fcontatos_emails);
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Tcontatos)

end.
