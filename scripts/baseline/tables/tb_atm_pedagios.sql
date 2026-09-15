-- ============================================================
-- BASELINE: dbo.tb_atm_pedagios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_atm_pedagios]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_atm_pedagios](
	[atp_cd_codigo] [int] IDENTITY(1,1) NOT NULL,
	[atp_cd_codigo_cliente] [int] NOT NULL,
	[atp_cd_codigo_usuario_motorista] [int] NOT NULL,
	[atp_dt_data] [date] NOT NULL,
	[atp_ds_rota] [varchar](20) NOT NULL,
	[atp_ds_base] [varchar](255) NULL,
	[atp_ds_dispacher] [varchar](255) NULL,
	[atp_dc_valor] [decimal](10, 2) NOT NULL,
	[atp_ds_municipio] [varchar](100) NULL,
	[atp_cd_codigo_upload] [bigint] NULL,
	[atp_in_excluido] [bit] NOT NULL,
	[atp_dh_criacao] [datetime] NOT NULL,
	[atp_cd_usr_criacao] [int] NOT NULL,
	[atp_dh_modificacao] [datetime] NOT NULL,
	[atp_cd_usr_modificacao] [int] NOT NULL,
	[atp_cd_codigo_status] [int] NULL,
	[atp_cd_codigo_motivo_reprovacao] [int] NULL,
	[atp_ds_observacao] [varchar](200) NULL,
	[atp_cd_cod_usuario_operador] [int] NULL,
	[atp_ds_matricula] [varchar](50) NULL,
	[atp_ds_upload_link] [nvarchar](1000) NULL,
	[atp_cd_after_deadline] [bit] NULL,
	[atp_ds_hash_rota]  AS (CONVERT([varchar](40),hashbytes('SHA1',concat(CONVERT([varchar](32),hashbytes('MD5',[atp_ds_rota]),(2)),':',[atp_ds_rota])),(2))) PERSISTED,
	[atp_ds_fora_prazo] [varchar](10) NULL,
	[atp_ds_placa] [varchar](20) NULL,
	[atp_cd_codigo_solicitacao] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[atp_cd_codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
