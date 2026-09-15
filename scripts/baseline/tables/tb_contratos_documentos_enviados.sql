-- ============================================================
-- BASELINE: dbo.tb_contratos_documentos_enviados
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_documentos_enviados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_documentos_enviados](
	[cde_cd_contrato_documento_enviado] [int] IDENTITY(1,1) NOT NULL,
	[cde_cd_contrato_documento_necessario] [int] NOT NULL,
	[cde_cd_contrato] [int] NOT NULL,
	[cde_cd_usuario] [int] NOT NULL,
	[cde_cd_cliente] [int] NOT NULL,
	[cde_ds_status] [varchar](30) NOT NULL,
	[cde_ds_motivo] [varchar](150) NULL,
	[cde_cd_arquivo] [int] NULL,
	[cde_ds_arquivo_link] [varchar](max) NULL,
	[cde_in_ativo] [bit] NOT NULL,
	[cde_in_excluido] [bit] NOT NULL,
	[cde_cd_usuario_criacao] [int] NOT NULL,
	[cde_dh_criacao] [datetime] NOT NULL,
	[cde_cd_usuario_modificacao] [int] NOT NULL,
	[cde_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_contrato_documento_enviado] PRIMARY KEY CLUSTERED 
(
	[cde_cd_contrato_documento_enviado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
