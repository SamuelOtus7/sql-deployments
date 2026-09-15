-- ============================================================
-- BASELINE: dbo.CadastroMotRodo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[CadastroMotRodo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CadastroMotRodo](
	[NOME_MOTORISTA] [nvarchar](50) NULL,
	[CPF] [nvarchar](50) NULL,
	[DATA_DE_NASC] [date] NULL,
	[TIPO_DE_CONTRATO] [nvarchar](50) NULL,
	[STATUS_DO_CONTRATO] [nvarchar](50) NULL,
	[RESPONSAVEL_CONTRATO] [nvarchar](50) NULL,
	[CIDADE_MOTORISTA] [nvarchar](50) NULL,
	[ESTADO_MOTORISTA] [nvarchar](50) NULL,
	[BANCO] [nvarchar](50) NULL,
	[NOME_DO_TITULAR_DA_CONTA] [nvarchar](50) NULL,
	[CPF_TITULAR_DA_CONTA] [nvarchar](50) NULL,
	[AGENCIA] [nvarchar](50) NULL,
	[CONTA] [nvarchar](50) NULL,
	[TIPO_CHAVE_PIX] [nvarchar](50) NULL,
	[PIX] [nvarchar](50) NULL,
	[TIPO_CONTA] [nvarchar](50) NULL,
	[CELULAR_MOTORISTA] [nvarchar](50) NULL,
	[EMAIL_MOTORISTA] [nvarchar](50) NULL
) ON [PRIMARY]
GO
