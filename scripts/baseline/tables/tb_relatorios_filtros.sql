-- ============================================================
-- BASELINE: dbo.tb_relatorios_filtros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_relatorios_filtros]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_relatorios_filtros](
	[rfl_cd_filtro] [int] IDENTITY(0,1) NOT NULL,
	[rfl_cd_rel_relatorio] [int] NOT NULL,
	[rfl_ds_tabela] [varchar](255) NOT NULL,
	[rfl_ds_coluna] [varchar](255) NOT NULL,
	[rfl_ds_valor] [varchar](255) NOT NULL,
	[rfl_in_excluido] [bit] NOT NULL,
 CONSTRAINT [pk_filtros_report] PRIMARY KEY CLUSTERED 
(
	[rfl_cd_filtro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
