-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_adicional_motorista_parada
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_adicional_motorista_parada]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_adicional_motorista_parada](
	[bfp_cd_adcional_parada] [int] IDENTITY(1,1) NOT NULL,
	[bfa_cd_adicional_motorista] [int] NOT NULL,
	[bfa_fx_ini] [int] NULL,
	[bfa_fx_fim] [int] NULL,
	[bfa_fx_valor] [decimal](10, 2) NULL,
	[bfa_fx_ini_2] [int] NULL,
	[bfa_fx_fim_2] [int] NULL,
	[bfa_dia_util] [bit] NULL,
	[tipo_fx_1] [int] NULL,
	[tipo_fx_2] [int] NULL,
	[bfa_tipo_valor] [int] NULL
) ON [PRIMARY]
GO
