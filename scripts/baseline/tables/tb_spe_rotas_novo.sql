-- ============================================================
-- BASELINE: dbo.tb_spe_rotas_novo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_rotas_novo]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_rotas_novo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CodigoRota] [varchar](30) NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraColeta] [datetime] NULL,
	[IdStation] [int] NOT NULL,
	[IdMotorista] [int] NOT NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [bit] NOT NULL,
	[TotalPacotes] [smallint] NULL,
	[PacotesEntregues] [smallint] NULL,
	[PacotesNaoEntregue] [smallint] NULL,
	[PacotesPendentes] [smallint] NULL,
	[DataUltimaEntrega] [datetime] NULL,
	[KmColetado] [decimal](10, 5) NULL,
	[LinkMapa] [varchar](1000) NULL,
 CONSTRAINT [PK_tb_spe_rotas_nov] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_spe_rotas_nov] UNIQUE NONCLUSTERED 
(
	[CodigoRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
