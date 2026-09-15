-- ============================================================
-- BASELINE: dbo.tb_controller
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_controller]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_controller](
	[ctr_cd_controller] [smallint] IDENTITY(1,1) NOT NULL,
	[ctr_nm_controller] [varchar](50) NOT NULL,
	[ctr_ds_controller] [varchar](150) NOT NULL,
	[ctr_nm_rota] [varchar](150) NOT NULL,
	[ctr_nm_rota_params] [varchar](150) NULL,
	[ctr_nm_rota_mobile] [varchar](150) NULL,
	[ctr_nm_rota_mobile_params] [varchar](150) NULL,
	[ctr_nm_label] [varchar](50) NOT NULL,
	[ctr_nm_icone] [varchar](50) NOT NULL,
	[ctr_cd_visibilidade_controller] [smallint] NOT NULL,
	[ctr_cd_controller_pai] [smallint] NULL,
	[ctr_ds_tag] [varchar](max) NULL,
	[ctr_no_ordem] [smallint] NOT NULL,
	[ctr_in_ativo] [bit] NOT NULL,
	[ctr_in_system] [bit] NOT NULL,
	[ctr_in_report] [bit] NOT NULL,
	[ctr_dh_criacao] [datetime] NOT NULL,
	[ctr_dh_modificacao] [datetime] NOT NULL,
	[ctr_ds_modulo] [varchar](250) NOT NULL,
	[ctrl_ds_funcionalidade_desc] [varchar](500) NULL,
	[ctrl_ds_funcionalidade_label] [varchar](250) NULL,
	[ctrl_ds_funcionalidade_acesso] [varchar](250) NOT NULL,
 CONSTRAINT [pk_controller] PRIMARY KEY CLUSTERED 
(
	[ctr_cd_controller] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
