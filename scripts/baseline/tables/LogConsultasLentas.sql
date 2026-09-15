-- ============================================================
-- BASELINE: dbo.LogConsultasLentas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[LogConsultasLentas]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogConsultasLentas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DataRegistro] [datetime] NULL,
	[SessionId] [int] NULL,
	[TempoExecucaoSegundos] [int] NULL,
	[TextoQuery] [nvarchar](max) NULL,
	[Banco] [nvarchar](200) NULL,
	[HostName] [nvarchar](200) NULL,
	[LoginName] [nvarchar](200) NULL,
	[Status] [nvarchar](50) NULL,
	[StatusBloqueio] [nvarchar](50) NULL,
	[SpidBloqueadoPor] [int] NULL,
	[SpidsBloqueados] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
