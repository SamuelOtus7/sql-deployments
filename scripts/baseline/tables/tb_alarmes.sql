-- ============================================================
-- BASELINE: dbo.tb_alarmes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_alarmes]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_alarmes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nome] [nvarchar](100) NOT NULL,
	[Label] [nvarchar](255) NULL,
	[IdGrupo] [int] NOT NULL,
	[ConsultaQtde] [nvarchar](max) NULL,
	[ConsultaDetalhamento] [nvarchar](max) NULL,
	[Icone] [nvarchar](255) NULL,
	[CorIcone] [char](7) NULL,
	[Ordem] [int] NOT NULL,
	[Status] [bit] NULL,
	[URLAcao] [nvarchar](255) NULL,
	[IconePadrao] [nvarchar](255) NULL,
	[Descricao] [nvarchar](255) NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_alarmes_hist])
)
GO
