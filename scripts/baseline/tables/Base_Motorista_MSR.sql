-- ============================================================
-- BASELINE: dbo.Base_Motorista_MSR
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Base_Motorista_MSR]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Base_Motorista_MSR](
	[MATRICULA] [varchar](255) NULL,
	[NOME_MOTORISTA] [varchar](255) NULL,
	[CPF] [varchar](255) NULL,
	[DATA_NASCIMENTO] [varchar](255) NULL,
	[TIPO_CONTRATO] [varchar](255) NULL,
	[STATUS_CONTRATO] [varchar](255) NULL,
	[RESPONSAVEL_CONTRATO] [varchar](255) NULL,
	[NOME_AJUDANTE] [varchar](255) NULL,
	[CPF_AJUDANTE] [varchar](255) NULL,
	[CONTATO_AJUDANTE] [varchar](255) NULL,
	[ENDERECO] [varchar](255) NULL,
	[CEP] [varchar](255) NULL,
	[RUA] [varchar](255) NULL,
	[NUMERO] [varchar](255) NULL,
	[COMPLEMENTO] [varchar](255) NULL,
	[BAIRRO] [varchar](255) NULL,
	[CIDADE] [varchar](255) NULL,
	[ESTADO] [varchar](255) NULL,
	[MARKETPLACE] [varchar](255) NULL,
	[BANCO] [varchar](255) NULL,
	[NOME_TITULAR_CONTA] [varchar](255) NULL,
	[CPF_TITULAR_CONTA] [varchar](255) NULL,
	[AGENCIA] [varchar](255) NULL,
	[CONTA] [varchar](255) NULL,
	[TIPO_CONTA] [varchar](255) NULL,
	[CELULAR] [varchar](255) NULL,
	[TELEFONE] [varchar](255) NULL,
	[CELUALR_2] [varchar](255) NULL,
	[EMAIL] [varchar](255) NULL,
	[NOME_CONTATO_EMERGENCIA] [varchar](255) NULL,
	[TELEFONE_CONTATO_EMERGENCIA] [varchar](255) NULL,
	[CELULAR_CONTATO_EMERGENCIA] [varchar](255) NULL,
	[CELULAR_CONTATO_EMERGENCIA_2] [varchar](255) NULL,
	[GRAU_PARENTESCO_CONTATO_EMERGENCIA] [varchar](255) NULL,
	[TIPO_EMPRESA] [varchar](255) NULL,
	[EMPRESA_PROPRIA] [varchar](255) NULL,
	[NOME_ MAE] [varchar](255) NULL,
	[NOME_PAI] [varchar](255) NULL,
	[DATA_RENOVACAO_GR] [varchar](255) NULL,
	[TIPO_MOTORISTA] [varchar](255) NULL,
	[TIPO_NACIONALIDADE] [varchar](255) NULL,
	[PAIS] [varchar](255) NULL,
	[RG] [varchar](255) NULL,
	[ESTADO_EMISSOR_RG] [varchar](255) NULL,
	[PRONTUARIO_CNH] [varchar](255) NULL,
	[NUMERO_CNH] [varchar](255) NULL,
	[DATA_PRIMEIRA_CNH] [varchar](255) NULL,
	[DATA_VENC_CNH] [varchar](255) NULL,
	[TIPO_CNH] [varchar](255) NULL,
	[RENACH_CNH] [varchar](255) NULL,
	[SERVICE_CENTER] [varchar](255) NULL,
	[LIBERAR_ACESSO] [varchar](255) NULL
) ON [PRIMARY]
GO
