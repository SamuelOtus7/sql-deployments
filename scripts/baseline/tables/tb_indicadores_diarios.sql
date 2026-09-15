-- ============================================================
-- BASELINE: dbo.tb_indicadores_diarios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_indicadores_diarios]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_indicadores_diarios](
	[ind_cd_indicadores_diarios] [int] IDENTITY(1,1) NOT NULL,
	[ind_cd_transportadora] [int] NOT NULL,
	[ind_cd_usuario] [int] NOT NULL,
	[ind_dh_data] [datetime] NULL,
	[ind_in_ativo] [bit] NOT NULL,
	[ind_dh_criacao] [datetime] NOT NULL,
	[ind_dh_modificacao] [datetime] NOT NULL,
	[ind_cd_base] [int] NULL,
	[ind_in_veiculos_cadastrados] [int] NULL,
	[ind_in_veiculos_disponibilizados] [int] NULL,
	[ind_in_rotas_recebidas] [int] NULL,
	[ind_in_rotas_carregadas] [int] NULL,
	[ind_in_noShow] [int] NULL,
	[ind_in_distrato] [int] NULL,
	[ind_ds_noShow_nome] [varchar](255) NULL,
	[ind_ds_noShow_motivo] [varchar](2000) NULL,
	[ind_ds_noShow_operacao] [varchar](255) NULL,
	[ind_in_distrato_nome] [varchar](255) NULL,
	[ind_in_distrato_motivo] [varchar](2000) NULL,
 CONSTRAINT [pk_indicadores_diarios] PRIMARY KEY CLUSTERED 
(
	[ind_cd_indicadores_diarios] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [tb_indicadores_diarios_unique] UNIQUE NONCLUSTERED 
(
	[ind_cd_transportadora] ASC,
	[ind_dh_data] ASC,
	[ind_cd_base] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
