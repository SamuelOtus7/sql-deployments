-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes_para_reprocessar
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes_para_reprocessar]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes_para_reprocessar](
	[CodigoPacote] [varchar](30) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[IdStation] [int] NOT NULL
) ON [PRIMARY]
GO
