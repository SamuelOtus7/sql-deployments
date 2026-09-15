-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura_mo_upload
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura_mo_upload]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura_mo_upload](
	[Produto] [varchar](255) NULL,
	[Pais] [varchar](255) NULL,
	[Transportadora] [varchar](255) NULL,
	[Milha] [varchar](255) NULL,
	[ID] [varchar](255) NULL,
	[Periodo] [varchar](255) NULL,
	[Tipo] [varchar](255) NULL,
	[Status] [varchar](255) NULL,
	[total] [varchar](255) NULL,
	[IdTransportadora] [int] NULL,
	[Ano] [int] NULL,
	[Mes] [int] NULL,
	[Quinzena] [int] NULL
) ON [PRIMARY]
GO
