-- ============================================================
-- BASELINE: dbo.FCA_ATTMot
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[FCA_ATTMot]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCA_ATTMot](
	[matricula] [varchar](max) NULL,
	[motorista] [varchar](max) NULL,
	[cpf] [varchar](max) NULL,
	[email] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
