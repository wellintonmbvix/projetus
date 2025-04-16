unit api.swagger.doc;

interface

uses
  Horse.GBSwagger;

procedure StartDocumentation;

implementation

procedure StartDocumentation;
begin
  Swagger
    .Host('127.0.0.1')
      .Info
        .Title('API Projetus')
        .Description('API para comunica��o do app')
          .Contact
            .Name('Wellinton Mattos Brozeghini')
            .Email('wellinton@projetus.com.br')
            .URL('http://www.projetus.com.br')
          .&End
      .&End
    .&End
  .&End;
end;

initialization
  StartDocumentation;

end.
