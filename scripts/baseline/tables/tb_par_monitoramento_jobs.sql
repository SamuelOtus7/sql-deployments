-- ============================================================
-- BASELINE: dbo.tb_par_monitoramento_jobs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_par_monitoramento_jobs]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_par_monitoramento_jobs](
	[CodigoParametro] [smallint] IDENTITY(1,1) NOT NULL,
	[NomeJob] [varchar](200) NOT NULL,
	[TempoMaximoSemSucesso] [smallint] NOT NULL,
	[Mensagem] [varchar](250) NOT NULL,
	[Ativo] [bit] NOT NULL,
 CONSTRAINT [pk_par_monitoramento_jobs] PRIMARY KEY CLUSTERED 
(
	[CodigoParametro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [Uk_par_monitoramento_jobs] UNIQUE NONCLUSTERED 
(
	[NomeJob] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
