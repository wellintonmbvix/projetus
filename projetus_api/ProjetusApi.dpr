program ProjetusApi;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  {$IFDEF MSWINDOWS}
  {$IFDEF DEBUG}
  FastMM4,
  {$ENDIF }
  {$ENDIF }
  System.SysUtils,
  Horse,
  Horse.Core,
  Horse.CORS,
  Horse.Jhonson,
  Horse.GBSwagger,
  System.JSON,
  model.resource.interfaces in 'src\model\resource\model.resource.interfaces.pas',
  model.resource.impl.configuration in 'src\model\resource\impl\model.resource.impl.configuration.pas',
  model.resource.impl.connection.firedac in 'src\model\resource\impl\model.resource.impl.connection.firedac.pas',
  model.resource.impl.factory in 'src\model\resource\impl\model.resource.impl.factory.pas',
  model.service.interfaces in 'src\model\service\model.service.interfaces.pas',
  model.service.interfaces.impl in 'src\model\service\impl\model.service.interfaces.impl.pas',
  controller.cliente in 'src\controller\controller.cliente.pas',
  model.api.error in 'src\model\entity\model.api.error.pas',
  model.endereco in 'src\model\entity\model.endereco.pas',
  model.pessoa in 'src\model\entity\model.pessoa.pas',
  controller.dto.pessoa.interfaces in 'src\controller\dto\controller.dto.pessoa.interfaces.pas',
  controller.dto.pessoa.interfaces.impl in 'src\controller\dto\implementation\controller.dto.pessoa.interfaces.impl.pas',
  model.api.sucess in 'src\model\entity\model.api.sucess.pas',
  model.pacotes_creditos in 'src\model\entity\model.pacotes_creditos.pas',
  controller.pacotes_creditos in 'src\controller\controller.pacotes_creditos.pas',
  controller.dto.pacotes_creditos.interfaces in 'src\controller\dto\controller.dto.pacotes_creditos.interfaces.pas',
  controller.dto.pacotes_creditos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.pacotes_creditos.interfaces.impl.pas',
  model.contatos in 'src\model\entity\model.contatos.pas',
  model.contatos_emails in 'src\model\entity\model.contatos_emails.pas',
  model.contatos_telefones in 'src\model\entity\model.contatos_telefones.pas',
  model.dados_pessoais in 'src\model\entity\model.dados_pessoais.pas',
  model.historico_creditos in 'src\model\entity\model.historico_creditos.pas',
  model.historico_orcamentos in 'src\model\entity\model.historico_orcamentos.pas',
  model.orcamentos in 'src\model\entity\model.orcamentos.pas',
  model.profissionais_pacotes_creditos in 'src\model\entity\model.profissionais_pacotes_creditos.pas',
  model.profissionais_servicos in 'src\model\entity\model.profissionais_servicos.pas',
  model.servicos in 'src\model\entity\model.servicos.pas',
  controller.dto.contatos.interfaces in 'src\controller\dto\controller.dto.contatos.interfaces.pas',
  controller.dto.contatos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.contatos.interfaces.impl.pas',
  controller.dto.contatos_telefones.interfaces in 'src\controller\dto\controller.dto.contatos_telefones.interfaces.pas',
  controller.dto.contatos_telefones.interfaces.impl in 'src\controller\dto\implementation\controller.dto.contatos_telefones.interfaces.impl.pas',
  uRotinas in '..\rotinas\uRotinas.pas',
  controller.dto.contatos_emails.interfaces in 'src\controller\dto\controller.dto.contatos_emails.interfaces.pas',
  controller.dto.contatos_emails.interfaces.impl in 'src\controller\dto\implementation\controller.dto.contatos_emails.interfaces.impl.pas',
  model.service.scripts.interfaces in 'src\model\service\model.service.scripts.interfaces.pas',
  model.service.scripts.interfaces.impl in 'src\model\service\impl\model.service.scripts.interfaces.impl.pas',
  controller.dto.servicos.interfaces in 'src\controller\dto\controller.dto.servicos.interfaces.pas',
  controller.dto.servicos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.servicos.interfaces.impl.pas',
  controller.servicos in 'src\controller\controller.servicos.pas',
  controller.profissional in 'src\controller\controller.profissional.pas',
  controller.dto.profissionais_pacotes_creditos.interfaces in 'src\controller\dto\controller.dto.profissionais_pacotes_creditos.interfaces.pas',
  controller.dto.profissionais_pacotes_creditos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.profissionais_pacotes_creditos.interfaces.impl.pas',
  controller.profissionais_pacotes_creditos in 'src\controller\controller.profissionais_pacotes_creditos.pas',
  controller.dto.profissionais_servicos.interfaces in 'src\controller\dto\controller.dto.profissionais_servicos.interfaces.pas',
  controller.dto.profissionais_servicos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.profissionais_servicos.interfaces.impl.pas',
  controller.profissionais_servicos in 'src\controller\controller.profissionais_servicos.pas',
  controller.nummus in 'src\controller\controller.nummus.pas';

