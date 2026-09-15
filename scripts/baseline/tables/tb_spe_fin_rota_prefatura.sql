-- ============================================================
-- BASELINE: dbo.tb_spe_fin_rota_prefatura
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_fin_rota_prefatura]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_fin_rota_prefatura](
	[rpre_cod] [int] IDENTITY(1,1) NOT NULL,
	[rpre_dt_data] [date] NULL,
	[rpre_cd_rota] [varchar](50) NULL,
	[rpre_km_rodado] [numeric](17, 0) NULL,
	[rpre_in_risco] [int] NULL,
	[rpre_data_Atualizacao] [datetime] NULL
) ON [PRIMARY]
GO
