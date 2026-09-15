-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_adicional_indicadores
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_adicional_indicadores]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_adicional_indicadores](
	[bfa_cd_transportadora] [int] NOT NULL,
	[bfa_cd_service_center] [varchar](50) NULL,
	[bfa_cd_tipo_veiculo] [int] NOT NULL,
	[Tipo] [varchar](9) NOT NULL,
	[Indicador] [varchar](16) NOT NULL,
	[Parametro] [varchar](5) NOT NULL,
	[valor] [decimal](7, 2) NOT NULL
) ON [PRIMARY]
GO
