-- ============================================================
-- BASELINE: dbo.tb_ml_gps_maps_app_resumo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_gps_maps_app_resumo]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_gps_maps_app_resumo](
	[gmar_id] [int] IDENTITY(1,1) NOT NULL,
	[Rota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[Latitude] [decimal](18, 9) NULL,
	[Longitude] [decimal](18, 9) NULL,
	[Sequencia] [bigint] NULL
) ON [PRIMARY]
GO
