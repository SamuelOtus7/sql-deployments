-- ============================================================
-- BASELINE: dbo.tb_validacoes_gerais_resultados
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_gerais_resultados]    Script Date: 14/09/2026 12:12:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_gerais_resultados](
	[vlr_cd_resultado] [bigint] IDENTITY(1,1) NOT NULL,
	[vlr_cd_cliente] [int] NOT NULL,
	[vlr_dt_resultado] [date] NOT NULL,
	[vlr_cd_validacao] [int] NOT NULL,
	[vlr_vl_casos_totais] [int] NOT NULL,
	[vlr_vl_inconsistencias] [int] NOT NULL,
	[vlr_dh_processamento] [datetime] NOT NULL,
 CONSTRAINT [pk_vlg_validacao_resultados] PRIMARY KEY CLUSTERED 
(
	[vlr_cd_resultado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY],
 CONSTRAINT [uk_vld_validacao_resultados] UNIQUE NONCLUSTERED 
(
	[vlr_cd_cliente] ASC,
	[vlr_dt_resultado] ASC,
	[vlr_cd_validacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
