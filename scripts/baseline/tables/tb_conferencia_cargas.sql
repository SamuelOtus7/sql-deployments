-- ============================================================
-- BASELINE: dbo.tb_conferencia_cargas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_conferencia_cargas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_conferencia_cargas](
	[cfr_cd_conferencia_cargas] [int] IDENTITY(1,1) NOT NULL,
	[cfr_cd_cliente] [int] NOT NULL,
	[cfr_nr_rota_lm] [varchar](20) NOT NULL,
	[cfr_nr_rota_lh] [varchar](20) NULL,
	[cfr_ds_cluster] [varchar](20) NULL,
	[cfr_cd_status_conferencia] [int] NOT NULL,
	[cfr_dh_created_at] [datetime] NOT NULL,
	[cfr_dh_inicio_conferencia] [datetime] NULL,
	[cfr_usr_inicio_conferencia] [int] NULL,
	[cfr_dh_fim_conferencia] [datetime] NULL,
	[cfr_usr_fim_conferencia] [int] NULL,
	[cfr_cd_base] [int] NULL,
 CONSTRAINT [pk_conferencia_cargas] PRIMARY KEY CLUSTERED 
(
	[cfr_cd_conferencia_cargas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
