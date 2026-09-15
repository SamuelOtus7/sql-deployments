-- ============================================================
-- BASELINE: dbo.tb_pbi_mon_etapas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pbi_mon_etapas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pbi_mon_etapas](
	[etapa_id] [int] IDENTITY(1,1) NOT NULL,
	[fluxo_id] [int] NOT NULL,
	[etapa_ordem] [int] NOT NULL,
	[etapa_nome] [nvarchar](200) NOT NULL,
	[etapa_query_sql] [nvarchar](max) NOT NULL,
	[etapa_ativo] [bit] NOT NULL,
	[dh_inclusao] [datetime2](0) NOT NULL,
 CONSTRAINT [pk_pbi_mon_etapas] PRIMARY KEY CLUSTERED 
(
	[etapa_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
