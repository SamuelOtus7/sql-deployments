-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_adicional_stg
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_adicional_stg]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_adicional_stg](
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
	[vfa_cd_prazo] [varchar](150) NULL
) ON [PRIMARY]
GO
