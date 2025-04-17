unit model.usuarios;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,

  GBSwagger.model.Attributes,

  model.usuarios_regras,

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
  [Table('usuarios', '')]
  [PrimaryKey('id_usuario', TAutoIncType.AutoInc,
                            TGeneratorType.SequenceInc,
                            TSortingOrder.NoSort,
                            True, 'Chave primária')]
  [Sequence('usuarios_id_usuario_seq')]
  [OrderBy('id_usuario')]
  Tusuarios = class
  private
    Fid_usuario: Integer;
    Fnome_usuario: String;
    Fsenha_hash: String;
    Fdt_alt: nullable<TDateTime>;
    Fdt_inc: TDateTime;
    Fdt_del: nullable<TDateTime>;
    Fid_pessoa: Integer;
    Fusuarios_regras: TObjectList<Tusuarios_regras>;

  public
    constructor Create;
    destructor Destroy; override;

    [SwagProp('id', '', False, True)]
    [Column('id_usuario', ftInteger)]
    [Dictionary('id_usuario', 'Mensagem de validação', '', '', '', taCenter)]
    property id_usuario: Integer read Fid_usuario write Fid_usuario;

    [SwagProp('id_pessoa', 'Campo preenchido automaticamente pelas rotas Cliente/Profissional', True, False)]
    [SwagNumber]
    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_usuarios_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [SwagString(50, 1)]
    [SwagRequired]
    [Column('nome_usuario', ftString, 50)]
    [Dictionary('nome_usuario', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property nome_usuario: String read Fnome_usuario write Fnome_usuario;

    [SwagString(120, 3)]
    [SwagProp('senha_usuario', '', True, False)]
    [Column('senha_hash', ftMemo)]
    [Dictionary('senha_hash', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property senha_hash: String read Fsenha_hash write Fsenha_hash;

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

    [SwagProp('regras', '', True, False)]
    [Association(TMultiplicity.OneToMany, 'id_usuario', 'usuarios_regras', 'id_usuario')]
    [CascadeActions([TCascadeAction.CascadeAutoInc,
                     TCascadeAction.CascadeInsert,
                     TCascadeAction.CascadeUpdate,
                     TCascadeAction.CascadeDelete])]
    property usuarios_regras: TObjectList<Tusuarios_regras> read Fusuarios_regras write Fusuarios_regras;
  end;

implementation

{ Tusuarios }

constructor Tusuarios.Create;
begin
  Fusuarios_regras := TObjectList<Tusuarios_regras>.Create;
end;

destructor Tusuarios.Destroy;
begin
  FreeAndNil(Fusuarios_regras);
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tusuarios)

end.
