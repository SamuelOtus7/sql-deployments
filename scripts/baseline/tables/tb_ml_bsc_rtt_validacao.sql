-- ============================================================
-- BASELINE: dbo.tb_ml_bsc_rtt_validacao
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_bsc_rtt_validacao]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_bsc_rtt_validacao](
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Quinzena] [int] NOT NULL,
	[IdRota] [int] NOT NULL,
	[Odometro] [decimal](8, 4) NOT NULL,
	[DistanciaSVC] [decimal](8, 4) NOT NULL,
	[KmTotal] [decimal](8, 4) NOT NULL
) ON [PRIMARY]
GO
