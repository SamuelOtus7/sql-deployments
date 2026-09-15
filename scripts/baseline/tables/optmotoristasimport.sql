-- ============================================================
-- BASELINE: dbo.optmotoristasimport
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[optmotoristasimport]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[optmotoristasimport](
	[MATRICULA] [bigint] NULL,
	[NOME_MOTORISTA] [nvarchar](50) NULL,
	[CPF] [bigint] NULL,
	[DATA_NASCIMENTO] [nvarchar](1) NULL,
	[TIPO_CONTRATO] [nvarchar](50) NULL,
	[Status_contrato] [nvarchar](50) NULL,
	[NOME_AJUDANTE] [nvarchar](1) NULL,
	[CPF_AJUDANTE] [nvarchar](1) NULL,
	[CONTATO_AJUDANTE] [nvarchar](1) NULL,
	[ENDERECO_MOTORISTA] [nvarchar](1) NULL,
	[CEP_MOTORISTA] [nvarchar](1) NULL,
	[RUA_MOTORISTA] [nvarchar](50) NULL,
	[NUMERO_CASA] [smallint] NULL,
	[COMPLEMENTO] [nvarchar](1) NULL,
	[BAIRRO_MOTORISTA] [nvarchar](50) NULL,
	[CIDADE_MOTORISTA] [nvarchar](50) NULL,
	[ESTADO_MOTORISTA] [nvarchar](1) NULL,
	[MARKETPLACE] [nvarchar](50) NULL,
	[BANCO] [nvarchar](1) NULL,
	[NOME_TITULAR_CONTA] [nvarchar](1) NULL,
	[CPF_TITULAR_CONTA] [nvarchar](1) NULL,
	[TIPO_CHAVE] [nvarchar](1) NULL,
	[CHAVE_PIX] [nvarchar](1) NULL,
	[CELULAR_MOTORISTA] [bigint] NULL,
	[TELEFONE_MOTORISTA] [nvarchar](1) NULL,
	[CELUALR_2_MOTORISTA] [nvarchar](1) NULL,
	[EMAIL_MOTORISTA] [nvarchar](50) NULL,
	[NOME_CONTATO_EMERGENCIA] [nvarchar](1) NULL,
	[TELEFONE_CONTATO_EMERGENCIA] [nvarchar](1) NULL,
	[CELULAR_CONTATO_EMERGENCIA] [nvarchar](1) NULL,
	[CELULAR_CONTATO_EMERGENCIA_2] [nvarchar](1) NULL,
	[GRAU_PARENTESCO_CONTATO_EMERGENCIA] [nvarchar](1) NULL,
	[TIPO_EMPRESA_MOTORISTA] [nvarchar](50) NULL,
	[EMPRESA_PROPRIA_MOTORISTA] [nvarchar](1) NULL,
	[NOME_MAE_MOTORISTA] [nvarchar](1) NULL,
	[NOME_PAI_MOTORISTA] [nvarchar](1) NULL,
	[DATA_RENOVACAO_GR] [nvarchar](1) NULL,
	[TIPO_MOTORISTA] [nvarchar](1) NULL,
	[TIPO_NACIONALIDADE] [nvarchar](1) NULL,
	[PAIS_MOTORISTA] [nvarchar](1) NULL,
	[RG_MOTORISTA] [nvarchar](1) NULL,
	[ESTADO_EMISSOR_RG_MOTORISTA] [nvarchar](1) NULL,
	[PRONTUARIO_CNH_MOTORISTA] [nvarchar](1) NULL,
	[NUMERO_CNH_MOTORISTA] [nvarchar](1) NULL,
	[DATA_PRIMEIRA_CNH_MOTORISTA] [nvarchar](1) NULL,
	[DATA_VENCIMENTO_CNH_MOTORISTA] [nvarchar](1) NULL,
	[RENACH_CNH_MOTORISTA] [nvarchar](1) NULL,
	[SIGLA_SERVICE_CENTER_HUB_ATUACAO] [nvarchar](50) NULL,
	[LIBERAR_ACESSO_APP] [nvarchar](50) NULL
) ON [PRIMARY]
GO
