-- ============================================================
-- BASELINE: dbo.tb_trg_CIOTVeiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_trg_CIOTVeiculos]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_trg_CIOTVeiculos](
	[Placa] [varchar](10) NOT NULL,
	[IdCiot] [int] NULL,
	[IdOperacaoTransporte] [int] NULL,
	[RNTRC] [varchar](20) NULL,
	[CodCiotVeiculo] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_tb_trg_CIOTVeiculos] PRIMARY KEY CLUSTERED 
(
	[CodCiotVeiculo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [tb_trg_CIOTVeiculos_unique] UNIQUE NONCLUSTERED 
(
	[Placa] ASC,
	[IdCiot] ASC,
	[IdOperacaoTransporte] ASC,
	[RNTRC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
