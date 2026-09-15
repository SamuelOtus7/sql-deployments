-- ============================================================
-- BASELINE: dbo.tb_spe_rotas_v4
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_rotas_v4]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_rotas_v4](
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
	[DistanciaTotal] [decimal](10, 5) NULL,
	[UsuarioIrisys] [int] NULL,
	[KmApp] [decimal](10, 2) NULL,
	[LinkMapaApp] [varchar](1000) NULL,
	[QuantidadeApontamento] [int] NULL,
	[LinkAppInterno] [varchar](500) NULL,
	[Apuracao] [varchar](50) NULL,
	[UsouAPP] [varchar](10) NULL,
 CONSTRAINT [PK_tb_spe_rotas_v4] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_spe_rotas_v4] UNIQUE NONCLUSTERED 
(
	[CodigoRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
