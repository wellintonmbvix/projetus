unit model.pessoa;

interface

uses
  DB, 
  Classes, 
  SysUtils, 
  Generics.Collections,

  GBSwagger.Model.Attributes,

  model.endereco,
  model.contatos,
  model.dados_pessoais,

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
  [Table('pessoas', '')]
  [PrimaryKey('id_pessoa', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('pessoas_id_pessoa_seq')]
  [OrderBy('id_pessoa')]
  Tpessoas = class
  private
    { Private declarations } 
    Fid_pessoa: Integer;
    Fnome: String;
    Ftipo: String;
    Fsuspenso: Boolean;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
    Fendereco: Tenderecos;
    Fcontatos: TObjectList<Tcontatos>;
    Fdados_pessoais: Tdados_pessoais;
  public
    constructor Create;
    destructor Destroy; override;

    { Public declarations }
    [SwagProp('id_pessoa', '', False, True)]
    [Column('id_pessoa', ftInteger)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [SwagString(60, 1)]
    [SwagRequired]
    [Column('nome', ftString, 60)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: String read Fnome write Fnome;

    [SwagIgnore]
    [Column('tipo', ftString, 1)]
    [Dictionary('tipo', 'Mensagem de validação', 'P', '', '', taLeftJustify)]
    property tipo: String read Ftipo write Ftipo;

    [SwagRequired]
    [Column('suspenso', ftBoolean)]
    [Dictionary('suspenso', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property suspenso: Boolean read Fsuspenso write Fsuspenso;

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

    [Association(TMultiplicity.OneToOne, 'id_pessoa', 'enderecos', 'id_pessoa')]
    [CascadeActions([TCascadeAction.CascadeAutoInc,
                     TCascadeAction.CascadeInsert,
                     TCascadeAction.CascadeUpdate,
                     TCascadeAction.CascadeDelete])]
    property endereco: Tenderecos read Fendereco write Fendereco;

    [SwagArray()]
    [Association(TMultiplicity.OneToMany, 'id_pessoa', 'contatos', 'id_pessoa')]
    [CascadeActions([TCascadeAction.CascadeAutoInc,
                     TCascadeAction.CascadeInsert,
                     TCascadeAction.CascadeUpdate,
                     TCascadeAction.CascadeDelete])]
    property contatos: TObjectList<Tcontatos> read Fcontatos write Fcontatos;

    [Association(TMultiplicity.OneToOne, 'id_pessoa', 'dados_pessoas', 'id_pessoa')]
    [CascadeActions([TCascadeAction.CascadeAutoInc,
                     TCascadeAction.CascadeInsert,
                     TCascadeAction.CascadeUpdate,
                     TCascadeAction.CascadeDelete])]
    property dados_pessoais: Tdados_pessoais read Fdados_pessoais write Fdados_pessoais;
  end;

implementation

{ Tpessoas }

constructor Tpessoas.Create;
begin
  Fendereco := Tenderecos.Create;
  Fcontatos := TObjectList<Tcontatos>.Create;
  Fdados_pessoais := Tdados_pessoais.Create;
end;

destructor Tpessoas.Destroy;
begin
  FreeAndNil(Fendereco);
  FreeAndNil(Fcontatos);
  FreeAndNil(Fdados_pessoais);
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Tpessoas)

end.
