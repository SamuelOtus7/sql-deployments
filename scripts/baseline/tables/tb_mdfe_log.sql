-- ============================================================
-- BASELINE: dbo.tb_mdfe_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_mdfe_log]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_mdfe_log](
	[Id] [uniqueidentifier] NOT NULL,
	[ItemId] [uniqueidentifier] NULL,
	[TenantId] [int] NOT NULL,
	[IdLote] [int] NOT NULL,
	[IdEmpresa] [int] NULL,
	[DataCriacao] [datetime2](7) NOT NULL,
	[Nivel] [varchar](10) NOT NULL,
	[Mensagem] [nvarchar](max) NOT NULL,
	[Etapa] [varchar](30) NULL,
	[Metodo] [varchar](200) NULL,
	[Detalhes] [nvarchar](max) NULL,
 CONSTRAINT [PK_tb_mdfe_log] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
