-- ============================================================
-- BASELINE: dbo.tb_pag_espelhos_logs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_espelhos_logs]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_espelhos_logs](
	[lsm_cd_log_status] [int] IDENTITY(1,1) NOT NULL,
	[lsm_cd_motorista_nfs] [int] NOT NULL,
	[lsm_cd_status_anterior] [int] NULL,
	[lsm_cd_status_atual] [int] NOT NULL,
	[lsm_dt_data_log] [datetime] NOT NULL,
	[lsm_cd_usuario] [int] NOT NULL,
	[lsm_ds_mensagem] [varchar](1000) NULL,
	[lsm_nm_remetente] [varchar](100) NULL,
	[lsm_ds_status_notificacao] [nvarchar](32) NULL,
	[lsm_dh_notificacao_api_externa] [datetime] NULL,
	[lsm_ds_notificacao_api_externa_status] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[lsm_cd_log_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
