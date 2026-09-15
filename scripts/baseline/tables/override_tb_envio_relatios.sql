-- ============================================================
-- BASELINE: dbo.override_tb_envio_relatios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[override_tb_envio_relatios]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[override_tb_envio_relatios](
	[er_cd_envio_relatorio] [int] IDENTITY(1,1) NOT NULL,
	[er_ds_cron_expression] [nvarchar](max) NULL,
	[er_cd_codigo_cliente] [int] NOT NULL,
	[er_dt_ultima_execucao] [datetime] NULL,
	[er_dt_proxima_execucao] [datetime] NULL,
	[er_nm_grupo] [nvarchar](max) NULL,
	[er_cd_relatorio] [int] NOT NULL,
	[tb_clientes_cli_cd_codigo_cliente] [int] NULL,
	[tb_relatorios_rel_cd_relatorio] [int] NULL,
 CONSTRAINT [PK_dbo.override_tb_envio_relatios] PRIMARY KEY CLUSTERED 
(
	[er_cd_envio_relatorio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
