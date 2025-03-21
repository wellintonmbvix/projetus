unit model.historico_creditos;

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
  [Table('historico_creditos', '')]
  [PrimaryKey('id_historico_credito', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave prim�ria')]
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
  public 
    { Public declarations } 
    constructor Create;
    destructor Destroy; override;

    [Column('id_historico_credito', ftInteger)]
    [Dictionary('id_historico_credito', 'Mensagem de valida��o', '', '', '', taCenter)]
    property id_historico_credito: Integer read Fid_historico_credito write Fid_historico_credito;

    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_historico_creditos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de valida��o', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [Column('credito', ftBCD)]
    [Dictionary('credito', 'Mensagem de valida��o', '0', '', '', taRightJustify)]
    property credito: Double read Fcredito write Fcredito;

    [Column('status', ftString, 1)]
    [Dictionary('status', 'Mensagem de valida��o', 'U', '', '', taLeftJustify)]
    property status: String read Fstatus write Fstatus;

    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('dt_inc', 'Mensagem de valida��o', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [Column('dt_alt', ftDateTime)]
    [Dictionary('dt_alt', 'Mensagem de valida��o', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [Column('dt_del', ftDateTime)]
    [Dictionary('dt_del', 'Mensagem de valida��o', 'Now', '',
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
