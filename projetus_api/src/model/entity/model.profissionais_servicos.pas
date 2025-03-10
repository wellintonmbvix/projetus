unit model.profissionais_servicos;

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
  [Table('profissionais_servicos', '')]
  [PrimaryKey('id_profissional_servico', TAutoIncType.AutoInc,
                                        TGeneratorType.SequenceInc,
                                        TSortingOrder.NoSort,
                                        True, 'Chave primária')]
  [Sequence('profissionais_servicos_id_profissional_servico_seq')]
  [OrderBy('id_profissional_servico')]
  Tprofissionais_servicos = class
  private
    { Private declarations } 
    Fid_profissional_servico: Integer;
    Fid_pessoa: Integer;
    Fid_servico: Integer;
    Fdt_inc: TDateTime;
    Fdt_alt: Nullable<TDateTime>;
    Fdt_del: Nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    [Column('id_profissional_servico', ftInteger)]
    [Dictionary('id_profissional_servico', 'Mensagem de validação', '', '', '', taCenter)]
    property id_profissional_servico: Integer read Fid_profissional_servico write Fid_profissional_servico;

    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_profissionais_servicos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', SetNull, SetNull)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [Column('id_servico', ftInteger)]
    [ForeignKey('fk_profissionais_servicos_servicos', 'id_servico', 'servicos', 'id_servico', SetNull, SetNull)]
    [Dictionary('id_servico', 'Mensagem de validação', '', '', '', taCenter)]
    property id_servico: Integer read Fid_servico write Fid_servico;

    [Restrictions([TRestriction.NoInsert, TRestriction.NoUpdate])]
    [Column('dt_inc', ftDateTime)]
    [Dictionary('dt_inc', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_inc: TDateTime read Fdt_inc write Fdt_inc;

    [Column('dt_alt', ftDateTime)]
    [Dictionary('dt_alt', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_alt: nullable<TDateTime> read Fdt_alt write Fdt_alt;

    [Column('dt_del', ftDateTime)]
    [Dictionary('dt_del', 'Mensagem de validação', 'Now', '',
      '!##/##/####;1;_', taLeftJustify)]
    property dt_del: nullable<TDateTime> read Fdt_del write Fdt_del;
  end;

implementation

constructor Tprofissionais_servicos.Create;
begin
  //
end;

destructor Tprofissionais_servicos.Destroy;
begin
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Tprofissionais_servicos)

end.
