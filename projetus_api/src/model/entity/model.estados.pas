unit model.estados;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,

  GBSwagger.Model.Attributes,

  model.municipios,

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
  [Table('estados', '')]
  [PrimaryKey('id_estado',TAutoIncType.NotInc,
                           TGeneratorType.NoneInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('id_estado')]
  Testados = class
  private
    { Private declarations }
    Fid_estado: Integer;
    Fnome: String;
    Fsigla: String;
    Fid_pais: Integer;
    Fmunicipios: TObjectList<Tmunicipios>;

  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [SwagProp('id', '', False, True)]
    [Column('id_estado', ftInteger)]
    [Dictionary('id_estado', 'Mensagem de validação', '', '', '', taCenter)]
    property id_estado: Integer read Fid_estado write Fid_estado;

    [SwagString(60, 1)]
    [SwagRequired]
    [Column('nome', ftString, 60)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: String read Fnome write Fnome;

    [SwagString(2, 1)]
    [SwagRequired]
    [Column('sigla', ftString, 2)]
    [Dictionary('sigla', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property sigla: String read Fsigla write Fsigla;

    [SwagProp('id_pais', '', False, True)]
    [Column('id_pais', ftInteger)]
    [Dictionary('id_pais', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pais: Integer read Fid_pais write Fid_pais;

    [Association(TMultiplicity.OneToMany, 'id_estado', 'municipios', 'id_estado')]
    [CascadeActions([TCascadeAction.CascadeAutoInc,
                     TCascadeAction.CascadeInsert,
                     TCascadeAction.CascadeUpdate,
                     TCascadeAction.CascadeDelete])]
    property municipios: TObjectList<Tmunicipios> read Fmunicipios write Fmunicipios;
  end;

implementation

{ Testados }

constructor Testados.Create;
begin
  Fmunicipios := TObjectList<Tmunicipios>.Create;
end;

destructor Testados.Destroy;
begin
  FreeAndNil(Fmunicipios);
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Testados)

end.
