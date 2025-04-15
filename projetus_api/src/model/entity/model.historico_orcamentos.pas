unit model.historico_orcamentos;

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
    Fcliente: nullable<String>;
    Ftipo_pessoa: nullable<String>;
  public 
    { Public declarations } 
    constructor Create;
    destructor Destroy; override;

    [SwagProp('id', '', False, True)]
    [Column('id_historico_orcamento', ftInteger)]
    [Dictionary('id_historico_orcamento', 'Mensagem de validação', '', '', '', taCenter)]
    property id_historico_orcamento: Integer read Fid_historico_orcamento write Fid_historico_orcamento;

    [SwagRequired]
    [Column('id_orcamento', ftInteger)]
    [ForeignKey('fk_historico_orcamentos_orcamentos', 'id_orcamento', 'orcamentos', 'id_orcamento', SetNull, SetNull)]
    [Dictionary('id_orcamento', 'Mensagem de validação', '', '', '', taCenter)]
    property id_orcamento: Integer read Fid_orcamento write Fid_orcamento;

    [SwagProp('id_cliente', '', True, False)]
    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_historico_orcamentos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [SwagProp('cliente', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('cliente', ftString, 60)]
    [JoinColumn('id_pessoa', 'pessoas', 'id_pessoa', 'nome',
      TJoin.InnerJoin, 'cliente')]
    [Dictionary('cliente', '')]
    property cliente: nullable<String> read Fcliente write Fcliente;

    [SwagProp('tip_pessoa', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('tipo_pessoa', ftString, 1)]
    [JoinColumn('id_pessoa', 'pessoas', 'id_pessoa', 'tipo',
      TJoin.InnerJoin, 'tipo_pessoa')]
    [Dictionary('tipo_pessoa', '')]
    property tipo_pessoa: nullable<String> read Ftipo_pessoa write Ftipo_pessoa;

    [SwagRequired]
    [Column('status', ftString, 30)]
    [Dictionary('status', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property status: String read Fstatus write Fstatus;

    [SwagProp('dt_inc', '', False, True)]
    [SwagDate('YYYY-mm-dd hh:mm:ss')]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('dt_inc', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [SwagProp('dt_alt', '', False, True)]
    [SwagDate('YYYY-mm-dd hh:mm:ss')]
    [Column('dt_alt', ftDateTime)]
    [Dictionary('dt_alt', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [SwagProp('dt_del', '', False, True)]
    [SwagDate('YYYY-mm-dd hh:mm:ss')]
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
