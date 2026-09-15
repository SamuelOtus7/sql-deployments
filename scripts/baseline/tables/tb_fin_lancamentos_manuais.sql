-- ============================================================
-- BASELINE: dbo.tb_fin_lancamentos_manuais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_lancamentos_manuais]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_lancamentos_manuais](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[IdRota] [varchar](50) NULL,
	[DataReferencia] [date] NULL,
	[ServiceCenter] [varchar](50) NULL,
	[Motorista] [varchar](100) NULL,
	[MotoristaApoio] [varchar](100) NULL,
	[TipoVeiculo] [varchar](100) NULL,
	[Ciclo] [varchar](2) NULL,
	[DescontoMeli] [decimal](7, 2) NULL,
	[DescontoSaida] [decimal](7, 2) NULL,
	[TipoLancamento] [varchar](30) NOT NULL,
	[Motivo] [varchar](1000) NULL
) ON [PRIMARY]
GO
