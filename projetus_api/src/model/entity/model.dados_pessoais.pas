unit model.dados_pessoais;

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
  [Table('dados_pessoais', '')]
  [PrimaryKey('id_dado_pessoal', TAutoIncType.AutoInc,
                                 TGeneratorType.SequenceInc,
                                 TSortingOrder.NoSort,
                                 True, 'Chave primária')]
  [Sequence('dados_pessoais_id_dado_pessoal_seq')]
  [OrderBy('id_dado_pessoal')]
  Tdados_pessoais = class
  private
    { Private declarations } 
    Fid_dado_pessoal: Integer;
    Fid_pessoa: Integer;
    Fcpf: nullable<String>;
    Fidentidade: nullable<String>;
    Fdata_nascimento: nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [SwagIgnore]
    [Column('id_dado_pessoal', ftInteger)]
    [Dictionary('id_dado_pessoal', 'Mensagem de validação', '', '', '', taCenter)]
    property id_dado_pessoal: Integer read Fid_dado_pessoal write Fid_dado_pessoal;

    [SwagIgnore]
    [Restrictions([TRestriction.NotNull])]
    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_dados_pessoais_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [SwagString(14)]
    [Column('cpf', ftString, 14)]
    [Dictionary('cpf', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cpf: nullable<String> read Fcpf write Fcpf;

    [SwagString(20)]
    [Column('identidade', ftString, 20)]
    [Dictionary('identidade', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property identidade: nullable<String> read Fidentidade write Fidentidade;

    [SwagDate('dd/mm/YYYY')]
    [Column('data_nascimento', ftDateTime)]
    [Dictionary('data_nascimento', 'Mensagem de validação', '', '', '', taCenter)]
    property data_nascimento: nullable<TDateTime> read Fdata_nascimento write Fdata_nascimento;
  end;

implementation

constructor Tdados_pessoais.Create;
begin
  //
end;

destructor Tdados_pessoais.Destroy;
begin
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Tdados_pessoais)

end.
