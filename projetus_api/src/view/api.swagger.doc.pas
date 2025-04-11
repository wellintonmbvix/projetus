unit api.swagger.doc;

interface

uses
  Horse.GBSwagger;

procedure StartDocumentation;

implementation

procedure StartDocumentation;
begin
  Swagger
    .Info
      .Title('API Projetus')
      .Description('API para comunica��o do app')
        .Contact
          .Name('Wellinton Mattos Brozeghini')
          .Email('wellinton@projetus.com.br')
          .URL('http://www.projetus.com.br')
        .&End
    .&End
  .&End;
end;

initialization
  StartDocumentation;

end.
