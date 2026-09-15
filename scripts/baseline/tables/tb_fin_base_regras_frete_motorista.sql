-- ============================================================
-- BASELINE: dbo.tb_fin_base_regras_frete_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_regras_frete_motorista]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_regras_frete_motorista](
	[id_transportadora] [int] NOT NULL,
	[cd_service_center] [varchar](50) NULL,
	[nm_cidade] [varchar](1000) NULL,
	[cd_tipo_veiculo] [int] NULL,
	[regra] [varchar](50) NULL,
	[vl_km] [decimal](10, 5) NULL,
	[vl_inicio_faixa] [int] NULL,
	[vl_fim_faixa] [int] NULL,
	[vl_frete] [decimal](7, 2) NULL,
	[vl_frete_pm] [decimal](7, 2) NULL,
	[vl_frete_fixo] [decimal](7, 2) NULL,
	[tipo_adicional_domingo] [int] NULL,
	[vl_adicional_domingo] [int] NULL,
	[tipo_adicional_ciclo_pm] [int] NULL,
	[vl_adicional_ciclo_pm] [int] NULL,
	[vl_paradas0_60] [int] NULL,
	[vl_paradas61_75] [int] NULL,
	[vl_paradas76_85] [int] NULL,
	[vl_paradas86_90] [int] NULL,
	[vl_paradas_acima_90] [int] NULL,
	[tipo_adicional_ajudante] [int] NULL,
	[vl_adicional_ajudante] [int] NULL,
	[tipo_adicional_risco] [int] NULL,
	[vl_adicional_risco] [int] NULL,
	[calcula_por_parada] [int] NULL,
	[vl_adicional] [int] NULL,
	[tipo_adicional_pool] [int] NULL
) ON [PRIMARY]
GO
