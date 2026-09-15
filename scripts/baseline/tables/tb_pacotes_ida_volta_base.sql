-- ============================================================
-- BASELINE: dbo.tb_pacotes_ida_volta_base
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pacotes_ida_volta_base]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pacotes_ida_volta_base](
	[IdRota] [int] NOT NULL,
	[IdPacote] [bigint] NOT NULL,
	[DataHoraPrimeiraParada] [datetime] NOT NULL,
	[DataReferencia] [date] NULL,
	[IdTransportadora] [int] NULL,
	[ServiceCenter] [varchar](60) NULL,
	[BaseSigla] [varchar](60) NULL,
	[LatitudePrimeiraParada] [decimal](18, 8) NULL,
	[LongitudePrimeiraParada] [decimal](18, 8) NULL,
	[BaseLatitude] [decimal](22, 15) NULL,
	[BaseLongitude] [decimal](22, 15) NULL,
	[DistanciaBasePrimeiraParadaKm] [float] NULL,
	[DistanciaPrimeiraParadaBaseKm] [float] NULL,
	[DistanciaIdaVoltaBaseKm] [float] NULL,
	[FlagSemBase] [int] NOT NULL,
	[FlagSemCoordenada] [int] NOT NULL
) ON [PRIMARY]
GO
