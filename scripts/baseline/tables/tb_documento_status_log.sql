-- ============================================================
-- BASELINE: dbo.tb_documento_status_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_documento_status_log]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_documento_status_log](
	[dsl_cd_documento_status_log] [int] IDENTITY(1,1) NOT NULL,
	[dsl_tp_documento] [varchar](50) NOT NULL,
	[dsl_cd_documento] [int] NOT NULL,
	[dsl_ds_status_anterior] [varchar](50) NULL,
	[dsl_ds_status_novo] [varchar](50) NOT NULL,
	[dsl_cd_usuario_alteracao] [int] NOT NULL,
	[dsl_dh_alteracao] [datetime] NOT NULL,
	[dsl_cd_cliente] [int] NOT NULL,
	[dsl_ds_motivo] [varchar](500) NULL,
 CONSTRAINT [PK_tb_documento_status_log] PRIMARY KEY CLUSTERED 
(
	[dsl_cd_documento_status_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
