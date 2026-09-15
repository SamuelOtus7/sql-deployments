-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_adicional
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_adicional]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_adicional](
	[bfa_cd_base_frete_adicional] [int] IDENTITY(1,1) NOT NULL,
	[bfa_cd_transportadora] [int] NOT NULL,
	[bfa_cd_service_center] [varchar](50) NULL,
	[bfa_estado] [varchar](2) NULL,
	[bfa_cd_tipo_veiculo] [int] NOT NULL,
	[bfa_tipo_adicional_domingo] [tinyint] NULL,
	[bfa_vl_adicional_domingo] [decimal](7, 2) NULL,
	[bfa_tipo_adicional_ciclo_pm] [tinyint] NULL,
	[bfa_vl_adicional_ciclo_pm] [decimal](7, 2) NULL,
	[bfa_vl_paradas0_60] [decimal](7, 2) NOT NULL,
	[bfa_vl_paradas61_90] [decimal](7, 2) NOT NULL,
	[bfa_vl_paradas_acima_90] [decimal](7, 2) NOT NULL,
	[bfa_tipo_adicional_ajudante] [tinyint] NULL,
	[bfa_vl_adicional_ajudante] [decimal](7, 2) NULL,
	[bfa_tipo_adicional_risco] [tinyint] NULL,
	[bfa_vl_adicional_risco] [decimal](7, 2) NULL,
	[bfa_calcula_por_parada] [bit] NOT NULL,
	[bfa_cd_codigo_cliente] [int] NULL,
	[bfa_data_inicio] [date] NULL,
	[bfa_data_fim] [date] NULL,
	[bfa_adicional_recarga] [decimal](7, 2) NULL,
	[bfa_tipo_adicional_recarga] [tinyint] NULL,
	[bfa_vl_adicional_recarga] [decimal](10, 2) NULL,
	[bfa_cd_operacao] [int] NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [pk_tb_fin_base_frete_adicional] PRIMARY KEY CLUSTERED 
(
	[bfa_cd_base_frete_adicional] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_fin_base_frete_adicional_hist])
)
GO
