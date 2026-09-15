-- ============================================================
-- BASELINE: dbo.tb_log_dash_alarmes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_dash_alarmes]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_dash_alarmes](
	[log_id] [bigint] IDENTITY(1,1) NOT NULL,
	[dh_captura] [datetime2](3) NOT NULL,
	[id_transportadora] [int] NULL,
	[nm_cliente] [nvarchar](500) NULL,
	[nm_alarme] [nvarchar](200) NOT NULL,
	[cd_valor] [tinyint] NOT NULL,
	[ds_status] [nvarchar](80) NOT NULL,
	[qt_falhas] [int] NOT NULL,
	[ds_motivo] [nvarchar](1000) NULL,
 CONSTRAINT [PK_tb_log_dash_alarmes] PRIMARY KEY CLUSTERED 
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
