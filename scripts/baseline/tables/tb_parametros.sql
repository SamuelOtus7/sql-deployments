-- ============================================================
-- BASELINE: dbo.tb_parametros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_parametros]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_parametros](
	[prm_cd_parametro] [smallint] IDENTITY(1,1) NOT NULL,
	[prm_nm_parametro] [varchar](150) NOT NULL,
	[prm_ds_parametro] [varchar](100) NOT NULL,
	[prm_ds_chave] [varchar](150) NOT NULL,
	[prm_ds_valor] [varchar](max) NULL,
	[prm_ds_placeholder] [varchar](150) NULL,
	[prm_ds_options] [varchar](max) NULL,
	[prm_ds_categoria] [varchar](50) NOT NULL,
	[prm_ds_tipo] [varchar](50) NOT NULL,
	[prm_in_ativo] [bit] NULL,
	[prm_in_excluido] [bit] NULL,
	[prm_cd_usuario_criacao] [int] NOT NULL,
	[prm_dh_criacao] [datetime] NOT NULL,
	[prm_cd_usuario_modificacao] [int] NOT NULL,
	[prm_dh_modificacao] [datetime] NOT NULL,
	[prm_cod_cliente] [int] NULL,
	[prm_cod_operacao] [int] NULL,
 CONSTRAINT [pk_parametros] PRIMARY KEY CLUSTERED 
(
	[prm_cd_parametro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_parametros] UNIQUE NONCLUSTERED 
(
	[prm_nm_parametro] ASC,
	[prm_cod_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
