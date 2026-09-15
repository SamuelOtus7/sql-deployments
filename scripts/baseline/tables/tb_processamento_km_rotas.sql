-- ============================================================
-- BASELINE: dbo.tb_processamento_km_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_processamento_km_rotas]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_processamento_km_rotas](
	[CodProcessamento] [int] IDENTITY(1,1) NOT NULL,
	[idRota] [varchar](50) NULL,
	[pontosAppRotasTotalKm] [float] NULL,
	[pontosRotasPacotesKm] [float] NULL,
	[pontosAppRotasTotalVoltaKm] [float] NULL,
	[pontosAppRotasTotalIdaVoltaSvcKm] [float] NULL,
	[flagInicioSVC] [bit] NULL,
	[flagFimSVC] [bit] NULL,
	[flagInicioPacote] [bit] NULL,
	[flagFimPacote] [bit] NULL,
	[flagSugestaoPreFatura] [nvarchar](50) NULL,
	[opcaoKmPreFatura] [nvarchar](50) NULL,
	[kmPreFatura] [float] NULL,
	[idRotaGuid] [uniqueidentifier] NULL,
	[processamento] [bit] NULL,
	[dateCreated] [datetime] NULL,
	[dateUpdated] [datetime] NULL
) ON [PRIMARY]
GO
