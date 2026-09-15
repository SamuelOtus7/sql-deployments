-- ============================================================
-- BASELINE: dbo.tb_mtr_webhook
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_mtr_webhook]    Script Date: 14/09/2026 12:12:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_mtr_webhook](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[tenantId] [int] NULL,
	[jsonData] [nvarchar](max) NULL,
	[createdAt] [datetime] NULL,
	[processingStatus] [smallint] NULL,
	[processingDatetime] [datetime] NULL,
	[processingResult] [varchar](100) NULL,
	[processingMessage] [varchar](250) NULL,
	[webhook] [varchar](255) NULL,
 CONSTRAINT [tb_mtr_webhook_pk] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
