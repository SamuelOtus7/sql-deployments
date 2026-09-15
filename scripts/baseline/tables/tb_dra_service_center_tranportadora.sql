-- ============================================================
-- BASELINE: dbo.tb_dra_service_center_tranportadora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_service_center_tranportadora]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_service_center_tranportadora](
	[dst_codigo] [int] IDENTITY(1,1) NOT NULL,
	[dst_cd_transportadora] [int] NOT NULL,
	[dst_servicecenter] [varchar](50) NOT NULL,
	[dst_status] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[dst_codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_chave] UNIQUE NONCLUSTERED 
(
	[dst_cd_transportadora] ASC,
	[dst_servicecenter] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
