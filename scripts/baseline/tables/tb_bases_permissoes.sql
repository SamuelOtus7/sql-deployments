-- ============================================================
-- BASELINE: dbo.tb_bases_permissoes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_bases_permissoes]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_bases_permissoes](
	[bsp_cd_base_permissoes] [int] IDENTITY(1,1) NOT NULL,
	[bsp_cd_base] [int] NOT NULL,
	[bsp_cd_tipo_permissao] [int] NOT NULL,
	[bsp_cd_usuario] [int] NOT NULL,
	[bsp_cod_cliente] [int] NULL,
	[bsp_cd_registro] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[bsp_cd_base_permissoes] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
