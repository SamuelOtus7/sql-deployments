-- ============================================================
-- BASELINE: dbo.tb_formularios_respostas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_formularios_respostas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_formularios_respostas](
	[frr_cd_formulario_resposta] [int] IDENTITY(1,1) NOT NULL,
	[frr_cd_formulario] [int] NOT NULL,
	[frr_json_formulario_resposta] [varchar](max) NOT NULL,
	[frr_in_ativo] [bit] NOT NULL,
	[frr_dh_criacao] [datetime] NOT NULL,
	[frr_cd_usr_criacao] [int] NULL,
	[frr_dh_modificacao] [datetime] NOT NULL,
	[frr_cd_usr_modificacao] [int] NULL,
	[cli_cd_codigo_cliente] [int] NOT NULL,
	[frr_ds_status] [varchar](100) NULL,
	[frr_ds_motivo] [varchar](max) NULL,
 CONSTRAINT [pk_cd_formulario_resposta] PRIMARY KEY CLUSTERED 
(
	[frr_cd_formulario_resposta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
