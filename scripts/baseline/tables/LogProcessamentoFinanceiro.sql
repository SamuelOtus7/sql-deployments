-- ============================================================
-- BASELINE: dbo.LogProcessamentoFinanceiro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[LogProcessamentoFinanceiro]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogProcessamentoFinanceiro](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CodPeriodoPagamento] [int] NULL,
	[DataLog] [datetime] NULL,
	[MensagemLog] [nvarchar](4000) NULL,
	[Severidade] [int] NULL,
	[Estado] [int] NULL,
	[TempoExecucao] [int] NULL,
	[idrota] [varchar](50) NULL,
	[avulso] [int] NULL,
	[DetalheTecnico] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
