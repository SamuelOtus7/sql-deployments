-- ============================================================
-- BASELINE: dbo.AdicionalMotorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[AdicionalMotorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdicionalMotorista](
	[TipoContrato] [varchar](255) NULL,
	[ServiceCenter] [varchar](255) NULL,
	[Cidade] [varchar](255) NULL,
	[TipoVeiculo] [varchar](255) NULL,
	[TipoAdicionalDomingoFeriado] [varchar](255) NULL,
	[ValorAdicionalDomingo] [decimal](10, 2) NULL,
	[TipoAdicionalCicloPM] [varchar](255) NULL,
	[ValorAdicionalCiclo] [decimal](10, 2) NULL,
	[TipoAdicionalAjudante] [varchar](255) NULL,
	[ValorAdicionalAjudante] [decimal](10, 2) NULL,
	[TipoAdicionalRisco] [varchar](255) NULL,
	[ValorAdicionalRisco] [decimal](10, 2) NULL,
	[ValorAdicionalPool] [decimal](10, 2) NULL,
	[ValorAdicional060] [decimal](10, 2) NULL,
	[ValorAdicional6190] [decimal](10, 2) NULL,
	[ValorAdicional91Mais] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
