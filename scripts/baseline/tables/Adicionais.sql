-- ============================================================
-- BASELINE: dbo.Adicionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Adicionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Adicionais](
	[TipoDeContrato] [int] NULL,
	[ServiceCenter] [varchar](50) NULL,
	[TipoDeVeiculo] [int] NULL,
	[ValorAdicional0_60] [varchar](10) NULL,
	[ValorAdicional61_75] [varchar](10) NULL,
	[ValorAdicional76_85] [varchar](10) NULL,
	[ValorAdicional86_90] [varchar](10) NULL,
	[ValorAdicionalAcimaDe90] [varchar](10) NULL
) ON [PRIMARY]
GO
