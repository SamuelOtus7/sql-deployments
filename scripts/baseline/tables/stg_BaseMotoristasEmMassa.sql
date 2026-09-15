-- ============================================================
-- BASELINE: dbo.stg_BaseMotoristasEmMassa
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BaseMotoristasEmMassa]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BaseMotoristasEmMassa](
	[motorista] [varchar](200) NULL,
	[cpf] [varchar](30) NULL,
	[email] [varchar](200) NULL
) ON [PRIMARY]
GO
