-- ============================================================
-- BASELINE: dbo.tb_usuarios_inativos_logando
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuarios_inativos_logando]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuarios_inativos_logando](
	[usr_cd_usuario] [int] IDENTITY(1,1) NOT NULL,
	[usr_nm_usuario] [varchar](50) NOT NULL,
	[usr_ds_email] [varchar](100) NOT NULL,
	[usr_ds_senha] [varchar](100) NOT NULL,
	[usr_in_ativo] [bit] NOT NULL,
	[usr_dh_criacao] [datetime] NOT NULL,
	[usr_cd_usr_criacao] [int] NULL,
	[usr_dh_modificacao] [datetime] NOT NULL,
	[usr_cd_usr_modificacao] [int] NULL,
	[usr_dt_nascimento] [date] NULL,
	[usr_ds_usuario] [varchar](100) NULL,
	[usr_in_plataforma] [int] NULL,
	[cli_cd_codigo_cliente] [int] NULL,
	[usr_dh_expiracao_token_mobile] [datetime] NULL,
	[usr_ds_token_mobile] [varchar](100) NULL,
	[usr_in_token_mobile_tentativas] [int] NULL,
	[usr_ds_num_telefone] [varchar](30) NULL,
	[usr_in_registro_gps] [bit] NOT NULL,
	[usr_in_motorista] [bit] NULL,
	[usr_cd_tipo_contrato] [int] NULL,
	[usr_cd_chat] [varchar](100) NULL,
	[usr_chat_token] [varchar](max) NULL,
	[usr_chat_username] [varchar](150) NULL,
	[usr_cd_usr_responsavel_contrato] [int] NULL,
	[usr_in_fat_motorista_valor_app] [bit] NOT NULL,
	[usr_ds_base] [varchar](100) NULL,
	[usr_matricula] [varchar](50) NULL,
	[usr_reset_token] [bit] NULL,
	[usr_in_reside_area_risco] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
