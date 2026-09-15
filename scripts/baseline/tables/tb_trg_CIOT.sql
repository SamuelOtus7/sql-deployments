-- ============================================================
-- BASELINE: dbo.tb_trg_CIOT
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_trg_CIOT]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_trg_CIOT](
	[IdCiot] [int] IDENTITY(1,1) NOT NULL,
	[IdOperacaoTransporte] [int] NULL,
	[Instrucao] [int] NULL,
	[CodigoCentroDeCusto] [varchar](50) NULL,
	[NCM] [varchar](50) NULL,
	[ProprietarioCarga] [int] NULL,
	[PesoCarga] [decimal](10, 2) NULL,
	[TipoOperacao] [int] NULL,
	[MunicipioOrigemCodigoIBGE] [int] NULL,
	[MunicipioDestinoCodigoIBGE] [int] NULL,
	[DataHoraInicio] [datetime] NULL,
	[DataHoraTermino] [datetime] NULL,
	[CPFCNPJContratado] [varchar](20) NULL,
	[ValorFrete] [decimal](10, 2) NULL,
	[ValorCombustivel] [decimal](10, 2) NULL,
	[ValorPedagio] [decimal](10, 2) NULL,
	[ValorDespesas] [decimal](10, 2) NULL,
	[ValorImpostoSestSenat] [decimal](10, 2) NULL,
	[ValorImpostoIRRF] [decimal](10, 2) NULL,
	[ValorImpostoINSS] [decimal](10, 2) NULL,
	[ValorImpostoIcmsIssqn] [decimal](10, 2) NULL,
	[ParcelaUnica] [bit] NULL,
	[ModoCompraValePedagio] [int] NULL,
	[CategoriaVeiculo] [int] NULL,
	[NomeMotorista] [varchar](100) NULL,
	[CPFMotorista] [varchar](20) NULL,
	[RNTRCMotorista] [varchar](20) NULL,
	[ItemFinanceiro] [varchar](100) NULL,
	[IdRotaModelo] [int] NULL,
	[DeduzirImpostos] [bit] NULL,
	[TarifasBancarias] [decimal](10, 2) NULL,
	[QuantidadeTarifasBancarias] [int] NULL,
	[IdIntegrador] [varchar](50) NULL,
	[ValorDescontoAntecipado] [decimal](10, 2) NULL,
	[CPFCNPJParticipanteDestinatario] [varchar](20) NULL,
	[CPFCNPJParticipanteContratante] [varchar](20) NULL,
	[CPFCNPJParticipanteSubcontratante] [varchar](20) NULL,
	[CPFCNPJParticipanteConsignatario] [varchar](20) NULL,
	[NumeroLacreTransporteCombustivel] [varchar](50) NULL,
	[ListaDestinatariosAdicionais] [varchar](50) NULL,
	[NumeroCartaoValePedagio] [varchar](50) NULL,
	[Quitacao] [bit] NULL,
	[ValorMercadoria] [decimal](10, 2) NULL,
	[PesoCarregadoMercadoria] [decimal](10, 2) NULL,
	[QuantidadeCarregada] [int] NULL,
	[TipoCalculoAvaria] [varchar](50) NULL,
	[EncerraNaANTT] [bit] NULL,
	[PorcentagemToleranciaPeso] [decimal](5, 2) NULL,
	[TipoToleranciaPeso] [int] NULL,
	[PorcetagemPesoAMaior] [decimal](5, 2) NULL,
	[DocumentoValePedagio] [varchar](50) NULL,
	[StatusIntegracao] [int] NOT NULL,
	[DataHoraIntegracao] [datetime] NULL,
	[DataHoraModificacao] [datetime] NULL,
	[StatusProcesso] [int] NOT NULL,
	[Excluido] [bit] NOT NULL,
	[CodCliente] [int] NULL,
	[CIOTRegistro] [varchar](100) NULL,
	[ValorImpostoPIS] [decimal](10, 2) NULL,
	[ValorImpostoCofins] [decimal](10, 2) NULL,
	[BaseCalculoPISCofins] [decimal](10, 2) NULL,
	[ValorContratado] [decimal](10, 2) NULL,
	[DadosQuitacao] [varchar](100) NULL,
	[TipoFormaPagamento] [int] NULL,
	[QuantidadeViagens] [int] NULL,
	[ProtocoloCIOT] [varchar](100) NULL,
	[ProtocoloEncerramento] [varchar](100) NULL,
	[IdEncerramentoOperacaoTransporte] [varchar](100) NULL,
	[MensagemRetorno] [varchar](200) NULL,
	[DataHoraFinalizacao] [varchar](100) NULL,
	[ValorBrutoEspelhoPagamento] [decimal](10, 2) NULL,
	[IdMotorista] [int] NULL,
	[IdTransportador] [int] NULL,
	[ValorFreteFinal] [decimal](18, 2) NULL,
	[ValorLiquidoFinal] [decimal](10, 2) NULL,
 CONSTRAINT [pk_trg_CIOT] PRIMARY KEY CLUSTERED 
(
	[IdCiot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_trg_CIOT_IdIntegrador] UNIQUE NONCLUSTERED 
(
	[IdIntegrador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
