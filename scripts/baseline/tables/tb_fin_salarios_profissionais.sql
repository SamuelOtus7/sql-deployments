-- ============================================================
-- BASELINE: dbo.tb_fin_salarios_profissionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_salarios_profissionais]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_salarios_profissionais](
	[tsp_cd_salario] [int] IDENTITY(1,1) NOT NULL,
	[tsp_cd_usuario] [int] NOT NULL,
	[tsp_dt_inicio] [date] NOT NULL,
	[tsp_dt_fim] [date] NULL,
	[tsp_vl_salario] [decimal](18, 2) NOT NULL,
	[tsp_nm_cargo] [nvarchar](255) NULL,
	[tsp_in_considera_sabado] [bit] NOT NULL,
	[tsp_in_considera_domingos_feriados] [bit] NOT NULL,
	[tsp_dh_criacao] [datetime] NOT NULL,
	[tsp_cd_usr_criacao] [int] NOT NULL,
	[tsp_dh_modificacao] [datetime] NULL,
	[tsp_cd_usr_modificacao] [int] NULL,
	[tsp_in_ativo] [bit] NOT NULL,
	[tsp_in_excluido] [bit] NOT NULL,
	[tsp_cd_client] [int] NULL,
	[tsp_ds_marketplace] [nvarchar](100) NULL,
	[tsp_ds_base] [nvarchar](100) NULL,
	[tsp_ds_regional] [nvarchar](100) NULL,
	[tsp_cd_coordenacao] [int] NULL,
	[tsp_cd_gerencia] [int] NULL,
	[tsp_ds_chave_pix] [nvarchar](77) NULL,
	[tsp_ds_setor] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[tsp_cd_salario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
