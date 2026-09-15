-- ============================================================
-- BASELINE: dbo.tb_formularios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_formularios]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_formularios](
	[frm_cd_formulario] [int] IDENTITY(1,1) NOT NULL,
	[frm_nm_formulario] [varchar](50) NOT NULL,
	[frm_json_formulario] [varchar](max) NOT NULL,
	[frm_dh_data_formulario] [varchar](50) NULL,
	[frm_ds_endereco_formulario] [varchar](max) NULL,
	[frm_ds_formulario] [varchar](max) NULL,
	[frm_in_ativo] [bit] NOT NULL,
	[frm_dh_criacao] [datetime] NOT NULL,
	[frm_cd_usr_criacao] [int] NULL,
	[frm_dh_modificacao] [datetime] NOT NULL,
	[frm_cd_usr_modificacao] [int] NULL,
	[cli_cd_codigo_cliente] [int] NOT NULL,
	[frm_in_onboarding] [bit] NULL,
	[frm_in_checklist] [bit] NOT NULL,
	[frm_in_update_usr] [bit] NOT NULL,
 CONSTRAINT [pk_cd_formulario] PRIMARY KEY CLUSTERED 
(
	[frm_cd_formulario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
