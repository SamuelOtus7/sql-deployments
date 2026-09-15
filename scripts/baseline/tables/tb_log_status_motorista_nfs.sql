-- ============================================================
-- BASELINE: dbo.tb_log_status_motorista_nfs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_status_motorista_nfs]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_status_motorista_nfs](
	[lsm_cd_log_status] [int] IDENTITY(1,1) NOT NULL,
	[lsm_cd_motorista_nfs] [int] NOT NULL,
	[lsm_cd_status_anterior] [int] NULL,
	[lsm_cd_status_atual] [int] NOT NULL,
	[lsm_dt_data_log] [datetime] NOT NULL,
	[lsm_cd_usuario] [int] NOT NULL,
	[lsm_ds_mensagem] [varchar](2000) NULL,
 CONSTRAINT [PK_tb_log_status_motorista_nfs] PRIMARY KEY CLUSTERED 
(
	[lsm_cd_log_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
