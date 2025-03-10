unit model.pacotes_creditos;

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
  [Table('pacotes_creditos', '')]
  [PrimaryKey('id_pacote_credito', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('pacotes_creditos_id_pacote_credito_seq')]
  [OrderBy('id_pacote_credito')]
  Tpacotes_creditos = class
  private
    { Private declarations } 
    Fid_pacote_credito: Integer;
    Fnome: String;
    Fcreditos: Integer;
    Fvalor_compra: Double;
    Fdias_expiracao: Integer;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
  public 
    { Public declarations } 
    [Column('id_pacote_credito', ftInteger)]
    [Dictionary('id_pacote_credito', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pacote_credito: Integer read Fid_pacote_credito write Fid_pacote_credito;

    [Column('nome', ftString, 60)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: String read Fnome write Fnome;

    [Column('creditos', ftInteger)]
    [Dictionary('creditos', 'Mensagem de validação', '', '', '', taCenter)]
    property creditos: Integer read Fcreditos write Fcreditos;

    [Column('valor_compra', ftBCD)]
    [Dictionary('valor_compra', 'Mensagem de validação', '0', '', '', taRightJustify)]
    property valor_compra: Double read Fvalor_compra write Fvalor_compra;

    [Column('dias_expiracao', ftInteger)]
    [Dictionary('dias_expiracao', 'Mensagem de validação', '', '', '', taCenter)]
    property dias_expiracao: Integer read Fdias_expiracao write Fdias_expiracao;

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

initialization
  TRegisterClass.RegisterEntity(Tpacotes_creditos)

end.
