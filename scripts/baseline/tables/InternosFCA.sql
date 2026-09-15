-- ============================================================
-- BASELINE: dbo.InternosFCA
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[InternosFCA]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InternosFCA](
	[Matricula] [smallint] NULL,
	[Colaboradores_Interno] [nvarchar](50) NULL,
	[CPF] [nvarchar](50) NULL,
	[E_MAIL] [nvarchar](50) NULL,
	[Tipo_de_Contrato] [nvarchar](50) NULL
) ON [PRIMARY]
GO
