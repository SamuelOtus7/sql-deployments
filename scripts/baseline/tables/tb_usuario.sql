-- ============================================================
-- BASELINE: dbo.tb_usuario
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_usuario]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_usuario](
	[usr_cd_usuario] [int] IDENTITY(1,1) NOT NULL,
	[usr_nm_usuario] [varchar](100) NULL,
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
	[usr_in_reside_area_risco] [bit] NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	[usr_ds_salario] [decimal](10, 2) NULL,
	[usr_dt_salario_data_inicio] [date] NULL,
	[usr_dt_salario_data_fim] [date] NULL,
	[usr_nm_usuario_original] [varchar](100) NULL,
	[urs_ds_status_MFA] [int] NULL,
	[urs_ds_parametro_MFA] [int] NULL,
	[urs_ds_chave_MFA] [varchar](255) NULL,
	[urs_ds_tentativa_MFA] [int] NULL,
	[usr_cd_usr_modificacao_documento] [int] NULL,
	[usr_ds_nivel_mot] [varchar](20) NULL,
	[usr_chat_senha_temporaria] [nvarchar](255) NULL,
	[usr_in_fat_multiplas_notas_app] [bit] NOT NULL,
	[usr_cd_driverid] [int] NULL,
 CONSTRAINT [pk_usuario] PRIMARY KEY CLUSTERED 
(
	[usr_cd_usuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_usuario_email] UNIQUE NONCLUSTERED 
(
	[usr_ds_email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_usuario_hist])
)
GO
