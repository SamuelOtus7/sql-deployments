-- ============================================================
-- BASELINE: dbo.tb_analise_rotas_km_baixo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_analise_rotas_km_baixo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_analise_rotas_km_baixo](
	[IdTransportadora] [varchar](50) NULL,
	[Idrota] [varchar](50) NULL,
	[Data] [date] NOT NULL,
	[Base] [varchar](50) NULL,
	[Motorista] [varchar](100) NOT NULL,
	[UsuarioDA] [int] NULL,
	[KmApp] [float] NULL,
	[pontosRotasPacotesKm] [float] NULL,
	[QuantidadeApontamento] [int] NULL,
	[InicioApp] [datetime] NULL,
	[FimApp] [datetime] NULL,
	[PrimeiraEntrega] [datetime] NULL,
	[UltimaEntrega] [datetime] NULL,
	[QtdPacotes] [int] NULL,
	[FaixaQtdApontamentos] [varchar](13) NOT NULL,
	[MinInicioApp_PrimeiraEntrega] [int] NULL,
	[FaixaTempoInicioApp] [varchar](25) NOT NULL,
	[MinFimApp_UltimaEntrega] [int] NULL,
	[FaixaTempoFimApp] [varchar](24) NOT NULL,
	[PercAtingimentoKmApp] [decimal](10, 2) NULL,
	[KmApp_Menor_90_Perc] [varchar](3) NOT NULL,
	[FaixaPrimeiroUltimoPacote] [varchar](3) NOT NULL,
	[UsouApp] [varchar](5) NULL,
	[ColetouGps] [varchar](3) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IXC_tb_analise_rotas_km_baixo]    Script Date: 14/09/2026 12:12:50 ******/
CREATE CLUSTERED INDEX [IXC_tb_analise_rotas_km_baixo] ON [dbo].[tb_analise_rotas_km_baixo]
(
	[Data] ASC,
	[IdTransportadora] ASC,
	[Idrota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
