-- ============================================================
-- BASELINE: dbo.tb_rotas_para_reprocessar
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rotas_para_reprocessar]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rotas_para_reprocessar](
	[IdRota] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[IdTransportadora] [int] NOT NULL
) ON [PRIMARY]
GO
