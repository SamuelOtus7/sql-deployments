-- ============================================================
-- BASELINE: dbo.Motoristasspot
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Motoristasspot]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Motoristasspot](
	[MATRÍCULA] [nvarchar](1) NULL,
	[NOME_MOTORISTA] [nvarchar](255) NULL,
	[CPF] [bigint] NULL,
	[DATA_DE_NASC] [nvarchar](1) NULL,
	[TIPO_DE_CONTRATO] [nvarchar](50) NULL,
	[NOME_DO_AJUDANTE] [nvarchar](1) NULL,
	[CPF_AJUDANTE] [nvarchar](1) NULL,
	[CONTATO_AJUDANTE] [nvarchar](1) NULL,
	[ENDEREÇO_MOTORISTA] [nvarchar](1) NULL,
	[CEP_MOTORISTA] [nvarchar](1) NULL,
	[RUA_MOTORISTA] [nvarchar](1) NULL,
	[NÚMERO_CASA] [nvarchar](1) NULL,
	[COMPLEMENTO] [nvarchar](1) NULL,
	[BAIRRO_MOTORISTA] [nvarchar](1) NULL,
	[CIDADE_MOTORISTA] [nvarchar](1) NULL,
	[ESTADO_MOTORISTA] [nvarchar](1) NULL,
	[MARKETPLACE] [nvarchar](1) NULL,
	[BANCO] [nvarchar](1) NULL,
	[NOME_DO_TITULAR_DA_CONTA] [nvarchar](1) NULL,
	[CPF_TITULAR_DA_CONTA] [nvarchar](1) NULL,
	[AGÊNCIA] [nvarchar](1) NULL,
	[CONTA] [nvarchar](1) NULL,
	[TIPO_CONTA] [nvarchar](1) NULL,
	[CELULAR_MOTORISTA] [bigint] NULL,
	[TELEFONE_MOTORISTA] [nvarchar](1) NULL,
	[CELUALR_2_MOTORISTA] [nvarchar](1) NULL,
	[E_MAIL_MOTORISTA] [nvarchar](50) NULL,
	[NOME_CONTATO_DE_EMERGÊNCIA] [nvarchar](1) NULL,
	[TELEFONE_CONTATO_DE_EMERGÊNCIA] [nvarchar](1) NULL,
	[CELULAR_CONTATO_EMERGÊNCIA] [nvarchar](1) NULL,
	[CELULAR_CONTATO_EMERGÊNCIA_2] [nvarchar](1) NULL,
	[GRAU_PARENTESCO_CONTATOD_DE_EMERGÊNCIA] [nvarchar](1) NULL,
	[TIPO_EMPRESA_MOTORISTA] [nvarchar](1) NULL,
	[EMPRESA_PRÓPRIA_MOTORISTA_SIM_OU_NÃO] [nvarchar](1) NULL,
	[NOME_DA_MÃE_MOTORISTA] [nvarchar](1) NULL,
	[NOME_DO_PAI_MOTORISTA] [nvarchar](1) NULL,
	[DATA_RENOVAÇÃO_GR] [nvarchar](1) NULL,
	[TIPO_MOTORISTA] [nvarchar](1) NULL,
	[TIPO_NACIONALIDADE] [nvarchar](1) NULL,
	[PAÍS_MOTORISTA] [nvarchar](1) NULL,
	[RG_MOTORISTA] [nvarchar](1) NULL,
	[ESTADO_EMISSOR_RG_MOTORISTA] [nvarchar](1) NULL,
	[PRONTUÁRIO_CNH_MOTORISTA] [nvarchar](1) NULL,
	[NÚMERO_CNH_MOTORISTA] [nvarchar](1) NULL,
	[DATA_PRIMEIRA_CNH_MOTORISTA] [nvarchar](1) NULL,
	[DATA_VENCIMENTO_CNH_MOTORISTA] [nvarchar](1) NULL,
	[TIPO_CNH_MOTORISTA] [nvarchar](1) NULL,
	[RENACH_CNH_MOTORISTA] [nvarchar](1) NULL,
	[SIGLA_SERVICE_CENTER_OU_HUB_DE_ATUAÇÃO] [nvarchar](1) NULL,
	[LIBERAR_ACESSO_PARA_VALORES_FINANCEIROS_NO_APP_DO_MOTORISTA] [nvarchar](1) NULL
) ON [PRIMARY]
GO