begin
{$IFDEF MSWINDOWS}
  IsConsole := False;
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

   HorseCORS
  //   .AllowedOrigin('*')
  //   .AllowedCredentials('true')
  //   .AllowedHeaders('*')
  //   .AllowedMethods('*')
     .ExposedHeaders('*');

  // Middlewares
  THorse
        .Use(HorseSwagger)
        .Use(CORS)
        .Use(Jhonson('UTF-8'));

  // Controllers
  TControllerCliente.Registry;
  TControllerPacotesCreditos.Registry;
  TControllerServicos.Registry;
  TControllerProfissional.Registry;
  TControllerProfissionalPacoteCredito.Registry;
  TControllerProfissionaisServicos.Registry;
  TControllerNummus.Registry;

  // Gerando documentação SWAGGER
  Swagger
    .Host('localhost:3000')
    .BasePath('api/v1')
{$REGION 'Módulo de Cliente'}
    .Path('clientes')
      .Tag('Cliente API')
      .Get('Lista clientes', 'Lista todos clientes')
        .AddParamQuery('nome', 'Parte ou nome completo de um cliente')
        .&End
        .AddParamQuery('email', 'Email do cliente desejado')
        .&End
        .AddParamQuery('page', 'Número da página atual')
        .&End
        .AddParamQuery('perPage', 'Registro por página')
        .&End
        .AddResponse(200, 'operação bem sucedida')
          .Schema(Tpessoas)
          .IsArray(True)
        .&End
        .AddResponse(400, 'bad request')
          .Schema(TAPIError)
        .&End
        .AddResponse(500, '')
          .Schema(TAPIError)
        .&End
      .&End
      .Post('Novo cliente', 'Adiciona um novo cliente')
          .AddParamBody('Cliente data', 'Cliente data')
            .Required(True)
            .Schema(Tpessoas)
          .&End
          .AddResponse(201, 'cliente criado com sucesso!')
            .Schema(TAPISuccess)
          .&End
          .AddResponse(400, 'bad request')
            .Schema(TAPIError)
          .&End
          .AddResponse(500, 'internal server error')
            .Schema(TAPIError)
          .&End
       .&End
      .&End
    .&End
    .Path('clientes/:id')
      .Tag('Cliente API')
      .Put('Atualiza cliente', 'Atualiza dados do cliente')
          .AddParamBody('Cliente data', 'Cliente data')
            .Required(True)
            .Schema(Tpessoas)
          .&End
          .AddResponse(201, 'cliente criado com sucesso!')
            .Schema(TAPISuccess)
          .&End
          .AddResponse(400, 'bad request')
            .Schema(TAPIError)
          .&End
          .AddResponse(500, 'internal server error')
            .Schema(TAPIError)
          .&End
      .&End
    .&End
    .Path('clientes/:id')
      .Tag('Cliente API')
      .Get('Lista cliente', 'Lista os dados de cliente específico')
        .AddParamQuery('id', 'Código do cliente desejado').&End
        .AddResponse(201, 'cliente retornado com sucesso!').Schema(Tpessoas).&End
      .&End
    .&End
    .Path('clientes/:id/delete')
      .Tag('Cliente API')
      .Delete('Deleta cliente', 'Deleta cliente e seu histórico')
        .AddParamQuery('id', 'Código do cliente desejado').&End
        .AddResponse(201, 'cliente deletado com sucesso!').Schema(TAPISuccess).&End
      .&End
    .&End
{$ENDREGION}

{$REGION 'Módulo Pacotes de Créditos'}
    .Path('pacotes-creditos')
      .Tag('Pacotes Créditos API')
      .Get('Lista pacotes de crédtios', 'Lista todos pacotes de créditos')
        .AddParamQuery('nome', 'Parte ou nome completo do pacote')
        .&End
        .AddParamQuery('page', 'Número da página atual').&End
        .AddParamQuery('perPage', 'Registro por página').&End
        .AddResponse(200, 'operação bem sucedida')
          .Schema(Tpacotes_creditos)
          .IsArray(True)
        .&End
        .AddResponse(400, 'bad request')
          .Schema(TAPIError)
        .&End
        .AddResponse(500, '')
          .Schema(TAPIError)
        .&End
      .&End
      .Post('Novo Pacote', 'Adiciona um novo pacote')
          .AddParamBody('Pacote data', 'acote data')
            .Required(True)
            .Schema(Tpacotes_creditos)
          .&End
          .AddResponse(201, 'pacote criado com sucesso!')
            .Schema(TAPISuccess)
          .&End
          .AddResponse(400, 'bad request')
            .Schema(TAPIError)
          .&End
          .AddResponse(500, 'internal server error')
            .Schema(TAPIError)
          .&End
       .&End
      .&End
    .&End
    .Path('pacotes-creditos/:id')
      .Tag('Pacotes Créditos API')
      .Put('Atualiza pacotes', 'Atualiza dados do pacotes de créditos')
          .AddParamBody('Pacote data', 'Pacote data')
            .Required(True)
            .Schema(Tpacotes_creditos)
          .&End
          .AddResponse(201, 'pacote criado com sucesso!')
            .Schema(TAPISuccess)
          .&End
          .AddResponse(400, 'bad request')
            .Schema(TAPIError)
          .&End
          .AddResponse(500, 'internal server error')
            .Schema(TAPIError)
          .&End
      .&End
    .&End
    .Path('pacotes-creditos/:id')
      .Tag('Pacotes Créditos API')
      .Get('Lista pacote', 'Lista os dados de pacote de créditos')
        .AddParamQuery('id', 'Código do pacote desejado').&End
        .AddResponse(201, 'pacote retornado com sucesso!')
          .Schema(Tpacotes_creditos).&End
      .&End
    .&End
    .Path('pacotes-creditos/:id/delete')
      .Tag('Pacotes Créditos API')
      .Delete('Deleta pacotes créditos', 'Deleta pacote de crédito')
        .AddParamQuery('id', 'Código do pacote desejado').&End
        .AddResponse(201, 'pacote deletado com sucesso!').Schema(TAPISuccess).&End
      .&End
    .&End
{$ENDREGION}

    .&End;

  THorse.Host := '127.0.0.1';
  THorse.Listen(3000,
    procedure
    begin
      Writeln(Format('Server is runing on %s:%d', [THorse.Host, THorse.Port]));
      Readln;
    end);

end.
