-- ============================================================
-- BASELINE: dbo.AluguelPRALOG
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[AluguelPRALOG]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AluguelPRALOG](
	[STATUS] [nvarchar](50) NULL,
	[PLACA] [nvarchar](50) NULL,
	[FABRICANTE] [nvarchar](50) NULL,
	[MODELO] [nvarchar](50) NULL,
	[TIPO_DE_VEÍCULO] [nvarchar](50) NULL,
	[VALOR] [money] NULL
) ON [PRIMARY]
GO
