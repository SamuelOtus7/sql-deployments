-- ============================================================
-- BASELINE: dbo.UspInsereParametrosIniciais
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspInsereParametrosIniciais]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspInsereParametrosIniciais]
as
declare @cd_cliente int 
	   ,@nmOperacao varchar(2) 
	   ,@CdOperacao int 

select @CdOperacao = lst_cd_lista
 from  tb_lista
where  lst_nm_lista ='Operações Marketplace'
  and  lst_cd_cliente = @cd_cliente
  and  lst_ds_valor = @nmOperacao

INSERT INTO tmp_testeDeParametros  -- alterar para a tabela de parametros após testes
(prm_in_ativo,prm_cod_operacao,prm_cod_Cliente,prm_dh_modificacao,prm_cd_usuario_modificacao,prm_dh_criacao,prm_cd_usuario_criacao,prm_nm_parametro, prm_ds_parametro, prm_ds_chave, prm_ds_valor, prm_ds_placeholder, prm_ds_options, prm_ds_categoria, prm_ds_tipo) 
VALUES
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-reenviar-comprovantes', N'Parâmetro para habilitar o reenvio de comprovantes já aprovados', N'Habilitar reenvio de comprovantes já aprovados', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-minhas rotas', N'Parâmetro para habilitar a tela de minhas rotas no aplicativo.', N'Visibildade tela minhas rotas', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-financeiro-notas fiscais', N'Parâmetro para habilitar a tela de financeiro-notas fiscais no aplicativo.', N'Visibildade tela financeiro-notas fiscais', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-financeiro-pedagio', N'Parâmetro para habilitar a tela de financeiro-pedagio no aplicativo.', N'Visibildade tela financeiro-pedagio', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos', N'Parâmetro para habilitar a tela de documentos no aplicativo.', N'Visibildade tela documentos', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos-pagamento seguradora', N'Parâmetro para habilitar a tela de documentos-pagamento seguradora no aplicativo.', N'Visibildade tela documentos-pagamento seguradora', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-mensagens', N'Parâmetro para habilitar a tela de mensagens no aplicativo.', N'Visibildade tela mensagens', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-km', N'Parâmetro para habilitar a visibilidades das informações de KM no aplicativo.', N'Visibildade de km', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos-dados-motorista', N'Parâmetro para habilitar a tela de documentos no aplicativo dados motorista.', N'Visibildade tela documentos dados motorista', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos-comprovantes', N'Parâmetro para habilitar a tela de documentos no aplicativo comprovantes.', N'Visibildade tela documentos comprovantes', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos-contratos', N'Parâmetro para habilitar a tela de documentos no aplicativo contratos.', N'Visibildade tela documentos contratos', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos-termos', N'Parâmetro para habilitar a tela de documentos no aplicativo termos.', N'Visibildade tela documentos termos', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos-pag-seguradora', N'Parâmetro para habilitar a tela de documentos no aplicativo seguradora.', N'Visibildade tela documentos seguradora', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-resultados', N'Parâmetro para habilitar a tela de resultados no aplicativo.', N'Visibildade tela resultados', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-acesso-gr-vencido', N'Bloquear o acesso do motorista no app com GR vencido', N'Bloquear o acesso do motorista no app com GR vencido', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-comprovantes-pedagio-dados', N'Parâmetro para exibir dados adicionais de pedágio na tela de comprovantes.', N'app-visibilidade-tela-comprovantes-pedagio-dados', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'Informações comprovantes - Configurações', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'APP - Push Notifications', N'Enviar alerta para motoristas que não fizeram upload da NF', N'app-envio-push-notification', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP - Configurações', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-habilitar-cpf-cadastro', N'Habilitar o campo CPF na tela de solicitação de cadastros', N'Habilitar o campo CPF na tela de solicitação de cadastros', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'Configuração APP mobile', N'', N'mobile_configuration', N'{ "cadastro": { "confirmacao": "Solicitar cadastro" }, "home": {"label_contadores": { "rotas": "Rotas", "pacotes": "Pacotes", "sucesso": "Sucesso", "insucesso": "Insucesso" }} }', N'', NULL, N'Configuração APP mobile', N'string'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'Home limite últimos lançamentos (dias)', N'Limite para Home do APP', N'home_limite_ultimos_lancamentos', N'2', N'Limite para Home do APP', N'', N'APP - Configurações', N'number'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'Limite disponibilidade(dias)', N'Limite disponibilidade(dias) do motorista APP', N'antecedencia_disponibilidade_maxima', N'1', N'Limite disponibilidade(dias)', N'', N'APP - Configurações', N'number'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'Frequência de Aplicação CheckList', N'Limite disponibilidade(dias) do motorista APP', N'cron_checklist_motorista', N'0 0 * * 4', N'Limite disponibilidade(dias)', N'', N'APP - Configurações', N'number'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'home_texto_faturamento', N'Texto para tela home do APP (limite)', N'home_texto_faturamento', N'Visão consolidada dos últimos 15 dias', N'', N'', N'APP - Configurações', N'string'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'primeiro-acesso-documentos', N'Parâmetro para habilitar a verificação de acesso com restrição a aba de documentos', N'primeiro-acesso-documentos', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'primeiro-acesso-documentos-excecao', N'Parâmetro para habilitar excecao para os IDS de usuário', N'primeiro-acesso-documentos-excecao', N'', N'', N'', N'APP - Configurações', N'string'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'primeiro-acesso-comprovantes', N'Parâmetro para habilitar a verificação de acesso com restrição a aba comprovantes', N'primeiro_acesso_comprovantes', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'primeiro-acesso-contratos', N'Parâmetro para habilitar a verificação de acesso com restrição a aba contratos', N'primeiro_acesso_contratos', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'primeiro-acesso-dados-motorista', N'Parâmetro para habilitar a verificação de acesso com restrição a aba dados motorista', N'primeiro_acesso_dados_motorista', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'primeiro-acesso-termos', N'Parâmetro para habilitar a verificação de acesso com restrição a aba termos', N'primeiro_acesso_termos', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'APP - Utilizar matricula para inclusão de pedagios', N'Vincular o número de matrícula ao envio de pedágios', N'Vincular matricula no pedagio', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP - Configurações', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-documentos-adm', N'Parâmetro para habilitar a tela de documentos no aplicativo para Administrativo', N'Visibildade tela documentos Administrativos', N'true', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP-ADM', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-planejamento', N'Parâmetro para habilitar a tela de planejamento no aplicativo.', N'Visibildade tela documentos planejamento', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'app-visibilidade-tela-financeiro-notas fiscais-adm', N'Parâmetro para habilitar a tela de financeiro-notas fiscais no aplicativo para Administrativo', N'Visibildade tela financeiro-notas fiscais-adm', N'false', N'', N'[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]', N'APP-ADM', N'select'),
  (1,@CdOperacao,@cd_cliente,getdate(),7,getdate(),7,N'Quantidade de NF''a que podem ser anexadas', N'Quantidade de NF''a que podem ser anexadas', N'numero_maximo_de_arquivos_permitidos', N'2', N'', NULL, N'APP - Configurações', N'number')


GO
