-- ============================================================
-- BASELINE: dbo.tb_cte_lotes_anexos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_cte_lotes_anexos]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_cte_lotes_anexos](
	[cla_cd_lote_anexo] [int] IDENTITY(1,1) NOT NULL,
	[cla_cd_cte_lote] [int] NOT NULL,
	[cla_nm_lote_anexo] [varchar](200) NOT NULL,
	[cla_cd_arquivo] [int] NULL,
 CONSTRAINT [pk_cte_lote_anexos] PRIMARY KEY CLUSTERED 
(
	[cla_cd_lote_anexo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
