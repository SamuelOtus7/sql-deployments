-- ============================================================
-- BASELINE: dbo.tb_prefatura_shopee
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_prefatura_shopee]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_prefatura_shopee](
	[rota] [varchar](50) NULL,
	[pacote] [varchar](50) NULL,
	[valorecebimento] [varchar](50) NULL,
	[cidade] [varchar](50) NULL,
	[data] [varchar](50) NULL
) ON [PRIMARY]
GO
