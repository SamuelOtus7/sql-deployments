-- ============================================================
-- BASELINE: dbo.tb_fin_lh_prefatura
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_lh_prefatura]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_lh_prefatura](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Quinzena] [int] NOT NULL,
	[TipoVeiculo] [varchar](100) NOT NULL,
	[ServiceCenter] [varchar](50) NOT NULL,
	[IdRota] [int] NOT NULL,
	[NomeRota] [varchar](80) NOT NULL,
	[DataInicio] [date] NOT NULL,
	[DataTermino] [date] NOT NULL,
	[Dia] [varchar](10) NULL,
	[Placa] [varchar](20) NOT NULL,
	[Motorista] [varchar](100) NOT NULL,
	[Quantidade] [int] NOT NULL,
	[PrecoUnitario] [decimal](7, 2) NOT NULL,
	[Total] [decimal](7, 2) NOT NULL
) ON [PRIMARY]
GO
