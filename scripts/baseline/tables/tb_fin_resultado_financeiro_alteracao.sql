-- ============================================================
-- BASELINE: dbo.tb_fin_resultado_financeiro_alteracao
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_resultado_financeiro_alteracao]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_resultado_financeiro_alteracao](
	[DataReferencia] [date] NULL,
	[idrota] [varchar](50) NOT NULL,
	[CicloPM] [varchar](2) NULL,
	[QuantidadePontos] [int] NULL,
	[QuantidadeParadas] [int] NULL,
	[QuantidadePacotes] [int] NULL,
	[PacotesEntregues] [int] NULL,
	[TipoVeiculo] [varchar](100) NULL,
	[KmColetado] [decimal](9, 5) NULL,
	[LinkMapa] [varchar](1000) NULL,
	[idtransportadora] [int] NULL,
	[DomingoOuFeriado] [varchar](5) NULL,
	[Ajudante] [varchar](5) NULL,
	[AreaRisco] [varchar](5) NULL,
	[faixakm] [varchar](50) NULL,
	[servicecenter] [varchar](50) NULL,
	[Observacao] [varchar](255) NULL,
	[Regiao] [varchar](255) NULL,
	[RiscoV2] [varchar](255) NULL,
	[ClientID] [int] NULL,
	[DividiuRota] [bit] NULL,
	[IdMotoristaDividiuRota] [int] NULL,
	[Ambulancia] [varchar](5) NULL
) ON [PRIMARY]
GO
