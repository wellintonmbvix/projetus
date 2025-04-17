unit model.regras;

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
  [Table('regras', '')]
  [PrimaryKey('id_regra', TAutoIncType.AutoInc,
                          TGeneratorType.SequenceInc,
                          TSortingOrder.NoSort,
                          True, 'Chave primária')]
  [Sequence('regras_id_regra_seq')]
  [OrderBy('id_regra')]
  Tregras = class
  private
    Fid_regra: Integer;
    Fnome_regra: String;
    Fdt_alt: nullable<TDateTime>;
    Fdt_inc: TDateTime;
    Fdt_del: nullable<TDateTime>;

  public
    constructor Create;
    destructor Destroy; override;

    [SwagProp('id', '', False, True)]
    [Column('id_regra', ftInteger)]
    [Dictionary('id_regra', 'Mensagem de validação', '', '', '', taCenter)]
    property id_regra: Integer read Fid_regra write Fid_regra;

    [SwagString(50, 1)]
    [SwagRequired]
    [Column('nome_regra', ftString, 50)]
    [Dictionary('nome_regra', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property nome_regra: String read Fnome_regra write Fnome_regra;

    [SwagIgnore]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('dt_inc', 'Mensagem de validação', 'Now', '', '!##/##/####;1;_',
      taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [SwagIgnore]
    [Column('dt_alt', ftDateTime)]
    [Dictionary('dt_alt', 'Mensagem de validação', 'Now', '', '!##/##/####;1;_',
      taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [SwagIgnore]
    [Column('dt_del', ftDateTime)]
    [Dictionary('dt_del', 'Mensagem de validação', 'Now', '', '!##/##/####;1;_',
      taLeftJustify)]
    property dt_del: nullable<TDateTime> read Fdt_del write Fdt_del;
  end;

implementation

{ Tregras }

constructor Tregras.Create;
begin
  //
end;

destructor Tregras.Destroy;
begin
  //
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tregras)

end.
