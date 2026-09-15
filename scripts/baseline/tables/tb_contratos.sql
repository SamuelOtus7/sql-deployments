-- ============================================================
-- BASELINE: dbo.tb_contratos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos](
	[ctt_cd_contrato] [int] IDENTITY(1,1) NOT NULL,
	[ctt_nm_contrato] [varchar](150) NULL,
	[ctt_cd_cliente] [int] NOT NULL,
	[ctt_cd_arquivo] [int] NULL,
	[ctt_ds_arquivo_link] [varchar](max) NULL,
	[ctt_in_ativo] [bit] NOT NULL,
	[ctt_in_excluido] [bit] NOT NULL,
	[ctt_cd_usuario_criacao] [int] NOT NULL,
	[ctt_dh_criacao] [datetime] NOT NULL,
	[ctt_cd_usuario_modificacao] [int] NOT NULL,
	[ctt_dh_modificacao] [datetime] NOT NULL,
	[ctt_ds_texto] [varchar](max) NULL,
 CONSTRAINT [pk_ctt_cd_contrato] PRIMARY KEY CLUSTERED 
(
	[ctt_cd_contrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
