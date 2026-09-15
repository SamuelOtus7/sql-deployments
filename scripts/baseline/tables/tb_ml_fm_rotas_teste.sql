-- ============================================================
-- BASELINE: dbo.tb_ml_fm_rotas_teste
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_fm_rotas_teste]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_fm_rotas_teste](
	[Id] [bigint] NULL,
	[IdRota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[NomeRota] [varchar](60) NOT NULL,
	[TipoRota] [varchar](30) NOT NULL,
	[Tipo] [varchar](30) NOT NULL,
	[OrigemSaida] [varchar](60) NOT NULL,
	[NomeOrigemSaida] [varchar](60) NOT NULL,
	[QuantidadeParadas] [int] NOT NULL,
	[QuantidadeParadasComSucesso] [int] NOT NULL,
	[QuantidadeParadasComFalha] [int] NOT NULL,
	[QuantidadeParadasComProblema] [int] NOT NULL,
	[QuantidadeParadasParcialmenteColetadas] [int] NOT NULL,
	[PorcentagemParadas] [decimal](5, 4) NOT NULL,
	[QuantidadePacotesEstimados] [int] NOT NULL,
	[QuantidadePacotesColetados] [int] NOT NULL,
	[QuantidadePacotesPreparados] [int] NOT NULL,
	[Status] [varchar](60) NOT NULL,
	[NomeVeiculo] [varchar](10) NOT NULL,
	[TipoVeiculo] [varchar](60) NOT NULL,
	[IdTipoVeiculo] [int] NOT NULL,
	[PlacaVeiculo] [varchar](60) NOT NULL,
	[CapacidadeVeiculo] [int] NOT NULL,
	[IdMotorista] [int] NOT NULL,
	[NomeMotorista] [varchar](60) NOT NULL,
	[DiaAtual] [bit] NOT NULL,
	[ColetadoParcialmente] [bit] NOT NULL,
	[Perfomance] [decimal](5, 4) NOT NULL,
	[ChegouNaInstalacao] [bit] NOT NULL,
	[IniciouEntrada] [bit] NOT NULL,
	[CaminhoParaInstalacao] [bit] NOT NULL,
	[DataConclusao] [datetime] NULL,
	[VolumeCarregado] [decimal](5, 2) NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Excluido] [bit] NOT NULL
) ON [PRIMARY]
GO
