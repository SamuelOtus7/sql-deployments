-- ============================================================
-- BASELINE: dbo.tb_logs
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_logs]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_logs](
	[log_cd_log] [int] IDENTITY(1,1) NOT NULL,
	[log_cd_tipo] [int] NOT NULL,
	[log_dh_ocorrencia] [datetime] NOT NULL,
	[log_ds_URI] [varchar](100) NULL,
	[log_ds_metodo] [varchar](100) NULL,
	[log_ds_descricao] [varchar](max) NULL,
	[log_cd_usuario] [int] NULL,
 CONSTRAINT [PK_tb_logs] PRIMARY KEY CLUSTERED 
(
	[log_cd_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
