-- ============================================================
-- BASELINE: dbo.tb_fin_paradas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_paradas]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_paradas](
	[idrota] [varchar](1000) NULL,
	[servicecenter] [varchar](50) NULL,
	[TipoVeiculo] [varchar](100) NULL,
	[ValorPrefatura] [varchar](1000) NULL,
	[RecebimentoParadas] [decimal](20, 2) NULL,
	[RecebimentoPonto] [decimal](10, 2) NULL,
	[ParadaPrefatura] [varchar](1000) NULL,
	[QuantidadeParadas] [smallint] NOT NULL,
	[QuantidadePontos] [smallint] NULL,
	[insucessos] [smallint] NULL,
	[ValidaPonto] [varchar](15) NULL,
	[ValidaParadas] [varchar](15) NULL,
	[PontoOuParada] [varchar](9) NULL,
	[MaiorMenor] [varchar](15) NOT NULL,
	[MaiorMenorPontos] [varchar](15) NOT NULL
) ON [PRIMARY]
GO
