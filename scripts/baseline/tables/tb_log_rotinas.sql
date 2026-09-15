-- ============================================================
-- BASELINE: dbo.tb_log_rotinas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_rotinas]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_rotinas](
	[lrt_cd_log_rotina] [int] IDENTITY(1,1) NOT NULL,
	[lrt_cd_rotina] [int] NOT NULL,
	[lrt_ds_mensagem] [varchar](max) NULL,
	[lrt_ds_dados_execucao] [varchar](max) NULL,
	[lrt_dt_execucao] [datetime] NOT NULL,
	[lrt_cd_usuario] [int] NOT NULL,
	[lrt_rts_cd_rotina_status] [int] NOT NULL,
 CONSTRAINT [pk_log_rotinas] PRIMARY KEY CLUSTERED 
(
	[lrt_cd_log_rotina] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
