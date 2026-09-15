-- ============================================================
-- BASELINE: dbo.CalculosImpostos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[CalculosImpostos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CalculosImpostos](
	[Cdi_cd_Cliente] [int] NULL,
	[Base] [varchar](200) NULL,
	[Iss] [decimal](10, 4) NULL,
	[Comercial] [decimal](10, 4) NULL,
	[RDM] [decimal](10, 4) NULL,
	[Gestao_Logistica] [decimal](10, 4) NULL,
	[cd_base] [int] NULL
) ON [PRIMARY]
GO
