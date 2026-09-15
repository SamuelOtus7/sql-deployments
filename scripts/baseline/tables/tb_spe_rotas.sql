-- ============================================================
-- BASELINE: dbo.tb_spe_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_rotas]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_rotas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdRota] [varchar](30) NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraColeta] [datetime] NULL,
	[IdStation] [int] NOT NULL,
	[IdMotorista] [int] NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [bit] NOT NULL,
	[TotalPacotes] [smallint] NULL,
	[PacotesEntregues] [smallint] NULL,
	[PacotesNaoEntregue] [smallint] NULL,
	[PacotesPendentes] [smallint] NULL,
	[DataUltimaEntrega] [datetime] NULL,
 CONSTRAINT [pk_spe_rotas] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_spe_rotas_chave] UNIQUE NONCLUSTERED 
(
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[IdMotorista] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
