-- ============================================================
-- BASELINE: dbo.tb_tipo_frota
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tipo_frota]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tipo_frota](
	[tf_cd_tipo_frota] [int] IDENTITY(1,1) NOT NULL,
	[tf_ds_tipo_frota] [varchar](255) NULL,
	[tf_nm_tipo_frota] [varchar](150) NOT NULL,
	[tf_fl_excluido] [bit] NOT NULL,
	[tf_cd_usuario_criacao] [int] NOT NULL,
	[tf_cd_usuario_modificacao] [int] NULL,
	[tf_cd_cliente] [int] NOT NULL,
	[tf_dh_criacao] [datetime2](7) NOT NULL,
	[tf_dh_atualizacao] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[tf_cd_tipo_frota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
