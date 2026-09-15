-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_transportadora_stg
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_transportadora_stg]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_transportadora_stg](
	[bft_cd_transportadora] [int] NOT NULL,
	[bft_cd_service_center] [varchar](50) NULL,
	[bft_estado] [varchar](2) NULL,
	[bft_cd_tipo_veiculo] [varchar](50) NOT NULL,
	[bft_vl_inicio_faixa] [int] NULL,
	[bft_vl_fim_faixa] [int] NULL,
	[bft_vl_frete] [decimal](7, 2) NULL,
	[Prazo] [varchar](150) NULL
) ON [PRIMARY]
GO
