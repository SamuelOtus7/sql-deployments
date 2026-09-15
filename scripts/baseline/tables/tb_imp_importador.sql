-- ============================================================
-- BASELINE: dbo.tb_imp_importador
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_imp_importador]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_imp_importador](
	[imp_cd_importador] [int] IDENTITY(1,1) NOT NULL,
	[cli_cd_codigo_cliente] [int] NOT NULL,
	[grp_cd_grupo] [int] NOT NULL,
	[imp_ds_nome] [varchar](150) NOT NULL,
	[imp_ds_descricao] [varchar](400) NULL,
	[imp_ds_nome_arquivo_modelo] [varchar](200) NOT NULL,
	[imp_ds_caminho_arquivo_modelo] [varchar](500) NOT NULL,
	[imp_ds_caminho_pasta_destino] [varchar](500) NOT NULL,
	[imp_ds_extensoes_permitidas] [varchar](50) NOT NULL,
	[imp_nu_tamanho_maximo_mb] [int] NOT NULL,
	[imp_ds_nome_script] [varchar](150) NOT NULL,
	[imp_ds_caminho_script] [varchar](500) NULL,
	[imp_in_script_disponivel] [bit] NOT NULL,
	[imp_in_ativo] [bit] NOT NULL,
	[imp_dh_criacao] [datetime] NOT NULL,
	[imp_dh_modificacao] [datetime] NULL,
	[usr_cd_usuario_criacao] [int] NULL,
 CONSTRAINT [PK_tb_imp_importador] PRIMARY KEY CLUSTERED 
(
	[imp_cd_importador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_imp_importador_cliente_nome] UNIQUE NONCLUSTERED 
(
	[cli_cd_codigo_cliente] ASC,
	[imp_ds_nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
