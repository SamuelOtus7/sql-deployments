-- ============================================================
-- BASELINE: dbo.tb_dra_hist_perf_minuto
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_hist_perf_minuto]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_hist_perf_minuto](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[Intervalo] [time](7) NOT NULL,
	[Total] [smallint] NOT NULL,
	[Online] [smallint] NOT NULL,
	[Historico] [smallint] NOT NULL,
	[TotalErros] [smallint] NOT NULL,
	[Erro_401] [smallint] NOT NULL,
	[Erro_403] [smallint] NOT NULL,
	[Erro_404] [smallint] NOT NULL,
	[Erro_424] [smallint] NOT NULL,
	[Erro_Outros] [smallint] NOT NULL,
 CONSTRAINT [pk_dra_hist_perf_minuto] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY],
 CONSTRAINT [uk_dra_hist_perf_minuto] UNIQUE NONCLUSTERED 
(
	[DataReferencia] ASC,
	[Intervalo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
