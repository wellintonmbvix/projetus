unit model.resource.impl.configuration;

interface

uses
  System.SysUtils,
  System.IniFiles,
  model.resource.interfaces;

type
  TConfiguration = class(TInterfacedObject, IConfiguration)
  private
    FServidor: String;
    FPorta: Integer;
    FDriverName: String;
    FUserName: String;
    FPassword: String;
    FDataBase: String;

    function Crypt(Action, Src: String): String;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IConfiguration;

    function DriverID(Value: String): IConfiguration; overload;
    function DriverID: String; overload;

    function Database(Value: String): IConfiguration; overload;
    function Database: String; overload;

    function Username(Value: String): IConfiguration; overload;
    function Username: String; overload;

    function Password(Value: String): IConfiguration; overload;
    function Password: String; overload;

    function Port(Value: String): IConfiguration; overload;
    function Port: String; overload;

    function Server(Value: String): IConfiguration; overload;
    function Server: String; overload;

    function Schema(Value: String): IConfiguration; overload;
    function Schema: String; overload;
  end;

implementation

{ TConfiguration }

function TConfiguration.Crypt(Action, Src: String): String;
Label Fim;
var
  KeyLen: Integer;
  KeyPos: Integer;
  OffSet: Integer;
  Dest, Key: String;
  SrcPos: Integer;
  SrcAsc: Integer;
  TmpSrcAsc: Integer;
  Range: Integer;
begin
  if (Src = '') Then
  begin
    Result := '';
    Goto Fim;
  end;
  Key := 'YUQL23KL23DF90WI5E1JAS467NMCXXL6JAOAUWWMCL0AOMM4A4VZYW9KHJUI2347EJHJKDF3424SKL K3LAKDJSL9RTIKJ';
  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  SrcPos := 0;
  SrcAsc := 0;
  Range := 256;
  if (Action = UpperCase('C')) then
  begin
    Randomize;  // Inicializa o gerador de números aleatórios
    OffSet := Random(Range);  // Gera um valor aleatório dentro do range
    Dest := Format('%1.2x', [OffSet]);  // Formata o valor de OffSet como hexadecimal

    KeyPos := 1;  // Inicializa a posição da chave

    for SrcPos := 1 to Length(Src) do
    begin
      // Calcula o valor ASCII modificado com o deslocamento
      SrcAsc := (Ord(Src[SrcPos]) + OffSet) Mod 255;

      // Atualiza a posição da chave de forma cíclica
      if KeyPos < KeyLen then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;

      // Realiza a operação XOR com a chave
      SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);

      // Adiciona o valor resultante ao destino em formato hexadecimal
      Dest := Dest + Format('%1.2x', [SrcAsc]);

      // Atualiza o deslocamento
      OffSet := SrcAsc;
    end;
  end
  Else if (Action = UpperCase('D')) then
  begin
    OffSet := StrToInt('$' + Copy(Src, 1, 2));
    // <--------------- adiciona o $ entra as aspas simples
    SrcPos := 3;
    repeat
      SrcAsc := StrToInt('$' + Copy(Src, SrcPos, 2));
      // <--------------- adiciona o $ entra as aspas simples
      if (KeyPos < KeyLen) Then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;
      TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      if TmpSrcAsc <= OffSet then
        TmpSrcAsc := 255 + TmpSrcAsc - OffSet
      else
        TmpSrcAsc := TmpSrcAsc - OffSet;
      Dest := Dest + Chr(TmpSrcAsc);
      OffSet := SrcAsc;
      SrcPos := SrcPos + 2;
    until (SrcPos >= Length(Src));
  end;
  Result := Dest;
Fim:
end;

constructor TConfiguration.Create;
var
  fileIni: String;
begin

{$IFDEF DEBUG}
  fileIni := ExtractFilePath(ParamStr(0)) + '../../../config.ini';
{$ELSE}
  fileIni := ExtractFilePath(ParamStr(0)) + '/config.ini';
{$ENDIF}
  if not FileExists(fileIni) then
  begin
    raise Exception.Create('Arquivo de Configuração não encontrado' + #13 +
      'Entre em contato com o suporte técnico');
    Exit;
  end;

  // Carregando as informações do arquivo de configurações
  var
  configuracoes := TIniFile.Create(fileIni);
  Try
    FServidor := configuracoes.ReadString('Dados', 'Servidor', FServidor);
    FPorta := configuracoes.ReadInteger('Dados', 'Porta', FPorta);
    FDriverName := configuracoes.ReadString('Dados', 'DriverName', FDriverName);
    FUserName := configuracoes.ReadString('Dados', 'UserName', FUserName);
    FPassword := configuracoes.ReadString('Dados', 'PassWord', FPassword);
    FDataBase := configuracoes.ReadString('Dados', 'Database', FDataBase);
  Finally
    configuracoes.Free;
  end;

  FServidor := Crypt('D', FServidor);
  FUserName := Crypt('D', FUserName);
  FPassword := Crypt('D', FPassword);
  FDataBase := Crypt('D', FDataBase);
end;

function TConfiguration.Database(Value: String): IConfiguration;
begin
  Result := Self;
  // Gravar no INI
end;

function TConfiguration.Database: String;
begin
  Result := FDataBase; // Puxar do INI
end;

destructor TConfiguration.Destroy;
begin
  inherited;
end;

function TConfiguration.DriverID: String;
begin
  Result := FDriverName; // Puxar do INI
end;

function TConfiguration.DriverID(Value: String): IConfiguration;
begin
  Result := Self;
  // Gravar no INI
end;

class function TConfiguration.New: IConfiguration;
begin
  Result := Self.Create;
end;

function TConfiguration.Password(Value: String): IConfiguration;
begin
  Result := Self;
  // Gravar no INI
end;

function TConfiguration.Password: String;
begin
  Result := FPassword; // Puxar do INI
end;

function TConfiguration.Port(Value: String): IConfiguration;
begin
  Result := Self;
  // Gravar no INI
end;

function TConfiguration.Port: String;
begin
  Result := FPorta.ToString; // Puxar do INI
end;

function TConfiguration.Schema: String;
begin
  Result := ''; // Puxar do INI
end;

function TConfiguration.Schema(Value: String): IConfiguration;
begin
  Result := Self;
  // Gravar no INI
end;

function TConfiguration.Server(Value: String): IConfiguration;
begin
  Result := Self;
  // Gravar no INI
end;

function TConfiguration.Server: String;
begin
  Result := FServidor; // Puxar do INI
end;

function TConfiguration.Username: String;
begin
  Result := FUserName; // Puxar do INI
end;

function TConfiguration.Username(Value: String): IConfiguration;
begin
  Result := Self;
  // Gravar no INI
end;

end.
