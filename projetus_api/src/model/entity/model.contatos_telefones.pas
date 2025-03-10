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
  [PrimaryKey('id_contato_telefone', NotInc, NoSort, False, 'Chave primária')]
  Tcontatos_telefones = class
  private
    { Private declarations } 
    Fid_contato_telefone: Integer;
    Fid_contato: Integer;
    Ftelefone: String;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [Column('id_contato_telefone', ftInteger)]
    [Dictionary('id_contato_telefone', 'Mensagem de validação', '', '', '', taCenter)]
    property id_contato_telefone: Integer read Fid_contato_telefone write Fid_contato_telefone;

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
