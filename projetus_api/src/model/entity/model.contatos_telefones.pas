unit model.contatos_telefones;

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
  [Table('contatos_telefones', '')]
  [PrimaryKey('id', TAutoIncType.NotInc,
                                     TGeneratorType.NoneInc,
                                     TSortingOrder.NoSort,
                                     True, 'Chave primária')]
//  [Sequence('contatos_telefones_id_contato_telefone_seq')]
  [OrderBy('id')]
  Tcontatos_telefones = class
  private
    { Private declarations }
    Fid: nullable<String>;
    Fid_contato: Integer;
    Ftelefone: String;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [Column('id', ftString, 38)]
    [Dictionary('id', 'Mensagem de validação', '', '', '', taCenter)]
    property id: nullable<String> read Fid write Fid;

    [Restrictions([TRestriction.NotNull])]
    [Column('id_contato', ftInteger)]
    [ForeignKey('fk_contatos_telefones_contatos', 'id_contato', 'contatos', 'id_contato', Cascade, Cascade)]
    [Dictionary('id_contato', 'Mensagem de validação', '', '', '', taCenter)]
    property id_contato: Integer read Fid_contato write Fid_contato;

    [Column('telefone', ftString, 15)]
    [Dictionary('telefone', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property telefone: String read Ftelefone write Ftelefone;

    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('Data Inclusão', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [Column('dt_alt', ftDateTime)]
    [Dictionary('Data Alteração', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [Column('dt_del', ftDateTime)]
    [Dictionary('Data Deleção', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_del: nullable<TDateTime> read Fdt_del write Fdt_del;
  end;

implementation

constructor Tcontatos_telefones.Create;
begin
  //
end;

destructor Tcontatos_telefones.Destroy;
begin
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Tcontatos_telefones)

end.
