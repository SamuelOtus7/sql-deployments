-- ============================================================
-- BASELINE: dbo.tb_dra_historico_rotas_aux
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_historico_rotas_aux]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_historico_rotas_aux](
	[dhr_cd_cliente] [int] NOT NULL,
	[dhr_dt_data] [date] NOT NULL,
	[dhr_dh_coleta] [datetime] NOT NULL,
	[dhr_nr_rota] [bigint] NOT NULL,
	[dhr_nr_motorista] [bigint] NOT NULL,
	[dhr_ds_nome_motorista] [varchar](200) NULL,
	[dhr_ds_veiculo] [varchar](50) NOT NULL,
	[dhr_ds_placa] [varchar](20) NOT NULL,
	[dhr_vl_quilometros_percorridos] [decimal](10, 2) NOT NULL,
	[dhr_ds_service_center] [varchar](10) NOT NULL,
	[dhr_ds_ciclo] [varchar](10) NOT NULL,
	[dhr_nr_envios_expedidos] [int] NOT NULL,
	[dhr_nr_envios_entregues] [int] NOT NULL,
	[dhr_vl_delivery_success] [decimal](10, 2) NOT NULL,
	[dhr_nr_nao_visitado] [decimal](10, 2) NULL,
	[dhr_vl_orh] [decimal](10, 2) NOT NULL,
	[dhr_vl_sporh] [decimal](10, 2) NOT NULL,
	[dhr_vl_dpph] [decimal](10, 2) NOT NULL
) ON [PRIMARY]
GO
