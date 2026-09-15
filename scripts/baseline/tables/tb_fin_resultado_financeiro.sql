-- ============================================================
-- BASELINE: dbo.tb_fin_resultado_financeiro
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_resultado_financeiro]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_resultado_financeiro](
	[codreceb] [int] IDENTITY(1,1) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[IdRota] [varchar](30) NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[ServiceCenter] [varchar](50) NULL,
	[XPT] [varchar](50) NULL,
	[Base] [varchar](50) NULL,
	[Placa] [varchar](15) NULL,
	[Motorista] [varchar](100) NOT NULL,
	[Destino] [varchar](150) NULL,
	[Cluster] [varchar](20) NULL,
	[TipoVeiculo] [varchar](100) NULL,
	[CicloPM] [varchar](2) NOT NULL,
	[DomingoOuFeriado] [char](3) NULL,
	[TipoPagamentoFrete] [varchar](30) NULL,
	[TipoPagamentoAdicional] [varchar](30) NULL,
	[QuantidadePacotes] [smallint] NOT NULL,
	[PacotesEntregues] [smallint] NULL,
	[Insucessos] [smallint] NULL,
	[Pendentes] [smallint] NULL,
	[QuantidadeParadas] [smallint] NOT NULL,
	[QuantidadePontos] [smallint] NULL,
	[PgtoSaida] [int] NULL,
	[PgtoParadas] [int] NULL,
	[Adicional] [int] NULL,
	[KmColetado] [decimal](10, 5) NOT NULL,
	[LinkMapa] [varchar](1000) NULL,
	[FaixaKm] [varchar](10) NULL,
	[RecebMeli] [decimal](7, 2) NOT NULL,
	[RecebimentoParadas] [decimal](20, 2) NULL,
	[RecebimentoDomingo] [decimal](7, 2) NULL,
	[RecebimentoRisco] [decimal](7, 2) NULL,
	[RecebimentoAjudante] [decimal](7, 2) NULL,
	[DescontoCicloPM] [decimal](7, 2) NULL,
	[Pedagio] [int] NULL,
	[ReceitaTotal] [decimal](7, 2) NULL,
	[PgtoLancamentoManual] [varchar](30) NULL,
	[PgtoValorManual] [decimal](7, 2) NULL,
	[RecebimentoLancamentoManual] [varchar](30) NULL,
	[RecebimentoValorManual] [decimal](7, 2) NULL,
	[RecebMeli0a100] [decimal](7, 2) NULL,
	[FretePreFatura] [decimal](7, 2) NULL,
	[RecebimentoDomingoPrefatura] [decimal](7, 2) NULL,
	[DescontoCicloPMPrefatura] [decimal](7, 2) NULL,
	[ValorAdicional0_60] [int] NULL,
	[ValorAdicional61_90] [int] NULL,
	[ValorAdicionalAcima_90] [int] NULL,
	[DataHoraInicio] [datetime] NULL,
	[TxAdicionalDomingo] [decimal](18, 2) NULL,
	[TxAdicionalCiclo_pm] [decimal](18, 2) NULL,
	[TxAdicionalAjudante] [decimal](18, 2) NULL,
	[TxAdicionalRisco] [decimal](18, 2) NULL,
	[UsouAPP] [varchar](150) NULL,
	[VersaoDA] [varchar](50) NULL,
	[kmnovo] [float] NULL,
	[FaixaPrimeiroUltimoPacote] [int] NULL,
	[ambulancia] [int] NULL,
	[RecebimentoPonto] [decimal](10, 2) NULL,
	[ID] [int] NULL,
	[DataAtualizacao] [datetime] NULL,
	[tx_adicional_recarga] [decimal](7, 2) NULL,
	[RecebimentoRecarga] [decimal](10, 2) NULL,
	[Observacao] [varchar](255) NULL,
	[Regiao] [varchar](255) NULL,
	[RiscoV2] [varchar](50) NULL,
	[AjudanteV2] [varchar](255) NULL,
	[idmktplace] [int] NULL,
	[ValorPreFatura] [decimal](10, 2) NULL,
	[DividiuRota] [bit] NULL,
	[IdMotoristaDividiuRota] [int] NULL,
 CONSTRAINT [PK_tb_fin_resultado_financeiro_novo] PRIMARY KEY NONCLUSTERED 
(
	[IdTransportadora] ASC,
	[IdRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_tb_fin_resultado_financeiro_DataReferencia_IdTransportadora_IdRota]    Script Date: 14/09/2026 12:12:44 ******/
CREATE CLUSTERED INDEX [IDX_tb_fin_resultado_financeiro_DataReferencia_IdTransportadora_IdRota] ON [dbo].[tb_fin_resultado_financeiro]
(
	[DataReferencia] ASC,
	[IdTransportadora] ASC,
	[IdRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
