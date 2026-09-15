-- ============================================================
-- BASELINE: dbo.Stg_basefretemotoristaTor
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Stg_basefretemotoristaTor]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stg_basefretemotoristaTor](
	[veiculo] [varchar](50) NULL,
	[km] [int] NULL,
	[km_fim] [int] NULL,
	[vl] [decimal](18, 0) NULL,
	[adcDomingo] [int] NULL,
	[recarga] [decimal](18, 0) NULL,
	[ciclopm] [int] NULL,
	[serviceCenter] [varchar](50) NULL
) ON [PRIMARY]
GO
