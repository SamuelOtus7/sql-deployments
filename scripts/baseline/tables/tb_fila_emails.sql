-- ============================================================
-- BASELINE: dbo.tb_fila_emails
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fila_emails]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fila_emails](
	[fle_cd_fila_emails] [int] IDENTITY(1,1) NOT NULL,
	[fle_cd_usuario] [int] NOT NULL,
	[fle_ds_email] [varchar](100) NOT NULL,
	[fle_ds_tipo_email] [varchar](100) NOT NULL,
	[fle_dt_hora_inclusao] [datetime] NULL,
	[fle_cd_status_processamento] [int] NULL,
	[fle_dt_hora_processamento] [datetime] NULL,
	[fle_ds_mensagem_erro] [varchar](200) NULL
) ON [PRIMARY]
GO
