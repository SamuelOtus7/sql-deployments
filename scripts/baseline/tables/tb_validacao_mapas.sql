-- ============================================================
-- BASELINE: dbo.tb_validacao_mapas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacao_mapas]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacao_mapas](
	[vmp_idvalicao] [int] IDENTITY(1,1) NOT NULL,
	[vmp_linkrecebimento] [varchar](1000) NULL,
	[vmp_kmrecebimento] [varchar](20) NULL,
	[vmp_linkpagamento] [varchar](1000) NULL,
	[vmp_kmpagamento] [varchar](20) NULL,
	[vmp_observacaopagamento] [varchar](1000) NULL,
	[vmp_usuario_criacao] [int] NOT NULL,
	[vmp_dh_criacao] [datetime] NOT NULL,
	[vmp_usuario_modificacao] [int] NOT NULL,
	[vmp_dh_modificacao] [datetime] NOT NULL,
	[vmp_maparecebimento] [varchar](50) NULL,
	[vmp_observacaorecebimento] [varchar](50) NULL,
	[vmp_idrota] [varchar](500) NOT NULL,
	[vmp_mapapagamento] [varchar](500) NULL,
	[vmp_cd_rota] [varchar](500) NULL,
	[vmp_km_total_mapa] [varchar](100) NULL,
	[vmp_km_total_mapa_pgto] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[vmp_idvalicao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
