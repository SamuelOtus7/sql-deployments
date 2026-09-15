-- ============================================================
-- BASELINE: dbo.tb_rotinas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rotinas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rotinas](
	[rtn_cd_rotina] [int] IDENTITY(1,1) NOT NULL,
	[rtn_ds_nome] [varchar](100) NOT NULL,
	[rtn_cd_usr_criacao] [int] NOT NULL,
	[rtn_dt_criacao] [datetime] NOT NULL,
	[rtn_cd_usr_modificacao] [int] NOT NULL,
	[rtn_dt_modificacao] [datetime] NOT NULL,
	[rtn_in_ativo] [bit] NOT NULL,
	[rtn_execution_id] [varchar](max) NULL,
	[rtn_ds_grupo] [varchar](max) NULL,
	[rtn_cd_rotina_tipo] [int] NOT NULL,
	[rtn_ds_metodo] [varchar](10) NULL,
	[rtn_ds_parametros] [varchar](max) NULL,
	[rtn_ds_header] [varchar](max) NULL,
	[rtn_ds_body] [varchar](max) NULL,
	[rtn_ds_uri] [varchar](200) NULL,
	[rtn_ds_query] [varchar](max) NULL,
	[rtn_ds_download] [varchar](50) NULL,
	[cli_cd_codigo_cliente] [int] NULL,
 CONSTRAINT [pk_pf_rotinas] PRIMARY KEY CLUSTERED 
(
	[rtn_cd_rotina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
