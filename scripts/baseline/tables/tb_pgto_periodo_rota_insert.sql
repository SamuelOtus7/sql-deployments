-- ============================================================
-- BASELINE: dbo.tb_pgto_periodo_rota_insert
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_periodo_rota_insert]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_periodo_rota_insert](
	[ppr_cd_periodo] [int] NULL,
	[ppr_nome_motorista] [varchar](200) NULL,
	[ppr_vl_total] [decimal](10, 2) NULL,
	[ppr_lcto_observacao] [varchar](200) NULL,
	[ppr_data_referencia] [date] NULL
) ON [PRIMARY]
GO
