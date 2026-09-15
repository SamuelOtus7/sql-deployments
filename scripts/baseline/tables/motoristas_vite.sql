-- ============================================================
-- BASELINE: dbo.motoristas_vite
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[motoristas_vite]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[motoristas_vite](
	[MATRÍCULA] [varchar](max) NULL,
	[NOME MOTORISTA] [varchar](max) NULL,
	[CPF] [varchar](max) NULL,
	[DATA DE NASC.] [varchar](max) NULL,
	[TIPO DE CONTRATO] [varchar](max) NULL,
	[NOME DO AJUDANTE] [varchar](max) NULL,
	[CPF AJUDANTE] [varchar](max) NULL,
	[CONTATO AJUDANTE] [varchar](max) NULL,
	[ENDEREÇO MOTORISTA] [varchar](max) NULL,
	[CEP MOTORISTA] [varchar](max) NULL,
	[RUA MOTORISTA] [varchar](max) NULL,
	[NÚMERO CASA] [varchar](max) NULL,
	[COMPLEMENTO] [varchar](max) NULL,
	[BAIRRO MOTORISTA] [varchar](max) NULL,
	[CIDADE MOTORISTA] [varchar](max) NULL,
	[ESTADO MOTORISTA] [varchar](max) NULL,
	[MARKETPLACE] [varchar](max) NULL,
	[BANCO] [varchar](max) NULL,
	[NOME DO TITULAR DA CONTA] [varchar](max) NULL,
	[CPF TITULAR DA CONTA] [varchar](max) NULL,
	[AGÊNCIA] [varchar](max) NULL,
	[CONTA] [varchar](max) NULL,
	[TIPO CONTA] [varchar](max) NULL,
	[CELULAR MOTORISTA] [varchar](max) NULL,
	[TELEFONE MOTORISTA] [varchar](max) NULL,
	[CELUALR 2 MOTORISTA] [varchar](max) NULL,
	[E-MAIL MOTORISTA] [varchar](max) NULL,
	[NOME CONTATO DE EMERGÊNCIA] [varchar](max) NULL,
	[TELEFONE CONTATO DE EMERGÊNCIA] [varchar](max) NULL,
	[CELULAR CONTATO EMERGÊNCIA] [varchar](max) NULL,
	[CELULAR CONTATO EMERGÊNCIA 2] [varchar](max) NULL,
	[GRAU PARENTESCO CONTATOD DE EMERGÊNCIA] [varchar](max) NULL,
	[TIPO EMPRESA MOTORISTA] [varchar](max) NULL,
	[EMPRESA PRÓPRIA MOTORISTA? (SIM OU NÃO)] [varchar](max) NULL,
	[NOME DA MÃE MOTORISTA] [varchar](max) NULL,
	[NOME DO PAI MOTORISTA] [varchar](max) NULL,
	[DATA RENOVAÇÃO GR] [varchar](max) NULL,
	[TIPO MOTORISTA] [varchar](max) NULL,
	[TIPO NACIONALIDADE] [varchar](max) NULL,
	[PAÍS MOTORISTA] [varchar](max) NULL,
	[RG MOTORISTA] [varchar](max) NULL,
	[ESTADO EMISSOR RG MOTORISTA] [varchar](max) NULL,
	[PRONTUÁRIO CNH MOTORISTA] [varchar](max) NULL,
	[NÚMERO CNH MOTORISTA] [varchar](max) NULL,
	[DATA PRIMEIRA CNH MOTORISTA] [varchar](max) NULL,
	[DATA VENCIMENTO CNH MOTORISTA] [varchar](max) NULL,
	[TIPO CNH MOTORISTA] [varchar](max) NULL,
	[RENACH CNH MOTORISTA] [varchar](max) NULL,
	[SIGLA SERVICE CENTER OU HUB DE ATUAÇÃO] [varchar](max) NULL,
	[LIBERAR ACESSO PARA VALORES FINANCEIROS NO APP DO MOTORISTA?] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
