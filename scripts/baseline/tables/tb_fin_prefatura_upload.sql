-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura_upload
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura_upload]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura_upload](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[Produto] [varchar](1000) NULL,
	[Pais] [varchar](1000) NULL,
	[Transportadora] [varchar](1000) NULL,
	[Milha] [varchar](1000) NULL,
	[IDPrefatura] [varchar](1000) NULL,
	[Periodo] [varchar](1000) NULL,
	[TipoPreFatura] [varchar](1000) NULL,
	[StatusPrefatura] [varchar](1000) NULL,
	[Column8] [varchar](50) NULL,
	[Column9] [varchar](50) NULL,
	[Column10] [varchar](50) NULL,
	[Column11] [varchar](50) NULL,
	[Column12] [varchar](50) NULL
) ON [PRIMARY]
GO
