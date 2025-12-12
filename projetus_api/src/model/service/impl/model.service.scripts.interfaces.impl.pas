unit model.service.scripts.interfaces.impl;

interface

uses
  System.StrUtils,
  System.Generics.Collections,
  System.SysUtils,
  System.Rtti,
  System.TypInfo,
  System.JSON,

  dbebr.factory.interfaces,
  dbebr.factory.firedac,
  cqlbr.select.postgresql,
  cqlbr.serialize.postgresql,
  ormbr.criteria.resultset,
  ormbr.types.nullable,

  firedac.Comp.Client,
  firedac.Comp.DataSet,
  firedac.UI.Intf,
  {$IFDEF Defined(HAS_VCL)}
  firedac.VCLUI.Wait,
  {$ENDIF}
  firedac.Comp.UI,
  firedac.Stan.Param,

  model.pessoa,
  model.resource.interfaces,
  model.resource.impl.factory,
  model.service.scripts.interfaces;

type
  TServiceScripts = class(TInterfacedObject, IServiceScripts)
    private
    FConnection: IConnection;
    FConnectionORM: IDBConnection;
    FServiceScripts: IServiceScripts;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IServiceScripts;

      function InsertCustomer(Cliente: Tpessoas; var msg: String): Boolean; overload;
      function GetEmailByUserName(userName: String; out email: String): Boolean; overload;
  end;

implementation

{ TServiceScripts }

uses
  cqlbr.interfaces,
  criteria.query.language;

constructor TServiceScripts.Create;
begin
  FConnection := TResource.New.Connection;
  FConnectionORM := TFactoryFiredac.Create
    (TFDConnection(FConnection.Connect), dnPostgreSQL);
end;

destructor TServiceScripts.Destroy;
begin
  inherited;
end;

function TServiceScripts.GetEmailByUserName(userName: String;
  out email: String): Boolean;
var
  LSQL: String;
  LResultSet: IDBResultSet;
  id_pessoa, id_contato: Integer;
begin
  Result := False;
  email := '';

  LSQL := TCQL.New(dbnPostgreSQL)
          .Select
          .All
          .From('contatos_emails')
            .InnerJoin('contatos').On('contatos_emails.id_contato=contatos.id_contato')
            .InnerJoin('usuarios').On('contatos.id_pessoa=contatos.id_pessoa')
          .Where('usuarios.nome_usuario='+QuotedStr(username))
        .AsString;

  LResultSet := TCriteria.New.SetConnection(FConnectionORM).SQL(LSQL).AsResultSet;
  if LResultSet.RecordCount > 0 then
    begin
      email := LResultSet.FieldByName('emails').Value;
      var JSONArray := TJSONObject.ParseJSONValue(email) as TJSONArray;
      if Assigned(JSONArray) then
        begin
          email := JSONArray.Items[0].Value;
          Result := True;
        end;
    end;
end;

function TServiceScripts.InsertCustomer(Cliente: Tpessoas;
  var msg: String): Boolean;
var
  FDTransaction: TFDTransaction;
  lQry: TFDQuery;
  pessoaId, contatoId: Int64;
