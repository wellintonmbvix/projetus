unit model.servicos;

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
  [Table('servicos', '')]
  [PrimaryKey('id_servico', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('servicos_id_servico_seq')]
  [OrderBy('id_servico')]
  Tservicos = class
  private
    { Private declarations } 
    Fid_servico: Integer;
    Fnome: String;
    Fdt_inc: TDateTime;
    Fdt_alt: Nullable<TDateTime>;
    Fdt_del: Nullable<TDateTime>;
  public 
    { Public declarations }
    [SwagProp('id_servico', '', False, True)]
    [Column('id_servico', ftInteger)]
    [Dictionary('id_servico', 'Mensagem de validação', '', '', '', taCenter)]
    property id_servico: Integer read Fid_servico write Fid_servico;

    [SwagRequired]
    [SwagString(110)]
    [Column('nome', ftString, 110)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: String read Fnome write Fnome;

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

initialization
  TRegisterClass.RegisterEntity(Tservicos)

end.
