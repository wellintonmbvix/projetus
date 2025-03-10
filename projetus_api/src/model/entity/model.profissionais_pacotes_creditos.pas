unit model.profissionais_pacotes_creditos;

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
  [Table('profissionais_pacotes_creditos', '')]
  [PrimaryKey('id_profissional_pacote', TAutoIncType.AutoInc,
                                        TGeneratorType.SequenceInc,
                                        TSortingOrder.NoSort,
                                        True, 'Chave primária')]
  [Sequence('profissionais_pacotes_creditos_id_profissional_pacote_seq')]
  [OrderBy('id_profissional_pacote')]
  Tprofissionais_pacotes_creditos = class
  private
    { Private declarations }
    Fid_profissional_pacote: Integer;
    Fid_pessoa: Integer;
    Fid_pacote_credito: Integer;
    Fdata_validade: TDateTime;
    Fdt_inc: TDateTime;
    Fdt_alt: nullable<TDateTime>;
    Fdt_del: nullable<TDateTime>;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;

    [Column('id_profissional_pacote', ftInteger)]
    [Dictionary('id_profissional_pacote', 'Mensagem de validação', '', '', '',
      taCenter)]
    property id_profissional_pacote: Integer read Fid_profissional_pacote
      write Fid_profissional_pacote;

    [Column('id_pessoa', ftInteger)]
    [ForeignKey('fk_profissionais_pacotes_creditos_pessoas', 'id_pessoa',
      'pessoas', 'id_pessoa', Cascade, Cascade)]
    [Dictionary('id_pessoa', 'Mensagem de validação', '', '', '', taCenter)]
    property id_pessoa: Integer read Fid_pessoa write Fid_pessoa;

    [Column('id_pacote_credito', ftInteger)]
    [ForeignKey('fk_profissionais_pacotes_creditos_pacotes_creditos',
      'id_pacote_credito', 'pacotes_creditos', 'id_pacote_credito',
      SetNull, SetNull)]
    [Dictionary('id_pacote_credito', 'Mensagem de validação', '', '', '',
      taCenter)]
    property id_pacote_credito: Integer read Fid_pacote_credito
      write Fid_pacote_credito;

    [Column('data_validade', ftTime)]
    [Dictionary('data_validade', 'Mensagem de validação', '', '', '', taCenter)]
    property data_validade: TDateTime read Fdata_validade write Fdata_validade;

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
