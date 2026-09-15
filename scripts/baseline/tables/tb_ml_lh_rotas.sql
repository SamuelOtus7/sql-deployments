-- ============================================================
-- BASELINE: dbo.tb_ml_lh_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_lh_rotas]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_lh_rotas](
	[Id] [bigint] IDENTITY(100000000000000,1) NOT NULL,
	[IdRota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[RosteringId] [int] NOT NULL,
	[CodigoRota] [varchar](100) NOT NULL,
	[DataPartidaEsperada] [datetime] NULL,
	[DataFinalizacao] [datetime] NULL,
	[Status] [varchar](60) NULL,
	[SubStatus] [varchar](60) NULL,
	[StatusGeral] [varchar](60) NULL,
	[SubstatusGeral] [varchar](60) NULL,
	[SecaoRota] [int] NULL,
	[IdMotorista] [int] NULL,
	[NomeMotorista] [varchar](60) NULL,
	[SequenciaMotorista] [int] NULL,
	[IdVeiculo] [int] NULL,
	[Placa] [varchar](10) NULL,
	[TipoVeiculo] [varchar](60) NULL,
	[IdVeiculo1] [int] NULL,
	[PlacaVeiculo1] [varchar](10) NULL,
	[TracaoVeiculo1] [bit] NULL,
	[IdVeiculo2] [int] NULL,
	[PlacaVeiculo2] [varchar](10) NULL,
	[TracaoVeiculo2] [bit] NULL,
	[QuantidadeTotalRotas] [int] NULL,
	[IdParadaOrigem] [int] NULL,
	[StatusParadaOrigem] [varchar](60) NULL,
	[TipoParadaOrigem] [varchar](60) NULL,
	[NomeServiceCenterOrigem] [varchar](60) NULL,
	[ServiceCenterOrigem] [varchar](60) NULL,
	[DataInicioEsperadaOrigem] [datetime] NULL,
	[DataFinalizacaoEsperadaOrigem] [datetime] NULL,
	[FonteInicioOrigem] [varchar](60) NULL,
	[FonteFinalizacaoOrigem] [varchar](60) NULL,
	[EtaOrigem] [datetime] NULL,
	[AtaOrigem] [datetime] NULL,
	[EtdOrigem] [datetime] NULL,
	[AtdOrigem] [datetime] NULL,
	[IdCargaOrigem] [int] NULL,
	[TotalUnidadesTransporteOrigem] [int] NULL,
	[TotalPacotesOrigem] [int] NULL,
	[TotalPacotesAcumuladosOrigem] [int] NULL,
	[IdParadaDestino] [int] NULL,
	[StatusParadaDestino] [varchar](60) NULL,
	[TipoParadaDestino] [varchar](60) NULL,
	[NomeServiceCenterDestino] [varchar](60) NULL,
	[ServiceCenterDestino] [varchar](60) NULL,
	[DataInicioEsperadaDestino] [datetime] NULL,
	[DataFinalizacaoEsperadaDestino] [datetime] NULL,
	[FonteInicioDestino] [varchar](60) NULL,
	[FonteFinalizacaoDestino] [varchar](60) NULL,
	[EtaDestino] [datetime] NULL,
	[AtaDestino] [datetime] NULL,
	[EtdDestino] [datetime] NULL,
	[AtdDestino] [datetime] NULL,
	[IdCargaDestino] [int] NULL,
	[TotalUnidadesTransporteDestino] [int] NULL,
	[TotalPacotesDestino] [int] NULL,
	[TotalPacotesAcumuladosDestino] [int] NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [int] NOT NULL,
	[UsuarioDA] [int] NULL,
	[IndicadorOts] [varchar](50) NULL,
	[IndicadorOtd] [varchar](50) NULL,
	[IndicadorOta] [varchar](50) NULL,
	[IndicadorOtr] [varchar](50) NULL,
	[NotaRota] [nvarchar](500) NULL,
 CONSTRAINT [PK_tb_ml_lh_rotas] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_ml_lh_rotas] UNIQUE NONCLUSTERED 
(
	[IdRota] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
