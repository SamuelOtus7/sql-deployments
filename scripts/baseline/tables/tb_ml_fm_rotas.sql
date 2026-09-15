-- ============================================================
-- BASELINE: dbo.tb_ml_fm_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_fm_rotas]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_fm_rotas](
	[Id] [bigint] IDENTITY(10000000000,1) NOT NULL,
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
	[NomeVeiculo] [varchar](60) NOT NULL,
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
	[Excluido] [bit] NOT NULL,
	[usuarioda] [int] NULL,
	[AmbulanciaStatus] [varchar](100) NULL,
	[AmbulanciaPagamento] [varchar](50) NULL,
	[AmbulanciaIdMotorista] [int] NULL,
	[DataInicio] [datetime] NULL,
	[KmPercorrido] [decimal](10, 4) NULL,
 CONSTRAINT [PK_tb_ml_fm_rotas] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_ml_fm_rotas] UNIQUE NONCLUSTERED 
(
	[IdRota] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
