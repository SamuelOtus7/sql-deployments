-- ============================================================
-- BASELINE: dbo.tb_app_notificacoes_usuarios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_app_notificacoes_usuarios]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_app_notificacoes_usuarios](
	[anu_cd_app_notificacoes_usuario] [smallint] IDENTITY(1,1) NOT NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[not_cd_notificacao] [int] NOT NULL,
	[anu_in_visualizado] [bit] NOT NULL,
	[anu_in_excluido] [bit] NOT NULL,
	[usr_cd_usuario_criacao] [int] NOT NULL,
	[anu_dh_criacao] [datetime] NOT NULL,
	[usr_cd_usuario_modificacao] [int] NOT NULL,
	[anu_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_app_notificacoes_usuarios] PRIMARY KEY CLUSTERED 
(
	[anu_cd_app_notificacoes_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
