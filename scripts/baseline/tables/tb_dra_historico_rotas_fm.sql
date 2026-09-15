-- ============================================================
-- BASELINE: dbo.tb_dra_historico_rotas_fm
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_historico_rotas_fm]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_historico_rotas_fm](
	[dhr_cd_historico_rota] [bigint] IDENTITY(1,1) NOT NULL,
	[dhr_dt_data] [date] NOT NULL,
	[dhr_dh_coleta] [datetime] NULL,
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
	[dhr_vl_dpph] [decimal](10, 2) NOT NULL,
	[idtransportadora] [int] NULL,
 CONSTRAINT [PK_tb_dra_historico_rotas_fm] PRIMARY KEY CLUSTERED 
(
	[dhr_cd_historico_rota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
