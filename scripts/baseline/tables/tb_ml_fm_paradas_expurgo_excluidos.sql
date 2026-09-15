-- ============================================================
-- BASELINE: dbo.tb_ml_fm_paradas_expurgo_excluidos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_fm_paradas_expurgo_excluidos]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_fm_paradas_expurgo_excluidos](
	[IdRota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[IdParada] [bigint] NOT NULL,
	[IdVendedor] [varchar](60) NOT NULL,
	[Vendedor] [varchar](60) NOT NULL,
	[Agente] [bit] NULL,
	[VendedorTop] [bit] NULL,
	[Ordem] [int] NOT NULL,
	[Status] [varchar](60) NOT NULL,
	[Tipo] [varchar](60) NOT NULL,
	[DataHoraInicio] [datetime] NULL,
	[DataHoraFim] [datetime] NULL,
	[TempoColeta] [datetime] NULL,
	[TempoInicioMilkrun] [datetime] NULL,
	[TempoFimMilkrun] [datetime] NULL,
	[QuantidadePacotesEstimados] [int] NOT NULL,
	[QuantidadePacotesColetados] [int] NOT NULL,
	[QuantidadePacotesPreparados] [int] NOT NULL,
	[QuantidadePacotesFalhos] [int] NOT NULL,
	[StatusTempo] [varchar](60) NULL,
	[TipoIncidente] [varchar](60) NULL,
	[Retentativa] [bit] NULL,
	[ColetaParcial] [bit] NULL,
	[EtaEstimado] [bit] NULL,
	[RetiradaForaDoIntervalo] [bit] NULL,
	[Endereco] [varchar](100) NULL,
	[NomeRua] [varchar](100) NULL,
	[NumeroRua] [varchar](30) NULL,
	[Referencia] [varchar](100) NULL,
	[Bairro] [varchar](60) NULL,
	[Cidade] [varchar](60) NULL,
	[Estado] [varchar](60) NULL,
	[CEP] [varchar](10) NULL,
	[Latitude] [decimal](18, 8) NULL,
	[Longitude] [decimal](18, 8) NULL,
	[Precisao] [varchar](60) NULL,
	[LatitudePlanejada] [decimal](18, 8) NULL,
	[LongitudePlanejada] [decimal](18, 8) NULL,
	[PrecisaoPlanejada] [varchar](60) NULL,
	[TipoGeolocalizacaoPlanejada] [varchar](60) NULL,
	[LatitudePlanejadaLocalizacao] [decimal](18, 8) NULL,
	[LongitudePlanejadaLocalizacao] [decimal](18, 8) NULL,
	[ForaDoIntervaloGeolocalizacaoPlanejada] [bit] NULL,
	[DistanciaForaIntervaloGeolocalizacaoPlanejada] [decimal](18, 8) NULL,
	[TipoGeolocalizacaoForaIntervalo] [varchar](60) NULL,
	[LatitudeGPS] [decimal](18, 8) NULL,
	[LongitudeGPS] [decimal](18, 8) NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [int] NOT NULL
) ON [PRIMARY]
GO
