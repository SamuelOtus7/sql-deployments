-- ============================================================
-- BASELINE: dbo.tb_fin_spe_prefatura
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_spe_prefatura]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_spe_prefatura](
	[idtransportadora] [int] NULL,
	[TipoServico] [varchar](max) NULL,
	[Operacao] [varchar](max) NULL,
	[SOC] [varchar](max) NULL,
	[Hub] [varchar](max) NULL,
	[Rota] [varchar](max) NULL,
	[PeriodoAnoMesQuinzena] [varchar](max) NULL,
	[TrackingNumber] [varchar](max) NULL,
	[TrackingNumberAPI] [varchar](max) NULL,
	[DataPrestacaoServico] [varchar](103) NULL,
	[NomeTomadorServico] [varchar](max) NULL,
	[CNPJTomador] [varchar](max) NULL,
	[NomeTransportadora] [varchar](max) NULL,
	[CNPJEmitente] [varchar](max) NULL,
	[CEPOrigem] [varchar](max) NULL,
	[CidadeOrigem] [varchar](max) NULL,
	[UFOrigem] [varchar](max) NULL,
	[CEPentrega] [varchar](max) NULL,
	[CidadeEntrega] [varchar](max) NULL,
	[UFEntrega] [varchar](max) NULL,
	[DadosSeller] [varchar](max) NULL,
	[DataEntrega] [varchar](max) NULL,
	[QuantidadeVolume] [varchar](max) NULL,
	[PesoReal] [varchar](max) NULL,
	[PesoCubado] [varchar](max) NULL,
	[PesoCalculadoCobrado] [varchar](max) NULL,
	[KMRodado] [varchar](20) NULL,
	[TipoVeiculo] [varchar](max) NULL,
	[FatorAgrupador] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[ValorNotaFiscalMercadoria] [decimal](10, 2) NULL,
	[TarifaAplicada] [varchar](20) NULL,
	[FreteTarifaBase] [decimal](10, 2) NULL,
	[FreteCalculado] [decimal](10, 2) NULL,
	[ADV] [varchar](max) NULL,
	[GRIS] [decimal](10, 2) NULL,
	[AliquotaICMSISS] [decimal](10, 2) NULL,
	[BaseCalcICMSISS] [decimal](10, 2) NULL,
	[ValorICMSISS] [decimal](10, 2) NULL,
	[ICMS_Subst] [varchar](max) NULL,
	[OutrosValores] [decimal](10, 2) NULL,
	[Descontos] [decimal](10, 2) NULL,
	[ValorFinalReceber] [decimal](10, 2) NULL,
	[DataEmissaoCteNF] [varchar](max) NULL,
	[Fatura] [varchar](max) NULL,
	[NumeroCte] [varchar](max) NULL,
	[NumeroNF] [varchar](max) NULL,
	[SerieCteNF] [varchar](max) NULL,
	[ChaveAcessoCte] [varchar](max) NULL,
	[MotivoRejeicaoCTE] [varchar](max) NULL,
	[PrefeituraNFSe] [varchar](max) NULL,
	[Valorajudante] [decimal](10, 2) NULL,
	[Valorincentivo] [decimal](10, 2) NULL,
	[FlagRisco] [decimal](10, 2) NULL,
	[DeAcordo] [varchar](max) NULL,
	[Motivo] [varchar](max) NULL,
	[ValorNegociado] [varchar](max) NULL,
	[Observacoes] [varchar](max) NULL,
	[ano] [int] NULL,
	[mes] [int] NULL,
	[quinzena] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
