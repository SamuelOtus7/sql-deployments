-- ============================================================
-- BASELINE: dbo.tb_validacoes_espelho
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_espelho]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_espelho](
	[vle_cd_validacao] [int] IDENTITY(1,1) NOT NULL,
	[vle_nm_validacao] [varchar](60) NOT NULL,
	[vle_ds_validacao] [varchar](100) NOT NULL,
	[vle_cd_grupo_validacao] [int] NOT NULL,
	[vle_cd_tipo_validacao] [int] NOT NULL,
	[vle_in_ativo] [bit] NOT NULL,
	[vle_ds_sql_script] [varchar](max) NOT NULL,
	[vle_dh_criacao] [datetime] NOT NULL,
	[vle_cd_usuario_criacao] [int] NOT NULL,
	[vle_dh_modificacao] [datetime] NOT NULL,
	[vle_cd_usuario_modificacao] [int] NOT NULL,
	[vle_nm_url_acao] [varchar](300) NULL,
 CONSTRAINT [pk_tb_validacoes_espelho] PRIMARY KEY CLUSTERED 
(
	[vle_cd_validacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
