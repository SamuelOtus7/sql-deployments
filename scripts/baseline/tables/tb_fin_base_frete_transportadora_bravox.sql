-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_transportadora_bravox
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_transportadora_bravox]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_transportadora_bravox](
	[bft_cd_transportadora] [int] NOT NULL,
	[bft_cd_service_center] [varchar](50) NULL,
	[bft_estado] [varchar](2) NULL,
	[bft_cd_tipo_veiculo] [int] NOT NULL,
	[bft_vl_inicio_faixa] [int] NULL,
	[bft_vl_fim_faixa] [int] NULL,
	[bft_vl_frete] [decimal](7, 2) NULL,
	[Prazo] [varchar](4) NOT NULL
) ON [PRIMARY]
GO
