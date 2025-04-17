unit model.usuarios_regras;

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
  [Table('usuarios_regras', '')]
  [PrimaryKey('id_usuario_regra', TAutoIncType.AutoInc,
                                  TGeneratorType.SequenceInc,
                                  TSortingOrder.NoSort,
                                  True, 'Chave primária')]
  [Sequence('usuarios_regras_id_usuario_regra_seq')]
  [OrderBy('id_usuario_regra')]
  Tusuarios_regras = class
  private
    Fid_usuario_regra: Integer;
    Fid_usuario: Integer;
    Fid_regra: Integer;
    Fdt_alt: nullable<TDateTime>;
    Fdt_inc: TDateTime;
    Fdt_del: nullable<TDateTime>;
    Fregra: nullable<String>;

  public
    constructor Create;
    destructor Destroy; override;

    [SwagIgnore]
    [Column('id_usuario_regra', ftInteger)]
    [Dictionary('id_usuario_regra', 'Mensagem de validação', '', '', '',
      taCenter)]
    property id_usuario_regra: Integer read Fid_usuario_regra
      write Fid_usuario_regra;

    [SwagIgnore]
    [Column('id_usuario', ftInteger)]
    [Dictionary('id_usuario', 'Mensagem de validação', '', '', '', taCenter)]
    property id_usuario: Integer read Fid_usuario write Fid_usuario;

    [SwagRequired]
    [Column('id_regra', ftInteger)]
    [Dictionary('id_regra', 'Mensagem de validação', '', '', '', taCenter)]
    property id_regra: Integer read Fid_regra write Fid_regra;

    [SwagProp('regra', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('regra', ftString, 50)]
    [JoinColumn('id_regra', 'regras', 'id_regra', 'nome_regra',
      TJoin.InnerJoin, 'regra')]
    property regra: nullable<String> read Fregra write Fregra;

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

{ Tusuarios_regras }

constructor Tusuarios_regras.Create;
begin
  //
end;

destructor Tusuarios_regras.Destroy;
begin
  //
  inherited;
end;

end.
