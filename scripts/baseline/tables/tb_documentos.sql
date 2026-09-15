-- ============================================================
-- BASELINE: dbo.tb_documentos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_documentos]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_documentos](
	[dcm_cd_documento] [int] IDENTITY(1,1) NOT NULL,
	[dcm_nm_documento] [varchar](150) NULL,
	[dcm_ds_tipo] [varchar](150) NULL,
	[dcm_cd_cliente] [int] NOT NULL,
	[dcm_in_ativo] [bit] NOT NULL,
	[dcm_in_excluido] [bit] NOT NULL,
	[dcm_cd_usuario_criacao] [int] NOT NULL,
	[dcm_dh_criacao] [datetime] NOT NULL,
	[dcm_cd_usuario_modificacao] [int] NOT NULL,
	[dcm_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_dcm_cd_documento] PRIMARY KEY CLUSTERED 
(
	[dcm_cd_documento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
