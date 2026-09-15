-- ============================================================
-- BASELINE: dbo.FM Shopee Cadastro Base Frete - MOTORISTAS (Pgtos)
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[FM Shopee Cadastro Base Frete - MOTORISTAS (Pgtos)]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FM Shopee Cadastro Base Frete - MOTORISTAS (Pgtos)](
	[OPERAÇÃO] [nvarchar](50) NULL,
	[Tipo_de_contrato] [nvarchar](50) NULL,
	[Service_Center] [nvarchar](50) NULL,
	[Cidade] [nvarchar](1) NULL,
	[Tipo_de_veículo] [nvarchar](50) NULL,
	[Início_da_Faixa] [smallint] NULL,
	[Fim_da_Faixa] [smallint] NULL,
	[Valor_do_Frete_PACOTE_LM] [varchar](50) NULL,
	[Valor_do_frete_PM_PACOTE_LM] [varchar](max) NULL,
	[Valor_do_Frete_Fixo] [nvarchar](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