begin
  Result := False;
  FDTransaction := TFDTransaction.Create(nil);
  lQRy := TFDQuery.Create(nil);
  FDTransaction.Connection := TFDConnection(FConnection.Connect);
  lQry.Connection := FDTransaction.Connection;
  FDTransaction.StartTransaction;
  Try
    Try
      lQry.Open('SELECT NEXTVAL(''pessoas_id_pessoa_seq'')');
      pessoaId := lQry.Fields[0].AsLargeInt;

      With lQry Do
        Begin
          // ** Inserção dos dados em "Pessoa"
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO pessoas(');
          SQL.Add('id_pessoa');
          SQL.Add(',nome');
          SQL.Add(',tipo');
          SQL.Add(',suspenso');
          SQL.Add(',dt_inc)');
          SQL.Add('VALUES(');
          SQL.Add(':id_pessoa');
          SQL.Add(',:nome');
          SQL.Add(',:tipo');
          SQL.Add(',:suspenso');
          SQL.Add(',:dt_inc);');
          ParamByName('id_pessoa').Value := pessoaId;
          ParamByName('nome').AsString := Cliente.nome;
          ParamByName('tipo').AsString := Cliente.tipo;
          ParamByName('suspenso').AsBoolean := Cliente.suspenso;
          ParamByName('dt_inc').AsDateTime := Cliente.dt_inc;
          ExecSQL;

          // ** Inserção dos dados em "Endereço"
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO enderecos(');
          SQL.Add('id_pessoa');
          SQL.Add(',cep');
          SQL.Add(',logradouro');
          SQL.Add(',numero');
          SQL.Add(',complemento');
          SQL.Add(',bairro');
          SQL.Add(',id_municipio');
          SQL.Add(',id_estado)');
          SQL.Add('VALUES(');
          SQL.Add(':id_pessoa');
          SQL.Add(',:cep');
          SQL.Add(',:logradouro');
          SQL.Add(',:numero');
          SQL.Add(',:complemento');
          SQL.Add(',:bairro');
          SQL.Add(',:id_municipio');
          SQL.Add(',:id_estado);');
          ParamByName('id_pessoa').Value := pessoaId;
          ParamByName('cep').AsString := Cliente.endereco.cep.Value;
          if not Cliente.endereco.cep.HasValue then
            ParamByName('cep').Clear(0);
          ParamByName('logradouro').AsString := Cliente.endereco.logradouro.Value;
          if not Cliente.endereco.logradouro.HasValue then
            ParamByName('logradouro').Clear(0);
          ParamByName('numero').AsString := Cliente.endereco.numero.Value;
          if not Cliente.endereco.numero.HasValue then
            ParamByName('numero').Clear(0);
          ParamByName('complemento').AsString := Cliente.endereco.complemento.Value;
          if not Cliente.endereco.complemento.HasValue then
            ParamByName('complemento').Clear(0);
          ParamByName('bairro').AsString := Cliente.endereco.bairro.Value;
          if not Cliente.endereco.bairro.HasValue then
            ParamByName('bairro').Clear(0);
          ParamByName('id_municipio').Value := Cliente.endereco.id_municipio;
          ParamByName('id_estado').Value := Cliente.endereco.id_estado;
          ExecSQL;


          // ** Inserção dos dados em "Dados Pessoais"
          Close;
          SQL.Clear;
          SQL.Add('INSERT INTO dados_pessoais(');
          SQL.Add('id_pessoa');
          SQL.Add(',cpf');
          SQL.Add(',identidade');
          SQL.Add(',data_nascimento)');
          SQL.Add('VALUES(');
          SQL.Add(':id_pessoa');
          SQL.Add(',:cpf');
          SQL.Add(',:identidade');
          SQL.Add(',:data_nascimento);');
          ParamByName('id_pessoa').Value := pessoaId;
          ParamByName('cpf').AsString := Cliente.dados_pessoais.cpf.Value;
          if not Cliente.dados_pessoais.cpf.HasValue then
            ParamByName('cpf').Clear(0);
          ParamByName('identidade').AsString := Cliente.dados_pessoais.identidade.Value;
          if not Cliente.dados_pessoais.identidade.HasValue then
            ParamByName('identidade').Clear(0);
          ParamByName('data_nascimento').AsDate := Cliente.dados_pessoais.data_nascimento.Value;
          if not Cliente.dados_pessoais.data_nascimento.HasValue then
            ParamByName('data_nascimento').Clear(0);
          ExecSQL;

          for var i := 0 to Cliente.contatos.Count - 1 do
            begin

              // ** Pegando o próximo Id de "Contatos"
              Close;
              SQL.Clear;
              Open('SELECT NEXTVAL(''contatos_id_contato_seq'')');
              contatoId := Fields[0].AsLargeInt;

              // ** Inserção dos dados em "Contato"
              Close;
              SQL.Clear;
              SQL.Add('INSERT INTO contatos(');
              SQL.Add('id_contato');
              SQL.Add(',id_pessoa');
              SQL.Add(',nome');
              SQL.Add(',dt_inc)');
              SQL.Add('VALUES(');
              SQL.Add(':id_contato');
              SQL.Add(',:id_pessoa');
              SQL.Add(',:nome');
              SQL.Add(',:dt_inc);');
              ParamByName('id_contato').Value := contatoId;
              ParamByName('id_pessoa').Value := pessoaId;
              ParamByName('nome').AsString := Cliente.nome;
              ParamByName('dt_inc').AsDateTime := Cliente.dt_inc;
              ExecSQL;

              Close;
              SQL.Clear;
              SQL.Add('INSERT INTO contatos_telefones(');
              SQL.Add('id_contato');
              SQL.Add(',telefones');
              SQL.Add(',dt_inc)');
              SQL.Add('VALUES(');
              SQL.Add(':id_contato');
              SQL.Add(',cast(:telefones as jsonb)');
              SQL.Add(',:dt_inc);');
              ParamByName('id_contato').Value := contatoId;
              ParamByName('telefones').AsMemo := Cliente.contatos[i].contatos_telefones.telefones;
              ParamByName('dt_inc').AsDateTime := Cliente.dt_inc;
              ExecSQL;

              Close;
              SQL.Clear;
              SQL.Add('INSERT INTO contatos_emails(');
              SQL.Add('id_contato');
              SQL.Add(',emails');
              SQL.Add(',dt_inc)');
              SQL.Add('VALUES(');
              SQL.Add(':id_contato');
              SQL.Add(',cast(:emails as jsonb)');
              SQL.Add(',:dt_inc);');
              ParamByName('id_contato').Value := contatoId;
              ParamByName('emails').AsMemo := Cliente.contatos[i].contatos_telefones.telefones;
              ParamByName('dt_inc').AsDateTime := Cliente.dt_inc;
              ExecSQL;
            end;
        End;

      FDTransaction.Commit;
      Result := True;
    Except
      on e: Exception do
        begin
          FDTransaction.Rollback;
          msg := e.Message;
        end;
    End;
  Finally
    FreeAndNil(lQry);
    FreeAndNil(FDTransaction);
  End;
end;

class function TServiceScripts.New: IServiceScripts;
begin
  Result := Self.Create;
end;

end.
