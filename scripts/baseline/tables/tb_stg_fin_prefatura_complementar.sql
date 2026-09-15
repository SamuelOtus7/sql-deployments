-- ============================================================
-- BASELINE: dbo.tb_stg_fin_prefatura_complementar
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_fin_prefatura_complementar]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_fin_prefatura_complementar](
	[periodo] [varchar](20) NULL,
	[entity_id] [varchar](50) NULL,
	[provider_id] [varchar](50) NULL,
	[conceito_billing] [varchar](200) NULL,
	[total_a_pagar] [varchar](50) NULL,
	[entity_type] [varchar](50) NULL,
	[final_desicao] [varchar](100) NULL,
	[motivo_aprovacao] [varchar](500) NULL,
	[mlp_name] [varchar](200) NULL,
	[placa] [varchar](50) NULL,
	[data_rota] [varchar](20) NULL,
	[billing_km_range] [varchar](50) NULL,
	[new_km_range] [varchar](50) NULL,
	[c_qty_stops] [varchar](50) NULL,
	[b_qty_stops] [varchar](50) NULL,
	[svc] [varchar](100) NULL,
	[veiculo] [varchar](200) NULL,
	[stg_ds_arquivo] [varchar](260) NULL,
	[stg_dt_carga] [datetime2](0) NULL
) ON [PRIMARY]
GO
