-- ============================================================
-- BASELINE: dbo.tb_logs_acessos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_logs_acessos]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_logs_acessos](
	[log_cd_log_acesso] [int] IDENTITY(1,1) NOT NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[log_dh_acesso] [datetime] NOT NULL,
	[act_cd_action] [smallint] NOT NULL,
	[ctr_cd_controller] [smallint] NOT NULL,
 CONSTRAINT [PK_logs_acessos] PRIMARY KEY CLUSTERED 
(
	[log_cd_log_acesso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
