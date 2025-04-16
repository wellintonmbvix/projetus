unit model.profissionais_pacotes_creditos;

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
  dbcbr.mapping.Classes,
  dbcbr.mapping.register,
  dbcbr.mapping.attributes;

type

  [Entity]
  [Table('profissionais_pacotes_creditos', '')]
  [PrimaryKey('id_profissional_pacote_credito', TAutoIncType.AutoInc,
                                        TGeneratorType.SequenceInc,
                                        TSortingOrder.NoSort,
                                        True, 'Chave primária')]
  [Sequence('profissionais_pacotes_creditos_id_profissional_pacote_seq')]
  [OrderBy('id_profissional_pacote_credito')]
  Tprofissionais_pacotes_creditos = class
  private
    { Private declarations }
    Fid_profissional_pacote_credito: Integer;
    Fid_pessoa: Integer;
    Fid_pacote_credito: Integer;
    Fdata_validade: TDateTime;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
    Fprofissional: nullable<String>;
    Fpacote: nullable<String>;
    Fdias_expirar: Integer;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [SwagProp('id', '', False, True)]
    [Column('id_profissional_pacote_credito', ftInteger)]
    [Dictionary('id_profissional_pacote_credito', 'Mensagem de validação', '', '', '',
      taCenter)]
    property id_profissional_pacote_credito: Integer read Fid_profissional_pacote_credito
      write Fid_profissional_pacote_credito;

    [SwagProp('id_profissional', '', True, False)]
    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_profissionais_pacotes_creditos_pessoas', 'id_pessoa',
      'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [SwagProp('profissional', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('profissional', ftString, 60)]
    [JoinColumn('id_pessoa', 'pessoas', 'id_pessoa', 'nome',
      TJoin.InnerJoin, 'profissional')]
    [Dictionary('profissional', '')]
    property profissional: nullable<String> read Fprofissional write Fprofissional;

    [SwagNumber]
    [SwagRequired]
    [Column('id_pacote_credito', ftInteger)]
    [ForeignKey('fk_profissionais_pacotes_creditos_pacotes_creditos',
      'id_pacote_credito', 'pacotes_creditos', 'id_pacote_credito',
      SetNull, SetNull)]
    [Dictionary('id_pacote_credito', 'Mensagem de validação', '', '', '',
      taCenter)]
    property id_pacote_credito: Integer read Fid_pacote_credito
      write Fid_pacote_credito;

    [SwagProp('pacote', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('pacote', ftString, 60)]
    [JoinColumn('id_pacote_credito', 'pacotes_creditos', 'id_pacote_credito', 'nome',
      TJoin.InnerJoin, 'pacote')]
    [Dictionary('pacote', '')]
    property pacote: nullable<String> read Fpacote write Fpacote;

    [SwagProp('dias_expirar', '', False, True)]
    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dias_expirar', ftInteger)]
    [JoinColumn('id_pacote_credito', 'pacotes_creditos', 'id_pacote_credito',
     'dias_expiracao', TJoin.InnerJoin, 'dias_expirar')]
    [Dictionary('dias_expirar', '')]
    property dias_expirar: Integer read Fdias_expirar write Fdias_expirar;

    [SwagRequired]
    [SwagDate('dd/mm/YYYY')]
    [Column('data_validade', ftDateTime)]
    [Dictionary('data_validade', 'Mensagem de validação', '', '', '', taCenter)]
    property data_validade: TDateTime read Fdata_validade write Fdata_validade;

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

constructor Tprofissionais_pacotes_creditos.Create;
begin
  //
end;

destructor Tprofissionais_pacotes_creditos.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tprofissionais_pacotes_creditos)

end.
