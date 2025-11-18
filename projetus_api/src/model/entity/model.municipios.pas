unit model.municipios;

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
  [Table('municipios', '')]
  [PrimaryKey('id_municipio',TAutoIncType.NotInc,
                           TGeneratorType.NoneInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('id_municipio')]
  Tmunicipios = class
  private
    Fid_municipio: Integer;
    Fnome: String;
    Fid_estado: Integer;

  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [SwagProp('id', '', False, True)]
    [Column('id_municipio', ftInteger)]
    [Dictionary('id_municipio', 'Mensagem de validação', '', '', '', taCenter)]
    property id_municipio: Integer read Fid_municipio write Fid_municipio;

    [SwagString(60, 1)]
    [SwagRequired]
    [Column('nome', ftString, 60)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: String read Fnome write Fnome;

    [SwagProp('id_estado', '', False, True)]
    [Column('id_estado', ftInteger)]
    [ForeignKey('fk_municipios_estados', 'id_estado', 'estados', 'id_estado', Cascade, Cascade)]
    [Dictionary('id_estado', 'Mensagem de validação', '', '', '', taCenter)]
    property id_estado: Integer read Fid_estado write Fid_estado;
  end;

implementation

{ Tmunicipios }

constructor Tmunicipios.Create;
begin
  //
end;

destructor Tmunicipios.Destroy;
begin
  //
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Tmunicipios)

end.
