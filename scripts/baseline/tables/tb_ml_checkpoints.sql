-- ============================================================
-- BASELINE: dbo.tb_ml_checkpoints
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_checkpoints]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_checkpoints](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdCheckPoint] [bigint] NOT NULL,
	[IdPacote] [bigint] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataHoraColeta] [datetime] NOT NULL,
	[Usuario] [varchar](250) NULL,
	[Status] [varchar](150) NULL,
	[SubStatus] [varchar](150) NULL,
	[Cluster] [varchar](20) NULL,
	[DataHora] [datetime] NULL,
	[Latitude] [decimal](18, 9) NULL,
	[Longitude] [decimal](18, 9) NULL,
 CONSTRAINT [PK_tb_ml_checkpoints] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
