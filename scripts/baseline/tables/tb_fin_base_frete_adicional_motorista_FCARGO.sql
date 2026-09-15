-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_adicional_motorista_FCARGO
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_adicional_motorista_FCARGO]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_adicional_motorista_FCARGO](
	[bfa_cd_base_frete_adicional_motorista] [int] IDENTITY(1,1) NOT NULL,
	[bfa_cd_transportadora] [int] NOT NULL,
	[bfa_cd_service_center] [varchar](50) NULL,
	[bfa_nm_cidade] [varchar](150) NULL,
	[bfa_cd_tipo_veiculo] [int] NOT NULL,
	[bfa_tipo_adicional_domingo] [tinyint] NOT NULL,
	[bfa_vl_adicional_domingo] [decimal](7, 2) NOT NULL,
	[bfa_tipo_adicional_ciclo_pm] [tinyint] NOT NULL,
	[bfa_vl_adicional_ciclo_pm] [decimal](7, 2) NOT NULL,
	[bfa_vl_paradas0_60] [decimal](7, 2) NOT NULL,
	[bfa_vl_paradas61_75] [decimal](7, 2) NOT NULL,
	[bfa_vl_paradas76_85] [decimal](7, 2) NOT NULL,
	[bfa_vl_paradas86_90] [decimal](7, 2) NOT NULL,
	[bfa_vl_paradas_acima_90] [decimal](7, 2) NOT NULL,
	[bfa_tipo_adicional_ajudante] [tinyint] NULL,
	[bfa_vl_adicional_ajudante] [decimal](7, 2) NULL,
	[bfa_tipo_adicional_risco] [tinyint] NULL,
	[bfa_vl_adicional_risco] [decimal](7, 2) NULL,
	[bfa_calcula_por_parada] [bit] NULL,
	[bfa_vl_adicional] [decimal](7, 2) NULL,
	[bfa_tipo_adicional_pool] [int] NULL,
	[bfa_cd_tipo_contrato] [int] NULL,
	[bfa_tipo_insucesso] [tinyint] NULL,
	[bfa_cd_insucesso] [tinyint] NULL,
	[bfa_vl_insucesso] [decimal](7, 2) NULL,
	[bfa_cd_dias_insentos] [varchar](50) NULL,
	[bfa_cd_pacote_ajudante] [decimal](7, 2) NULL,
	[bfa_cd_pacote_ajudante_area_risco] [decimal](7, 2) NULL,
	[bfa_cd_codigo_cliente] [int] NULL,
	[bfa_vl_adicional_recarga] [decimal](7, 2) NULL,
	[bfa_vl_sdd] [decimal](18, 2) NULL,
	[bfa_vl_adicional_km100] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
