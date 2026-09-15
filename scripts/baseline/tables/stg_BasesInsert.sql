-- ============================================================
-- BASELINE: dbo.stg_BasesInsert
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BasesInsert]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BasesInsert](
	[MARKETPLACE] [varchar](max) NULL,
	[SIGLA] [varchar](max) NULL,
	[NOME] [varchar](max) NULL,
	[NOME AMIGAVEL] [varchar](max) NULL,
	[ENDEREÇO] [varchar](max) NULL,
	[REGIAO] [varchar](max) NULL,
	[ESTADO] [varchar](max) NULL,
	[CIDADE] [varchar](max) NULL,
	[LATITUDE] [float] NULL,
	[LONGITUDE] [float] NULL,
	[USUARIOS INDICADORES DIARIOS] [float] NULL,
	[USUARIOS TRATATIVAS INSUCESSOS] [float] NULL,
	[USUARIOS COM PERMISSÃO PARA INDISPONIBILIZAR ESCALA] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
