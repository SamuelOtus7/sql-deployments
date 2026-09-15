-- ============================================================
-- BASELINE: dbo.tb_ml_status_entrega_traducao
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_status_entrega_traducao]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_status_entrega_traducao](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TenantID] [int] NOT NULL,
	[StatusEntrega] [varchar](50) NOT NULL,
	[StatusEntregaTraduzido] [nvarchar](100) NOT NULL,
	[SubStatus] [varchar](50) NULL,
	[SubStatusTraduzido] [nvarchar](510) NULL,
	[se_ds_classificacao] [nvarchar](100) NULL,
	[DataCriacao] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
