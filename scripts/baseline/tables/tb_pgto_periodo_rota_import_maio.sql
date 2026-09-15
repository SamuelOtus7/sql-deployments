-- ============================================================
-- BASELINE: dbo.tb_pgto_periodo_rota_import_maio
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_periodo_rota_import_maio]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_periodo_rota_import_maio](
	[ppr_cd_rota] [varchar](50) NULL,
	[ppr_cd_faixa_km] [varchar](20) NULL,
	[ppr_ds_placa] [varchar](50) NULL,
	[ppr_ds_tipo_veiculo] [varchar](50) NULL,
	[ppr_qt_pacotes] [int] NULL,
	[ppr_qt_pontos] [int] NULL,
	[ppr_qt_paradas] [int] NULL,
	[ppr_vl_base] [decimal](10, 2) NULL,
	[ppr_vl_paradas] [decimal](10, 2) NULL,
	[ppr_vl_ajudante] [decimal](10, 2) NULL,
	[ppr_vl_total] [decimal](10, 2) NULL,
	[ppr_base_principal] [varchar](max) NULL,
	[ppr_nome_motorista] [varchar](200) NULL,
	[ppr_data_referencia] [date] NULL,
	[nomecorrigido] [varchar](300) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
