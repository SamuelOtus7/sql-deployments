-- ============================================================
-- BASELINE: dbo.tb_spe_webhook_dev
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_webhook_dev]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_webhook_dev](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[jsonData] [nvarchar](max) NULL,
	[createdAt] [datetime] NULL,
	[processingStatus] [smallint] NULL,
	[processingDatetime] [datetime] NULL,
	[processingResult] [varchar](100) NULL,
	[processingMessage] [varchar](250) NULL,
 CONSTRAINT [tb_spe_webhook_dev_pk] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
