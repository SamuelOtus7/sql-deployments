-- ============================================================
-- BASELINE: dbo.tb_spe_rotas_v5
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_rotas_v5]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_rotas_v5](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CodigoRota] [varchar](50) NULL,
	[IdTransportadora] [int] NULL,
	[DataReferencia] [date] NULL,
	[DataHoraInicio] [datetime] NULL,
	[DataHoraFim] [datetime] NULL,
	[DataHoraColeta] [datetime] NULL,
	[IdStation] [int] NULL,
	[IdMotorista] [int] NULL,
	[IdStatus] [int] NULL,
	[DataAtualizacao] [datetime] NULL,
	[Excluido] [bit] NULL,
	[TotalPacotes] [smallint] NULL,
	[PacotesEntregues] [smallint] NULL,
	[PacotesNaoEntregue] [smallint] NULL,
	[PacotesPendentes] [smallint] NULL,
	[DataUltimaEntrega] [datetime] NULL,
	[KmColetado] [decimal](10, 2) NULL,
	[LinkMapa] [varchar](255) NULL,
	[TipoVeiculo] [varchar](50) NULL,
	[DataHoraCarga] [datetime] NULL,
	[Paradas] [int] NULL,
	[CidadeReferencia] [varchar](100) NULL,
	[DistanciaTotal] [decimal](10, 2) NULL,
	[UsuarioIrisys] [int] NULL,
	[KmApp] [decimal](10, 2) NULL,
	[LinkMapaApp] [varchar](255) NULL,
	[QuantidadeApontamento] [int] NULL,
	[LinkAppInterno] [varchar](255) NULL,
	[Apuracao] [varchar](100) NULL,
	[UsouAPP] [varchar](50) NULL,
	[NomeHub] [varchar](100) NULL,
	[Motorista] [varchar](255) NULL,
	[placa] [nvarchar](50) NULL,
	[CidadeDistante] [varchar](200) NULL,
	[KmPacotes] [decimal](10, 2) NULL,
	[LinkMapaPacotes] [varchar](200) NULL,
	[TipoOperacao] [nvarchar](100) NULL,
	[StationOrigem] [nvarchar](200) NULL,
	[StationDestino] [nvarchar](200) NULL,
	[DataHoraDesignacaoRota] [datetime2](3) NULL,
	[AgencyId] [int] NULL,
	[NomeRota] [varchar](80) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
