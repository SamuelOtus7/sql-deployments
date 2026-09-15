-- ============================================================
-- BASELINE: dbo.tb_termos_aceites
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_termos_aceites]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_termos_aceites](
	[tra_cd_termo_aceite] [int] IDENTITY(1,1) NOT NULL,
	[tra_nm_termo_aceite] [varchar](150) NULL,
	[tra_cd_cliente] [int] NOT NULL,
	[tra_cd_arquivo] [int] NULL,
	[tra_ds_arquivo_link] [varchar](max) NULL,
	[tra_in_ativo] [bit] NOT NULL,
	[tra_in_excluido] [bit] NOT NULL,
	[tra_cd_usuario_criacao] [int] NOT NULL,
	[tra_dh_criacao] [datetime] NOT NULL,
	[tra_cd_usuario_modificacao] [int] NOT NULL,
	[tra_dh_modificacao] [datetime] NOT NULL,
	[tra_in_home_app] [bit] NOT NULL,
	[tra_in_home_web] [bit] NOT NULL,
 CONSTRAINT [pk_tra_cd_termo_aceite] PRIMARY KEY CLUSTERED 
(
	[tra_cd_termo_aceite] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
