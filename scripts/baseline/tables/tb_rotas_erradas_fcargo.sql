-- ============================================================
-- BASELINE: dbo.tb_rotas_erradas_fcargo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rotas_erradas_fcargo]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rotas_erradas_fcargo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CodigoRota] [varchar](30) NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[DataHoraInicio] [date] NOT NULL,
	[DataHoraFim] [datetime] NULL,
	[DataHoraColeta] [datetime] NULL,
	[IdStation] [int] NOT NULL,
	[IdMotorista] [int] NOT NULL,
	[IdStatus] [int] NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [bit] NOT NULL,
	[TotalPacotes] [smallint] NULL,
	[PacotesEntregues] [smallint] NULL,
	[PacotesNaoEntregue] [smallint] NULL,
	[PacotesPendentes] [smallint] NULL,
	[DataUltimaEntrega] [datetime] NULL,
	[KmColetado] [decimal](10, 5) NULL,
	[LinkMapa] [varchar](1000) NULL,
	[TipoVeiculo] [varchar](100) NULL,
	[DataHoraCarga] [datetime] NULL,
	[Paradas] [int] NULL,
	[CidadeReferencia] [varchar](50) NULL,
	[DistanciaTotal] [decimal](10, 5) NULL
) ON [PRIMARY]
GO
