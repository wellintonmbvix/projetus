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
  Horse.JWT,
  JOSE.Core.JWT,
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
  controller.dto.historico_creditos.interfaces in 'src\controller\dto\controller.dto.historico_creditos.interfaces.pas',
  controller.dto.historico_creditos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.historico_creditos.interfaces.impl.pas',
  controller.historico_creditos in 'src\controller\controller.historico_creditos.pas',
  controller.dto.orcamentos.interfaces in 'src\controller\dto\controller.dto.orcamentos.interfaces.pas',
  controller.dto.orcamentos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.orcamentos.interfaces.impl.pas',
  controller.orcamentos in 'src\controller\controller.orcamentos.pas',
  controller.dto.historico_orcamentos.interfaces in 'src\controller\dto\controller.dto.historico_orcamentos.interfaces.pas',
  controller.dto.historico_orcamentos.interfaces.impl in 'src\controller\dto\implementation\controller.dto.historico_orcamentos.interfaces.impl.pas',
  controller.historico_orcamentos in 'src\controller\controller.historico_orcamentos.pas',
  api.swagger.doc in 'src\view\api.swagger.doc.pas',
  model.api.message in 'src\model\entity\model.api.message.pas',
  model.usuarios in 'src\model\entity\model.usuarios.pas',
  model.regras in 'src\model\entity\model.regras.pas',
  model.usuarios_regras in 'src\model\entity\model.usuarios_regras.pas',
  controller.dto.usuarios.interfaces in 'src\controller\dto\controller.dto.usuarios.interfaces.pas',
  controller.dto.usuarios.interfaces.impl in 'src\controller\dto\implementation\controller.dto.usuarios.interfaces.impl.pas',
  controller.dto.regras.interfaces in 'src\controller\dto\controller.dto.regras.interfaces.pas',
  controller.dto.regras.interfaces.impl in 'src\controller\dto\implementation\controller.dto.regras.interfaces.impl.pas',
  controller.usuarios in 'src\controller\controller.usuarios.pas',
  controller.login in 'src\controller\controller.login.pas',
  model.usuario.claims in 'src\model\entity\model.usuario.claims.pas',
  middleware.authmiddleware in 'src\middleware\middleware.authmiddleware.pas';

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
        .Use(HorseSwagger(Format('%s/swagger/doc/html', ['api/v1']),Format('%s/swagger/doc/json', ['api/v1'])))
        .Use(CORS)
        .Use(Jhonson('UTF-8'))
        .Use(HorseJWT('SuaSenhaMaisFraca@2025',
          THorseJWTConfig.New.SkipRoutes(['/api/v1/login',
                                          '/api/v1/profissionais',
                                          '/api/v1/clientes',
                                          '/api/v1/swagger/doc/html',
                                          '/api/v1/swagger/doc/json'])));

  // Controllers
  TControllerCliente.Registry;
  TControllerPacotesCreditos.Registry;
  TControllerServicos.Registry;
  TControllerProfissional.Registry;
  TControllerProfissionalPacoteCredito.Registry;
  TControllerProfissionaisServicos.Registry;
  TControllerHistoricoCreditos.Registry;
  TControllerOrcamentos.Registry;
  TControllerHistoricoOrcamentos.Registry;
  TControllerUsuarios.Registry;
  TControllerLogin.Registry;

  THorse.Host := '127.0.0.1';
  THorse.Listen(3000,
    procedure
    begin
      Writeln(Format('Server is runing on %s:%d', [THorse.Host, THorse.Port]));
      Readln;
    end);

end.
