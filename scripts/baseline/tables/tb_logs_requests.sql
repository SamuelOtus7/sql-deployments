-- ============================================================
-- BASELINE: dbo.tb_logs_requests
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_logs_requests]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_logs_requests](
	[lrq_cd_log] [bigint] IDENTITY(1,1) NOT NULL,
	[lrq_dh_ocorrencia] [datetime] NOT NULL,
	[lrq_cd_usuario] [int] NULL,
	[log_ds_metodo] [varchar](100) NOT NULL,
	[request_body] [varchar](max) NOT NULL,
	[response_body] [varchar](max) NULL,
	[lrq_ds_origin_ip] [varchar](255) NULL,
	[lrq_ds_navegador] [varchar](max) NULL,
 CONSTRAINT [pk_logs_requests] PRIMARY KEY CLUSTERED 
(
	[lrq_cd_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
