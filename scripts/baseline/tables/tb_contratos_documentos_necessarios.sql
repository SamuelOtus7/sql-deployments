-- ============================================================
-- BASELINE: dbo.tb_contratos_documentos_necessarios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_documentos_necessarios]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_documentos_necessarios](
	[cdn_cd_contrato_documento_necessario] [int] IDENTITY(1,1) NOT NULL,
	[cdn_cd_contrato] [int] NOT NULL,
	[cdn_cd_cliente] [int] NOT NULL,
	[cdn_nm_documento] [varchar](150) NULL,
	[cdn_in_ativo] [bit] NOT NULL,
	[cdn_in_excluido] [bit] NOT NULL,
	[cdn_cd_usuario_criacao] [int] NOT NULL,
	[cdn_dh_criacao] [datetime] NOT NULL,
	[cdn_cd_usuario_modificacao] [int] NOT NULL,
	[cdn_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_cdn_cd_contrato_documento_necessario] PRIMARY KEY CLUSTERED 
(
	[cdn_cd_contrato_documento_necessario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
