-- ============================================================
-- BASELINE: dbo.tb_validacoes_espelho_resultados_totais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_espelho_resultados_totais]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_espelho_resultados_totais](
	[vet_cd_validacao_resultado_totais] [int] IDENTITY(1,1) NOT NULL,
	[vet_cd_validacao_contexto] [int] NOT NULL,
	[vet_cd_periodo] [int] NOT NULL,
	[vet_nr_sucesso] [int] NOT NULL,
	[vet_nr_total] [int] NOT NULL,
 CONSTRAINT [pk_tb_validacoes_espelho_resultados_totais] PRIMARY KEY CLUSTERED 
(
	[vet_cd_validacao_resultado_totais] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY],
 CONSTRAINT [UQ_tb_validacoes_espelho_resultados_totais] UNIQUE NONCLUSTERED 
(
	[vet_cd_validacao_contexto] ASC,
	[vet_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
