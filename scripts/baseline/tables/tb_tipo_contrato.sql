-- ============================================================
-- BASELINE: dbo.tb_tipo_contrato
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_tipo_contrato]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_tipo_contrato](
	[ttc_cd_tipo_contrato] [int] IDENTITY(1,1) NOT NULL,
	[ttc_nm_tipo] [varchar](150) NULL,
	[ttc_cd_cliente] [int] NOT NULL,
	[ttc_in_motoristas_vinculados] [bit] NOT NULL,
	[ttc_in_veiculos_vinculados] [bit] NOT NULL,
	[ttc_in_ativo] [bit] NOT NULL,
	[ttc_in_excluido] [bit] NOT NULL,
	[ttc_cd_usuario_criacao] [int] NOT NULL,
	[ttc_dh_criacao] [datetime] NOT NULL,
	[ttc_cd_usuario_modificacao] [int] NOT NULL,
	[ttc_dh_modificacao] [datetime] NOT NULL,
	[ttc_cd_formulario] [int] NULL,
	[ttc_in_assinatura_responsavel] [bit] NULL,
	[ttc_in_administrativo] [bit] NOT NULL,
 CONSTRAINT [pk_tipo_contrato] PRIMARY KEY CLUSTERED 
(
	[ttc_cd_tipo_contrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
