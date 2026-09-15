-- ============================================================
-- BASELINE: dbo.tb_imp_grupo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_imp_grupo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_imp_grupo](
	[grp_cd_grupo] [int] IDENTITY(1,1) NOT NULL,
	[cli_cd_codigo_cliente] [int] NOT NULL,
	[grp_ds_nome] [varchar](100) NOT NULL,
	[grp_ds_descricao] [varchar](300) NULL,
	[grp_ds_cor_hex] [varchar](7) NULL,
	[grp_in_ativo] [bit] NOT NULL,
	[grp_dh_criacao] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_imp_grupo] PRIMARY KEY CLUSTERED 
(
	[grp_cd_grupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_imp_grupo_cliente_nome] UNIQUE NONCLUSTERED 
(
	[cli_cd_codigo_cliente] ASC,
	[grp_ds_nome] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
