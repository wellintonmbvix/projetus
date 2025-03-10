unit model.historico_orcamentos;

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
  [Table('historico_orcamentos', '')]
  [PrimaryKey('id_historico_orcamento', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('historico_orcamentos_id_historico_orcamento_seq')]
  [OrderBy('id_historico_orcamento')]
  Thistorico_orcamentos = class
  private
    { Private declarations } 
    Fid_historico_orcamento: Integer;
    Fid_orcamento: Integer;
    Fid_pessoa: Integer;
    Fstatus: String;
    Fdt_inc: TDateTime;
    Fdt_alt: Nullable<TDateTime>;
    Fdt_del: Nullable<TDateTime>;
  public 
    { Public declarations } 
    constructor Create;
    destructor Destroy; override;

    [Column('id_historico_orcamento', ftInteger)]
    [Dictionary('id_historico_orcamento', 'Mensagem de validação', '', '', '', taCenter)]
    property id_historico_orcamento: Integer read Fid_historico_orcamento write Fid_historico_orcamento;

    [Column('id_orcamento', ftInteger)]
    [ForeignKey('fk_historico_orcamentos_orcamentos', 'id_orcamento', 'orcamentos', 'id_orcamento', SetNull, SetNull)]
    [Dictionary('id_orcamento', 'Mensagem de validação', '', '', '', taCenter)]
    property id_orcamento: Integer read Fid_orcamento write Fid_orcamento;

    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_historico_orcamentos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [Column('status', ftString, 30)]
    [Dictionary('status', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property status: String read Fstatus write Fstatus;

    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('dt_inc', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [Column('dt_alt', ftDateTime)]
    [Dictionary('dt_alt', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [Column('dt_del', ftDateTime)]
    [Dictionary('dt_del', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_del: nullable<TDateTime> read Fdt_del write Fdt_del;
  end;

implementation

constructor Thistorico_orcamentos.Create;
begin
  //
end;

destructor Thistorico_orcamentos.Destroy;
begin
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Thistorico_orcamentos)

end.
