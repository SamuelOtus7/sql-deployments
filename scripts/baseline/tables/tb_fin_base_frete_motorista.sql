-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_motorista]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_motorista](
	[bfm_cd_base_frete_motorista] [int] IDENTITY(1,1) NOT NULL,
	[bfm_cd_transportadora] [int] NOT NULL,
	[bfm_cd_service_center] [varchar](50) NULL,
	[bfm_nm_cidade] [varchar](150) NULL,
	[bfm_cd_tipo_veiculo] [int] NOT NULL,
	[bfm_vl_inicio_faixa] [int] NOT NULL,
	[bfm_vl_fim_faixa] [int] NOT NULL,
	[bfm_vl_frete] [decimal](7, 2) NULL,
	[bfm_vl_frete_pm] [decimal](7, 2) NULL,
	[bfm_vl_frete_fixo] [decimal](7, 2) NULL,
	[bmf_cd_tipo_contrato] [int] NULL,
	[bfm_cd_codigo_cliente] [int] NULL,
	[bfm_vl_domfer_am] [decimal](10, 2) NULL,
	[bfm_vl_domfer_pm] [decimal](10, 2) NULL,
	[bfm_data_inicio_vigencia] [date] NOT NULL,
	[bfm_data_fim_vigencia] [date] NULL,
	[bfm_nm_regiao] [varchar](150) NULL,
	[bfm_cd_operacao] [int] NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[bfm_pag_pacote] [int] NULL,
	[bfm_cd_sla] [int] NULL,
	[bfm_pag_sla] [bit] NULL,
	[bfm_nm_regra_calculo] [varchar](50) NULL,
	[bfm_vl_valor_SLA_perdido] [decimal](7, 2) NULL,
	[bfm_numero_po] [varchar](50) NULL,
	[bfm_cd_pagar_por_pacotes] [int] NULL,
	[bfm_vl_frete_sd] [decimal](5, 2) NULL,
	[bfm_pag_pacote_entregues] [bit] NULL,
	[bfm_cd_criterio_pagamento] [int] NULL,
	[bfm_perc_minimo_endereco_nao_visitado] [decimal](5, 4) NULL,
	[bfm_zerar_ambulancia_nao_aprovada] [bit] NULL,
	[bfm_cd_usuario_alteracao] [int] NULL,
	[bfm_dh_alteracao] [datetime] NULL,
	[bfm_ds_autorizado_por] [nvarchar](200) NULL,
	[bfm_ds_placa] [varchar](20) NULL,
	[bfm_cd_criterio_faixa] [int] NULL,
	[bfm_vl_inicio_faixa2] [int] NULL,
	[bfm_vl_fim_faixa2] [int] NULL,
	[bfm_cd_criterio_faixa2] [int] NULL,
	[bfm_vl_frete_ambulancia_am] [decimal](10, 2) NULL,
	[bfm_vl_frete_ambulancia_pm] [decimal](10, 2) NULL,
	[bfm_vl_frete_saca] [decimal](5, 2) NULL,
 CONSTRAINT [pk_fin_base_frete_motorista] PRIMARY KEY CLUSTERED 
(
	[bfm_cd_base_frete_motorista] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_fin_base_frete_motorista] UNIQUE NONCLUSTERED 
(
	[bfm_cd_transportadora] ASC,
	[bmf_cd_tipo_contrato] ASC,
	[bfm_cd_service_center] ASC,
	[bfm_nm_cidade] ASC,
	[bfm_cd_tipo_veiculo] ASC,
	[bfm_vl_inicio_faixa] ASC,
	[bfm_data_inicio_vigencia] ASC,
	[bfm_cd_operacao] ASC,
	[bfm_ds_placa] ASC,
	[bfm_vl_inicio_faixa2] ASC,
	[bfm_vl_fim_faixa2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_fin_base_frete_motorista_hist])
)
GO
