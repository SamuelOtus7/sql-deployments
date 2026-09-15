-- ============================================================
-- BASELINE: dbo.tb_alarmes_hist
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_alarmes_hist]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_alarmes_hist](
	[Id] [int] NOT NULL,
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
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_tb_alarmes_hist]    Script Date: 14/09/2026 12:12:47 ******/
CREATE CLUSTERED INDEX [ix_tb_alarmes_hist] ON [dbo].[tb_alarmes_hist]
(
	[ValidTo] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
