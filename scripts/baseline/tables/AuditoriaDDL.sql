-- ============================================================
-- BASELINE: dbo.AuditoriaDDL
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[AuditoriaDDL]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditoriaDDL](
	[AuditID] [int] IDENTITY(1,1) NOT NULL,
	[Evento] [nvarchar](100) NULL,
	[Esquema] [nvarchar](100) NULL,
	[Objeto] [nvarchar](100) NULL,
	[TipoObjeto] [nvarchar](100) NULL,
	[DataEvento] [datetime] NULL,
	[LoginUsuario] [nvarchar](100) NULL,
	[TSQL] [nvarchar](max) NULL,
	[XMLEvento] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
