-- ============================================================
-- BASELINE: dbo.stg_BaseMotoristasEmMassaPraAprov
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BaseMotoristasEmMassaPraAprov]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BaseMotoristasEmMassaPraAprov](
	[Código Aprovação] [varchar](max) NULL,
	[Id Logistics] [varchar](max) NULL,
	[Documento] [varchar](max) NULL,
	[Documento.1] [varchar](max) NULL,
	[Nome] [varchar](max) NULL,
	[E-mail] [varchar](max) NULL,
	[Telefone] [varchar](max) NULL,
	[Status] [varchar](max) NULL,
	[Site] [varchar](max) NULL,
	[Origem] [varchar](max) NULL,
	[Última Rota] [varchar](max) NULL,
	[Base Última Rota] [varchar](max) NULL,
	[Aprovação para início] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
