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
  dbcbr.mapping.classes,
  dbcbr.mapping.register,
  dbcbr.mapping.attributes;

type
  [Entity]
  [Table('enderecos', '')]
  [PrimaryKey('id_endereco', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('enderecos_id_endereco_seq')]
  [OrderBy('id_endereco')]
  Tenderecos = class
  private
    { Private declarations } 
    Fid_endereco: Integer;
    Fid_pessoa: Integer;
    Fcep: Nullable<String>;
    Flogradouro: Nullable<String>;
    Fnumero: Nullable<String>;
    Fcomplemento: Nullable<String>;
    Fbairro: Nullable<String>;
    Fid_municipio: Integer;
    Fid_estado: Integer;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [Column('id_endereco', ftInteger)]
    [Dictionary('id_endereco', 'Mensagem de validação', '', '', '', taCenter)]
    property id_endereco: Integer read Fid_endereco write Fid_endereco;

    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_enderecos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [Column('cep', ftString, 9)]
    [Dictionary('cep', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cep: Nullable<String> read Fcep write Fcep;

    [Column('logradouro', ftString, 120)]
    [Dictionary('logradouro', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property logradouro: Nullable<String> read Flogradouro write Flogradouro;

    [Column('numero', ftString, 5)]
    [Dictionary('numero', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property numero: Nullable<String> read Fnumero write Fnumero;

    [Column('complemento', ftString, 30)]
    [Dictionary('complemento', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property complemento: Nullable<String> read Fcomplemento write Fcomplemento;

    [Column('bairro', ftString, 40)]
    [Dictionary('bairro', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property bairro: Nullable<String> read Fbairro write Fbairro;

    [Column('id_municipio', ftInteger)]
    [ForeignKey('fk_enderecos_municipios', 'id_municipio', 'municipios', 'id_municipio', Cascade, Cascade)]
    [Dictionary('id_municipio', 'Mensagem de validação', '', '', '', taCenter)]
    property id_municipio: Integer read Fid_municipio write Fid_municipio;

    [Column('id_estado', ftInteger)]
    [ForeignKey('fk_enderecos_estados', 'id_estado', 'estados', 'id_estado', Cascade, Cascade)]
    [Dictionary('id_estado', 'Mensagem de validação', '', '', '', taCenter)]
    property id_estado: Integer read Fid_estado write Fid_estado;
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
