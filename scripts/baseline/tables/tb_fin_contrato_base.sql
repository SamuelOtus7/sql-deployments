-- ============================================================
-- BASELINE: dbo.tb_fin_contrato_base
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_contrato_base]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_contrato_base](
	[ctb_cd_contrato_base] [int] IDENTITY(1,1) NOT NULL,
	[ctb_cd_cliente] [int] NOT NULL,
	[ctb_svc] [varchar](10) NOT NULL,
	[ctb_saida] [varchar](10) NOT NULL,
	[ctb_cd_contrato] [varchar](10) NOT NULL,
 CONSTRAINT [PK_tb_fin_contrato_base] PRIMARY KEY CLUSTERED 
(
	[ctb_cd_contrato_base] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_fin_contrato_base] UNIQUE NONCLUSTERED 
(
	[ctb_cd_cliente] ASC,
	[ctb_svc] ASC,
	[ctb_saida] ASC,
	[ctb_cd_contrato] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
