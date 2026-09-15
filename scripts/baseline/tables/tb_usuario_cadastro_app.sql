-- ============================================================
-- BASELINE: dbo.tb_usuario_cadastro_app
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuario_cadastro_app]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuario_cadastro_app](
	[ucp_cd_usuario_cadastro_app] [int] IDENTITY(1,1) NOT NULL,
	[ucp_ds_nome] [varchar](255) NOT NULL,
	[ucp_ds_email] [varchar](255) NOT NULL,
	[ucp_ds_telefone] [varchar](20) NOT NULL,
	[ucp_ds_app_origem] [varchar](20) NOT NULL,
	[ucp_in_aprovado] [bit] NOT NULL,
	[ucp_in_excluido] [bit] NOT NULL,
	[ucp_dh_criacao] [datetime] NOT NULL,
	[ucp_ds_parceiro_chave_app] [varchar](25) NULL,
	[ucp_ds_base] [varchar](3000) NULL,
	[ucp_ds_documento] [varchar](20) NULL,
 CONSTRAINT [pk_usuario_cadastro_app] PRIMARY KEY CLUSTERED 
(
	[ucp_cd_usuario_cadastro_app] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
