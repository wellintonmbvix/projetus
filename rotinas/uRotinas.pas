unit uRotinas;

interface

uses

  Winapi.Windows,
  Winapi.Messages,

  Vcl.Dialogs,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Imaging.jpeg,
  Vcl.DBGrids,

  System.SysUtils,
  System.Classes,
  System.Variants,
  System.UITypes,
  System.RegularExpressions,
  System.MaskUtils,
  System.StrUtils,
  System.Win.Registry,
  System.zip,
  System.Generics.Collections,

  JVDBGrid,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,

  Data.DB,
  Winapi.ActiveX;

const
  OffsetMemoryStream: Int64 = 0;

  // Funções
function GuidCreate: String;
function Crypt(Action, Src: String): String;

  // Procedures
procedure MsgAviso(Texto: String);
procedure MsgInformacao(Texto: String);
procedure MsgErro(Texto: String);

implementation

{$REGION 'Bloco de funções'}

function GuidCreate: String;
var
  ID : TGUID;
begin
  Result := EmptyStr;
  if CoCreateGuid(ID) = S_OK then
    Result := AnsiLowerCase(GUIDToString(ID));

  // *** Adicionado o método StringReplace a função para remover as chaves '{' e '}' que a função incrementa
  // *** Adicionado o método AnsiLowerCase para colocar os caracteres em 'mínusculos' (Perfumaria)

end;

function Crypt(Action, Src: String): String;
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
    Randomize;
    OffSet := Random(Range);
    Dest := Format('%1.2x', [OffSet]);
    for SrcPos := 1 to Length(Src) do
    begin
      Application.ProcessMessages;
      SrcAsc := (Ord(Src[SrcPos]) + OffSet) Mod 255;
      if KeyPos < KeyLen then
        KeyPos := KeyPos + 1
      else
        KeyPos := 1;

      SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      Dest := Dest + Format('%1.2x', [SrcAsc]);
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

{$ENDREGION}

{$REGION 'Bloco de procedures'}

procedure MsgAviso(Texto: String);
begin
  Application.MessageBox(PChar(Texto), 'Aviso', mb_ok + mb_iconexclamation);
end;

procedure MsgInformacao(Texto: String);
begin
  Application.MessageBox(PChar(Texto), 'Informação',
    mb_ok + mb_iconinformation);
end;

procedure MsgErro(Texto: String);
begin
  Application.MessageBox(PChar(Texto), 'Erro', mb_ok + mb_iconerror);
end;

{$ENDREGION}

end.

