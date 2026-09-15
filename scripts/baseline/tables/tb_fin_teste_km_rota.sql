-- ============================================================
-- BASELINE: dbo.tb_fin_teste_km_rota
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_teste_km_rota]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_teste_km_rota](
	[idRota] [int] NULL,
	[totalMetrosComSVC] [float] NULL,
	[totalTempoComSVC] [float] NULL,
	[totalKmComSVC] [float] NULL,
	[totalMetrosAppSemSVC] [float] NULL,
	[totalTempoAppSemSVC] [float] NULL,
	[totalKmAppSemSVC] [float] NULL,
	[totalKMPacotesComSVC] [float] NULL,
	[hashMapaApp] [varchar](255) NULL,
	[hashMapaPacotes] [varchar](255) NULL,
	[pontosAppRotasTotalKmSemRetorno] [decimal](18, 4) NULL,
	[pontosRotasPacotesKmSemRetorno] [decimal](18, 4) NULL,
	[pontosAppRotasTotalKmRetornoLinhaReta] [decimal](18, 4) NULL,
	[pontosAppRotasTotalKmRetornoRoviario] [decimal](18, 4) NULL,
	[pontosRotasPacotesKmRetornoLinhaReta] [decimal](18, 4) NULL,
	[pontosRotasPacotesKmRetornoRoviario] [decimal](18, 4) NULL
) ON [PRIMARY]
GO
