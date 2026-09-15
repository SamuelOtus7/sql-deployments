-- ============================================================
-- BASELINE: dbo.tb_action_grupo_acesso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_action_grupo_acesso]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_action_grupo_acesso](
	[aga_cd_action_grupo_acesso] [int] IDENTITY(1,1) NOT NULL,
	[aga_cd_grupo_acesso] [smallint] NOT NULL,
	[aga_cd_action_controller] [int] NOT NULL,
	[aga_in_ativo] [bit] NOT NULL,
	[aga_dh_criacao] [datetime] NOT NULL,
	[aga_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_action_grupo_acesso] PRIMARY KEY CLUSTERED 
(
	[aga_cd_action_grupo_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
