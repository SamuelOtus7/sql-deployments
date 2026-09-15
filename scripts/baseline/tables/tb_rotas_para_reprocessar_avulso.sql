-- ============================================================
-- BASELINE: dbo.tb_rotas_para_reprocessar_avulso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rotas_para_reprocessar_avulso]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rotas_para_reprocessar_avulso](
	[IdRota] [bigint] NULL,
	[DataReferencia] [date] NULL,
	[IdTransportadora] [bigint] NULL
) ON [PRIMARY]
GO
