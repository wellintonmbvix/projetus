unit model.configuracao_email;

interface

type
  Tconfiguracaoemail = class
  private
    Fhost: String;
    Fname: String;
    FuserName: String;
    Fpassword: String;
    Fport: Integer;
    FcriptografiaSSL: Boolean;
    FrequerAutenticacao: Boolean;
    FconfirmarRecebimento: Boolean;
  public
    property host: String read Fhost write Fhost;
    property name: String read Fname write Fname;
    property userName: String read FuserName write FuserName;
    property password: String read Fpassword write Fpassword;
    property port: Integer read Fport write Fport;
    property criptografiaSSL: Boolean read FcriptografiaSSL write FcriptografiaSSL;
    property requerAutenticacao: Boolean read FrequerAutenticacao write FrequerAutenticacao;
    property confirmarRecebimento: Boolean read FconfirmarRecebimento write FconfirmarRecebimento;
  end;

implementation

end.
