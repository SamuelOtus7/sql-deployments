-- ============================================================
-- BASELINE: dbo.tb_logistics_fat_motoristas_faixa
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_logistics_fat_motoristas_faixa]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_logistics_fat_motoristas_faixa](
	[lfm_cd_logistics_fat_motoristas_faixa] [int] IDENTITY(1,1) NOT NULL,
	[lfm_cd_rota] [int] NOT NULL,
	[lfm_ds_faixa_informada] [varchar](255) NOT NULL,
	[lfm_in_excluido] [bit] NOT NULL,
	[lfm_dh_criacao] [datetime] NOT NULL,
	[lfm_cd_usr_criacao] [int] NULL,
	[lfm_dh_modificacao] [datetime] NOT NULL,
	[lfm_cd_usr_modificacao] [int] NULL,
 CONSTRAINT [pk_cd_logistics_fat_motoristas_faixa] PRIMARY KEY CLUSTERED 
(
	[lfm_cd_logistics_fat_motoristas_faixa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
