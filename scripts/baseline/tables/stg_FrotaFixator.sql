-- ============================================================
-- BASELINE: dbo.stg_FrotaFixator
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_FrotaFixator]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_FrotaFixator](
	[Coordenador Responsável] [varchar](max) NULL,
	[Base de Operação] [varchar](max) NULL,
	[Contrato ] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[Cadastro  Portal Meli] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
