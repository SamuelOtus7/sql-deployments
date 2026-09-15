-- ============================================================
-- BASELINE: dbo.tb_usuario_grupo_acesso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuario_grupo_acesso]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuario_grupo_acesso](
	[uga_cd_usuario_grupo_acesso] [int] IDENTITY(1,1) NOT NULL,
	[uga_cd_grupo_acesso] [smallint] NOT NULL,
	[uga_cd_usuario] [int] NOT NULL,
	[uga_in_ativo] [bit] NOT NULL,
	[uga_dh_criacao] [datetime] NOT NULL,
	[uga_dh_modificacao] [datetime] NOT NULL,
	[uga_cd_usuario_criacao] [int] NULL,
	[uga_cd_usuario_modificacao] [int] NULL,
 CONSTRAINT [pk_usuario_grupo_acesso] PRIMARY KEY CLUSTERED 
(
	[uga_cd_usuario_grupo_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
