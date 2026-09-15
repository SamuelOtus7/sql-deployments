-- ============================================================
-- BASELINE: dbo.tb_ml_pacotes_transportadoras_diferentes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_pacotes_transportadoras_diferentes]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_pacotes_transportadoras_diferentes](
	[IdTransportadoraPacote] [int] NOT NULL,
	[IdRotaPacote] [int] NOT NULL,
	[IdTransportadoraRotas] [int] NOT NULL,
	[IdRotaRotas] [int] NOT NULL,
	[DataReferenciaPacotes] [date] NOT NULL,
	[ServiceCenterRotas] [varchar](50) NOT NULL,
	[DataAlteracao] [date] NULL
) ON [PRIMARY]
GO
