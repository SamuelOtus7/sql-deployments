-- ============================================================
-- BASELINE: dbo.tb_setor_grupo_acesso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_setor_grupo_acesso]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_setor_grupo_acesso](
	[sga_cd_setor_grupo_acesso] [int] IDENTITY(1,1) NOT NULL,
	[sga_cd_setor] [int] NOT NULL,
	[sga_cd_grupo_acesso] [smallint] NOT NULL,
	[sga_cd_cliente] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sga_cd_setor_grupo_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_setor_grupo_acesso] UNIQUE NONCLUSTERED 
(
	[sga_cd_setor] ASC,
	[sga_cd_grupo_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
