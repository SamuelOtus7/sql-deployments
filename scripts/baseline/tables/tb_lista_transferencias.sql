-- ============================================================
-- BASELINE: dbo.tb_lista_transferencias
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_lista_transferencias]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_lista_transferencias](
	[DataHoraEntrega] [datetime] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[IdRota] [int] NOT NULL,
	[idpacote] [bigint] NOT NULL,
	[SubStatus] [varchar](60) NULL,
	[StatusEntrega] [varchar](60) NULL,
	[IdRotaOrigem] [bigint] NULL,
	[IdRotaDestino] [bigint] NULL,
	[TempoEntrega] [int] NULL,
	[NomeMotorista] [varchar](100) NULL,
	[NomeMotoristaDestino] [varchar](100) NULL,
	[OrdemTransf] [bigint] NULL,
	[OrdemTransfDesc] [bigint] NULL
) ON [PRIMARY]
GO
