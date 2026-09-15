-- ============================================================
-- BASELINE: dbo.tb_ml_processamento_km_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_processamento_km_rotas]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_processamento_km_rotas](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[idRota] [int] NULL,
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
	[dateUpdated] [datetime] NULL,
	[idRotaGuidPaocte] [varchar](250) NULL,
	[pontosAppRotasTotalKmSemRetorno] [decimal](18, 4) NULL,
	[pontosRotasPacotesKmSemRetorno] [decimal](18, 4) NULL,
	[pontosAppRotasTotalKmRetornoLinhaReta] [decimal](18, 4) NULL,
	[pontosAppRotasTotalKmRetornoRoviario] [decimal](18, 4) NULL,
	[pontosRotasPacotesKmRetornoLinhaReta] [decimal](18, 4) NULL,
	[pontosRotasPacotesKmRetornoRoviario] [decimal](18, 4) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_ml_processamento_km_rotas_idrota] UNIQUE NONCLUSTERED 
(
	[idRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
