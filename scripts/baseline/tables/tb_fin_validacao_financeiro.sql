-- ============================================================
-- BASELINE: dbo.tb_fin_validacao_financeiro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_validacao_financeiro]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_validacao_financeiro](
	[IdTransportadora] [int] NULL,
	[Periodo] [int] NULL,
	[Etapa] [varchar](250) NULL,
	[Indicador] [varchar](250) NULL,
	[Valor] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
