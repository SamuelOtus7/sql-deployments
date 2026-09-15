-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura_lh_upload
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura_lh_upload]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura_lh_upload](
	[IdTransportadora] [int] NULL,
	[Ano] [int] NULL,
	[Mes] [int] NULL,
	[Quinzena] [int] NULL,
	[Produto] [varchar](255) NULL,
	[Pais] [varchar](255) NULL,
	[Transportadora] [varchar](255) NULL,
	[Milha] [varchar](255) NULL,
	[IDPreFatura] [varchar](255) NULL,
	[Periodo] [varchar](255) NULL,
	[TipoPreFatura] [varchar](255) NULL,
	[Status] [varchar](255) NULL,
	[PrecoUnitario] [varchar](255) NULL,
	[Total] [varchar](255) NULL
) ON [PRIMARY]
GO
