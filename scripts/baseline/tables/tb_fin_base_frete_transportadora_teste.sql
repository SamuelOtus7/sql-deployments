-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_transportadora_teste
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_transportadora_teste]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_transportadora_teste](
	[bft_cd_base_frete_transportadora] [int] IDENTITY(1,1) NOT NULL,
	[bft_cd_transportadora] [int] NOT NULL,
	[bft_cd_service_center] [varchar](50) NULL,
	[bft_estado] [varchar](2) NULL,
	[bft_cd_tipo_veiculo] [int] NOT NULL,
	[bft_vl_inicio_faixa] [int] NULL,
	[bft_vl_fim_faixa] [int] NULL,
	[bft_vl_frete] [decimal](7, 2) NULL
) ON [PRIMARY]
GO
