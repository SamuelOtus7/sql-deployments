-- ============================================================
-- BASELINE: dbo.tb_grupo_acesso
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_grupo_acesso]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_grupo_acesso](
	[gpa_cd_grupo_acesso] [smallint] IDENTITY(1,1) NOT NULL,
	[gpa_nm_grupo_acesso] [varchar](200) NULL,
	[gpa_ds_grupo_acesso] [varchar](150) NOT NULL,
	[gpa_in_ativo] [bit] NOT NULL,
	[gpa_in_compartilhado] [bit] NOT NULL,
	[gpa_dh_criacao] [datetime] NOT NULL,
	[gpa_dh_modificacao] [datetime] NOT NULL,
	[gpa_cd_cliente] [int] NULL,
 CONSTRAINT [pk_grupo_acesso] PRIMARY KEY CLUSTERED 
(
	[gpa_cd_grupo_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
