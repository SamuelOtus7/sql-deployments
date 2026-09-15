-- ============================================================
-- BASELINE: dbo.stg_BaseFrete_Transportadora_tor
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BaseFrete_Transportadora_tor]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BaseFrete_Transportadora_tor](
	[veiculo] [varchar](50) NULL,
	[km] [int] NULL,
	[km_fim] [int] NULL,
	[valor] [decimal](18, 0) NULL,
	[servicecenter] [varchar](50) NULL
) ON [PRIMARY]
GO
