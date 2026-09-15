-- ============================================================
-- BASELINE: dbo.tb_fin_Cidades_DePara
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_Cidades_DePara]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_Cidades_DePara](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Base] [varchar](255) NOT NULL,
	[CidadePai] [varchar](255) NOT NULL,
	[CidadeFilho] [varchar](255) NOT NULL,
	[idcliente] [int] NULL,
	[cid_cd_tipo_contrato] [int] NULL,
	[cid_cd_calculo_ibge] [int] NULL,
	[cid_cd_uf_calculo_ibge] [int] NULL,
	[cid_cd_base_ibge] [int] NULL,
	[cid_cd_uf_base_ibge] [int] NULL,
	[cid_cd_usu_criacao] [int] NULL,
	[cid_dh_criacao] [datetime] NULL,
	[cid_cd_base] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
