-- ============================================================
-- BASELINE: dbo.tb_relatorios_filtros_usuarios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_relatorios_filtros_usuarios]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_relatorios_filtros_usuarios](
	[rfu_cd_relatorios_filtro_usuario] [int] IDENTITY(0,1) NOT NULL,
	[rfu_cd_relatorios_filtro] [int] NOT NULL,
	[rfu_cd_usuario] [int] NOT NULL,
 CONSTRAINT [pk_relatorios_filtros_usuarios] PRIMARY KEY CLUSTERED 
(
	[rfu_cd_relatorios_filtro_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
