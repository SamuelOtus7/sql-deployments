-- ============================================================
-- BASELINE: dbo.tb_ml_bsc_rtt
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_bsc_rtt]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_bsc_rtt](
	[IdKmRtt] [int] IDENTITY(1,1) NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [int] NOT NULL,
	[Quinzena] [int] NOT NULL,
	[IdRota] [int] NOT NULL,
	[Odometro] [decimal](8, 4) NOT NULL,
	[DistanciaSVC] [decimal](8, 4) NOT NULL,
	[KmTotal] [decimal](8, 4) NOT NULL,
	[DataInsert] [datetime] NULL,
 CONSTRAINT [PK_tb_ml_bsc_rtt_IdNovo] PRIMARY KEY CLUSTERED 
(
	[IdKmRtt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_ml_bsc_rtt_AnoMesQuinzenaIdRota] UNIQUE NONCLUSTERED 
(
	[Ano] ASC,
	[Mes] ASC,
	[Quinzena] ASC,
	[IdRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
