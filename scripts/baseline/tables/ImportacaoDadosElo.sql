-- ============================================================
-- BASELINE: dbo.ImportacaoDadosElo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ImportacaoDadosElo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ImportacaoDadosElo](
	[MATRICULA] [varchar](255) NULL,
	[NOME_MOTORISTA] [varchar](255) NULL,
	[CPF] [varchar](255) NULL,
	[DATA_NASCIMENTO] [varchar](255) NULL,
	[TIPO_CONTRATO] [varchar](255) NULL,
	[NOME_AJUDANTE] [varchar](255) NULL,
	[CPF_AJUDANTE] [varchar](255) NULL,
	[CONTATO_AJUDANTE] [varchar](255) NULL,
	[ENDERECO_MOTORISTA] [varchar](255) NULL,
	[CEP_MOTORISTA] [varchar](255) NULL,
	[RUA_MOTORISTA] [varchar](255) NULL,
	[NUMERO_CASA] [varchar](255) NULL,
	[COMPLEMENTO] [varchar](255) NULL,
	[BAIRRO_MOTORISTA] [varchar](255) NULL,
	[CIDADE_MOTORISTA] [varchar](255) NULL,
	[ESTADO_MOTORISTA] [varchar](255) NULL,
	[MARKETPLACE] [varchar](255) NULL,
	[BANCO] [varchar](255) NULL,
	[NOME_TITULAR_CONTA ] [varchar](255) NULL,
	[CPF_TITULAR_CONTA] [varchar](255) NULL,
	[TIPO_CHAVE] [varchar](255) NULL,
	[CHAVE_PIX] [varchar](255) NULL,
	[CELULAR_MOTORISTA] [varchar](255) NULL,
	[TELEFONE_MOTORISTA] [varchar](255) NULL,
	[CELUALR_2_MOTORISTA] [varchar](255) NULL,
	[EMAIL_MOTORISTA] [varchar](255) NULL,
	[NOME_CONTATO_EMERGENCIA] [varchar](255) NULL,
	[TELEFONE_CONTATO_EMERGENCIA] [varchar](255) NULL,
	[CELULAR_CONTATO_EMERGENCIA] [varchar](255) NULL,
	[CELULAR_CONTATO_EMERGENCIA_2] [varchar](255) NULL,
	[GRAU_PARENTESCO_ CONTATO_EMERGENCIA] [varchar](255) NULL,
	[TIPO_EMPRESA_MOTORISTA] [varchar](255) NULL,
	[EMPRESA_PROPRIA_MOTORISTA] [varchar](255) NULL,
	[NOME_MAE_MOTORISTA] [varchar](255) NULL,
	[NOME_PAI_MOTORISTA] [varchar](255) NULL,
	[DATA_RENOVACAO_GR] [varchar](255) NULL,
	[TIPO_MOTORISTA] [varchar](255) NULL,
	[TIPO_NACIONALIDADE] [varchar](255) NULL,
	[PAIS_MOTORISTA] [varchar](255) NULL,
	[RG_MOTORISTA] [varchar](255) NULL,
	[ESTADO_EMISSOR_RG_MOTORISTA] [varchar](255) NULL,
	[PRONTUARIO_CNH_MOTORISTA] [varchar](255) NULL,
	[NUMERO_CNH_MOTORISTA] [varchar](255) NULL,
	[DATA_PRIMEIRA_CNH_MOTORISTA] [varchar](255) NULL,
	[DATA_VENCIMENTO_CNH_MOTORISTA] [varchar](255) NULL,
	[TIPO_CNH_MOTORISTA] [varchar](255) NULL,
	[RENACH_CNH_MOTORISTA] [varchar](255) NULL,
	[SIGLA_SERVICE_CENTER_HUB_ATUACAO] [varchar](255) NULL,
	[LIBERAR_ACESSO_APP] [varchar](255) NULL
) ON [PRIMARY]
GO
