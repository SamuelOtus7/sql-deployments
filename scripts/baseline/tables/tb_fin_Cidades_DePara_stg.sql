-- ============================================================
-- BASELINE: dbo.tb_fin_Cidades_DePara_stg
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_Cidades_DePara_stg]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_Cidades_DePara_stg](
	[Base] [varchar](255) NOT NULL,
	[CidadePai] [varchar](255) NOT NULL,
	[CidadeFilho] [varchar](255) NOT NULL,
	[cid_cd_tipo_contrato] [int] NULL,
	[Estado] [varchar](2) NULL,
	[EstadoFilho] [varchar](2) NULL,
	[codcliente] [int] NULL,
	[ufcod] [int] NULL
) ON [PRIMARY]
GO
