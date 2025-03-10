unit model.orcamentos;

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
  [Table('orcamentos', '')]
  [PrimaryKey('id_orcamento', TAutoIncType.AutoInc,
                           TGeneratorType.SequenceInc,
                           TSortingOrder.NoSort,
                           True, 'Chave primária')]
  [Sequence('orcamentos_id_orcamento_seq')]
  [OrderBy('id_orcamento')]
  Torcamentos = class
  private
    { Private declarations } 
    Fid_orcamento: Integer;
    Fid_pessoa: Integer;
    Fid_servico: Integer;
    Finfo_adicionais: nullable<TBlob>;
    Furgente: Boolean;
    Fprevisao_inicio: Nullable<TDateTime>;
    Fdt_inc: TDateTime;
    Fdt_alt: Nullable<TDateTime>;
    Fdt_del: Nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [Column('id_orcamento', ftInteger)]
    [Dictionary('id_orcamento', 'Mensagem de validação', '', '', '', taCenter)]
    property id_orcamento: Integer read Fid_orcamento write Fid_orcamento;

    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_orcamentos_pessoas', 'id_pessoa', 'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [Column('id_servico', ftInteger)]
    [ForeignKey('fk_orcamentos_servicos', 'id_servico', 'servicos', 'id_servico', SetNull, SetNull)]
    [Dictionary('id_servico', 'Mensagem de validação', '', '', '', taCenter)]
    property id_servico: Integer read Fid_servico write Fid_servico;

    [Column('info_adicionais', ftBlob)]
    [Dictionary('info_adicionais', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property info_adicionais: nullable<TBlob> read Finfo_adicionais write Finfo_adicionais;

    [Column('urgente', ftBoolean)]
    [Dictionary('urgente', 'Mensagem de validação', 'false', '', '', taLeftJustify)]
    property urgente: Boolean read Furgente write Furgente;

    [Column('previsao_inicio', ftDateTime)]
    [Dictionary('previsao_inicio', 'Mensagem de validação', '', '', '', taCenter)]
    property previsao_inicio: Nullable<TDateTime> read Fprevisao_inicio write Fprevisao_inicio;

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

constructor Torcamentos.Create;
begin
  //
end;

destructor Torcamentos.Destroy;
begin
  inherited;
end;

initialization
  TRegisterClass.RegisterEntity(Torcamentos)

end.
