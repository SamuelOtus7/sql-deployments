-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura_complementar_upload
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura_complementar_upload]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura_complementar_upload](
	[pfc_cd_upload] [bigint] IDENTITY(1,1) NOT NULL,
	[pfc_cd_transportadora] [int] NOT NULL,
	[pfc_nu_ano] [int] NOT NULL,
	[pfc_nu_mes] [int] NOT NULL,
	[pfc_nu_quinzena] [int] NOT NULL,
	[pfc_id_lote] [uniqueidentifier] NOT NULL,
	[pfc_ds_marketplace] [varchar](100) NULL,
	[pfc_ds_operacao] [varchar](200) NULL,
	[pfc_ds_periodo] [varchar](20) NULL,
	[pfc_cd_rota] [varchar](50) NULL,
	[pfc_cd_provider] [bigint] NULL,
	[pfc_ds_conceito_billing] [varchar](200) NULL,
	[pfc_vl_servico] [decimal](18, 2) NULL,
	[pfc_ds_tipo_entidade] [varchar](50) NULL,
	[pfc_ds_status_final] [varchar](100) NULL,
	[pfc_ds_motivo_aprovacao] [varchar](500) NULL,
	[pfc_ds_nome_transportadora] [varchar](200) NULL,
	[pfc_ds_placa_base] [varchar](50) NULL,
	[pfc_dt_rota] [varchar](20) NULL,
	[pfc_ds_faixa_km] [varchar](50) NULL,
	[pfc_ds_nova_faixa_km] [varchar](50) NULL,
	[pfc_qt_paradas_atualizada] [int] NULL,
	[pfc_qt_paradas_anterior] [int] NULL,
	[pfc_ds_service_center] [varchar](100) NULL,
	[pfc_ds_tipo_veiculo] [varchar](50) NULL,
	[pfc_cd_motorista] [varchar](50) NULL,
	[pfc_ds_new_ds] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[pfc_cd_upload] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
