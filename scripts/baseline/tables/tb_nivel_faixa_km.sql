-- ============================================================
-- BASELINE: dbo.tb_nivel_faixa_km
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_nivel_faixa_km]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_nivel_faixa_km](
	[servicecenter] [varchar](50) NULL,
	[FaixaKm] [varchar](10) NULL,
	[Ordem] [bigint] NULL
) ON [PRIMARY]
GO
