-- ============================================================
-- BASELINE: dbo.tb_spe_sla_stuck
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_sla_stuck]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_sla_stuck](
	[idSLA] [int] IDENTITY(1,1) NOT NULL,
	[IdJson] [int] NULL,
	[CodigoPacote] [varchar](50) NULL,
	[DataHoraColeta] [datetime] NULL,
	[EstacaoColeta] [datetime] NULL,
	[NomeHub] [varchar](255) NULL,
	[StatusColeta] [varchar](255) NULL,
	[MensagemColeta] [varchar](500) NULL,
	[MensagemStatus] [varchar](max) NULL,
	[InicioSLA] [bit] NULL,
	[FimSla] [bit] NULL,
	[DataImportacao] [datetime] NULL,
	[Finalizado] [int] NULL,
	[idtransportadora] [int] NULL,
	[on_hold_reason] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idSLA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
