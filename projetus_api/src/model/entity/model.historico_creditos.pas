unit model.historico_creditos;

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
  [Table('historico_creditos', '')]
  [PrimaryKey('id_historico_credito', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('historico_creditos_id_historico_credito_seq')]
  [OrderBy('id_historico_credito')]
  Thistorico_creditos = class
  private
    { Private declarations } 
    Fid_historico_credito: Integer;
    Fid_pessoa: Integer;
    Fcredito: Double;
    Fstatus: String;
    Fdt_inc: TDateTime;
    Fdt_alt: Nullable<TDateTime>;
    Fdt_del: Nullable<TDateTime>;
    Fpessoa: nullable<String>;
    Ftipo_pessoa: nullable<String>;
  public 
    { Public declarations } 
    constructor Create;
    destructor Destroy; override;

    [SwagProp('id', '', False, True)]
    [Column('id_historico_credito', ftInteger)]
    [Dictionary('id_historico_credito', 'Mensagem de validação', '', '', '', taCenter)]
    property id_historico_credito: Integer read Fid_historico_credito write Fid_historico_credito;

    [SwagProp('id_profissional', '', True, False)]
    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_historico_creditos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [SwagProp('profissional', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('pessoa', ftString, 60)]
    [JoinColumn('id_pessoa', 'pessoas', 'id_pessoa', 'nome',
      TJoin.InnerJoin, 'pessoa')]
    [Dictionary('pessoa', '')]
    property pessoa: nullable<String> read Fpessoa write Fpessoa;

    [SwagProp('tipo_pessoa', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('tipo_pessoa', ftString, 1)]
    [JoinColumn('id_pessoa', 'pessoas', 'id_pessoa', 'tipo',
      TJoin.InnerJoin, 'tipo_pessoa')]
    [Dictionary('tipo_pessoa', '')]
    property tipo_pessoa: nullable<String> read Ftipo_pessoa write Ftipo_pessoa;

    [SwagNumber]
    [SwagRequired]
    [Column('credito', ftBCD)]
    [Dictionary('credito', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property credito: Double read Fcredito write Fcredito;

    [SwagString(1)]
    [SwagRequired]
    [Column('status', ftString, 1)]
    [Dictionary('status', 'Mensagem de validação', 'U', '', '', taLeftJustify)]
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

constructor Thistorico_creditos.Create;
begin
  //
end;

destructor Thistorico_creditos.Destroy;
begin
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Thistorico_creditos)

end.
