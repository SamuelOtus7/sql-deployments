-- ============================================================
-- BASELINE: dbo.tb_ml_aprovacao_usuario
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_aprovacao_usuario]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_aprovacao_usuario](
	[mau_cd_aprovacao] [int] IDENTITY(1,1) NOT NULL,
	[mau_ds_tipo_documento] [varchar](20) NOT NULL,
	[mau_cd_logistics] [int] NOT NULL,
	[mau_ds_documento] [varchar](30) NOT NULL,
	[mau_nm_completo] [varchar](150) NOT NULL,
	[mau_in_habilitado] [bit] NOT NULL,
	[mau_ds_email] [varchar](100) NOT NULL,
	[mau_ds_telefone] [varchar](30) NULL,
	[mau_ds_status] [varchar](30) NULL,
	[mau_cd_usuario_aprovacao] [int] NULL,
	[mau_cd_cliente] [int] NOT NULL,
	[mau_ds_site] [varchar](30) NULL,
	[mau_dh_aprovacao] [datetime] NULL,
	[mau_cd_usuario_gerado] [int] NULL,
	[mau_in_ativo] [bit] NOT NULL,
	[mau_in_excluido] [bit] NOT NULL,
	[mau_cd_usuario_criacao] [int] NOT NULL,
	[mau_dh_criacao] [datetime] NOT NULL,
	[mau_cd_usuario_modificacao] [int] NOT NULL,
	[mau_dh_modificacao] [datetime] NOT NULL,
	[mau_in_reside_area_risco] [bit] NULL,
	[mau_ds_origem] [varchar](30) NOT NULL,
	[mau_cd_tipo_contrato] [int] NULL,
	[mau_in_faturamento_motorista_app] [bit] NULL,
	[mau_cd_responsavel_contrato] [int] NULL,
	[mau_ds_bases_cadastro] [varchar](3000) NULL,
	[mau_ds_ajudante] [bit] NULL,
	[mau_cd_usuario_reativacao] [int] NULL,
	[mau_in_reativacao] [bit] NOT NULL,
 CONSTRAINT [pk_ml_aprovacao_usuario] PRIMARY KEY CLUSTERED 
(
	[mau_cd_aprovacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
