-- ============================================================
-- BASELINE: dbo.tb_tipos_lancamentos_grupos_acesso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tipos_lancamentos_grupos_acesso]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tipos_lancamentos_grupos_acesso](
	[lga_tipos_lancamentos_grupos_acesso] [int] IDENTITY(1,1) NOT NULL,
	[lga_cd_tipo_lancamento_manual] [int] NOT NULL,
	[lga_cd_grupo_acesso] [smallint] NOT NULL,
 CONSTRAINT [pk_tipos_lancamentos_grupos_acesso] PRIMARY KEY CLUSTERED 
(
	[lga_tipos_lancamentos_grupos_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
