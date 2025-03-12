unit model.endereco;

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
  dbcbr.mapping.Classes,
  dbcbr.mapping.register,
  dbcbr.mapping.attributes;

type

  [Entity]
  [Table('enderecos', '')]
  [PrimaryKey('id_endereco', TAutoIncType.AutoInc, TGeneratorType.SequenceInc,
    TSortingOrder.NoSort, True, 'Chave primária')]
  [Sequence('enderecos_id_endereco_seq')]
  [OrderBy('id_endereco')]
  Tenderecos = class
  private
    { Private declarations }
    Fid_endereco: Integer;
    Fid_pessoa: Integer;
    Fcep: nullable<String>;
    Flogradouro: nullable<String>;
    Fnumero: nullable<String>;
    Fcomplemento: nullable<String>;
    Fbairro: nullable<String>;
    Fid_municipio: Integer;
    Fid_estado: Integer;
    Fmunicipio: nullable<String>;
    Festado: nullable<String>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [Column('id_endereco', ftInteger)]
    [Dictionary('id_endereco', 'Mensagem de validação', '', '', '', taCenter)]
    property id_endereco: Integer read Fid_endereco write Fid_endereco;

    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_enderecos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa',
      Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [Column('cep', ftString, 9)]
    [Dictionary('cep', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cep: nullable<String> read Fcep write Fcep;

    [Column('logradouro', ftString, 120)]
    [Dictionary('logradouro', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property logradouro: nullable<String> read Flogradouro write Flogradouro;

    [Column('numero', ftString, 5)]
    [Dictionary('numero', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property numero: nullable<String> read Fnumero write Fnumero;

    [Column('complemento', ftString, 30)]
    [Dictionary('complemento', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property complemento: nullable<String> read Fcomplemento write Fcomplemento;

    [Column('bairro', ftString, 40)]
    [Dictionary('bairro', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property bairro: nullable<String> read Fbairro write Fbairro;

    [Column('id_municipio', ftInteger)]
    [ForeignKey('fk_enderecos_municipios', 'id_municipio', 'municipios',
      'id_municipio', Cascade, Cascade)]
    [Dictionary('id_municipio', 'Mensagem de validação', '', '', '', taCenter)]
    property id_municipio: Integer read Fid_municipio write Fid_municipio;

    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('municipio', ftString, 60)]
    [JoinColumn('id_municipio', 'municipios', 'id_municipio', 'nome',
      TJoin.InnerJoin, 'municipio')]
    [Dictionary('municipio', '')]
    property municipio: nullable<String> read Fmunicipio write Fmunicipio;

    [Column('id_estado', ftInteger)]
    [ForeignKey('fk_enderecos_estados', 'id_estado', 'estados', 'id_estado',
      Cascade, Cascade)]
    [Dictionary('id_estado', 'Mensagem de validação', '', '', '', taCenter)]
    property id_estado: Integer read Fid_estado write Fid_estado;

    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('estado', ftString, 60)]
    [JoinColumn('id_estado', 'estados', 'id_estado', 'sigla', TJoin.InnerJoin,
      'estado')]
    [Dictionary('estado', '')]
    property estado: nullable<String> read Festado write Festado;
  end;

implementation

constructor Tenderecos.Create;
begin
  //
end;

destructor Tenderecos.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tenderecos)

end.
