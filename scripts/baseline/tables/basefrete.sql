-- ============================================================
-- BASELINE: dbo.basefrete
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[basefrete]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[basefrete](
	[Tipo_de_contrato] [nvarchar](50) NOT NULL,
	[Service_Center] [nvarchar](50) NOT NULL,
	[Cidade] [nvarchar](1) NULL,
	[Tipo_de_veículo] [nvarchar](50) NOT NULL,
	[Início_da_Faixa] [tinyint] NOT NULL,
	[Fim_da_Faixa] [smallint] NOT NULL,
	[Valor_do_Frete] [nvarchar](1) NULL,
	[Valor_do_frete_PM] [nvarchar](1) NULL,
	[Valor_do_Frete_Fixo] [money] NOT NULL
) ON [PRIMARY]
GO
