-- ============================================================
-- BASELINE: dbo.tb_fin_spe_prefatura_upload
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_spe_prefatura_upload]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_spe_prefatura_upload](
	[TipoServico] [varchar](max) NULL,
	[Operacao] [varchar](max) NULL,
	[SOC] [varchar](max) NULL,
	[Hub] [varchar](max) NULL,
	[Rota] [varchar](max) NULL,
	[PeriodoAnoMesQuinzena] [varchar](max) NULL,
	[TrackingNumber] [varchar](max) NULL,
	[TrackingNumberAPI] [varchar](max) NULL,
	[DataPrestacaoServico] [varchar](max) NULL,
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
	[KMRodado] [varchar](max) NULL,
	[TipoVeiculo] [varchar](max) NULL,
	[FatorAgrupador] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[ValorNotaFiscalMercadoria] [varchar](max) NULL,
	[TarifaAplicada] [varchar](max) NULL,
	[FreteTarifaBase] [varchar](max) NULL,
	[FreteCalculado] [varchar](max) NULL,
	[ADV] [varchar](max) NULL,
	[GRIS] [varchar](max) NULL,
	[AliquotaICMSISS] [varchar](max) NULL,
	[BaseCalcICMSISS] [varchar](max) NULL,
	[ValorICMSISS] [varchar](max) NULL,
	[ICMS_Subst] [varchar](max) NULL,
	[OutrosValores] [varchar](max) NULL,
	[Descontos] [varchar](max) NULL,
	[ValorFinalReceber] [varchar](max) NULL,
	[DataEmissaoCteNF] [varchar](max) NULL,
	[Fatura] [varchar](max) NULL,
	[NumeroCte] [varchar](max) NULL,
	[NumeroNF] [varchar](max) NULL,
	[SerieCteNF] [varchar](max) NULL,
	[ChaveAcessoCte] [varchar](max) NULL,
	[MotivoRejeicaoCTE] [varchar](max) NULL,
	[PrefeituraNFSe] [varchar](max) NULL,
	[Valorajudante] [varchar](max) NULL,
	[Valorincentivo] [varchar](max) NULL,
	[FlagRisco] [varchar](max) NULL,
	[DeAcordo] [varchar](max) NULL,
	[Motivo] [varchar](max) NULL,
	[ValorNegociado] [varchar](max) NULL,
	[Observacoes] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
