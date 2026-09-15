-- ============================================================
-- BASELINE: dbo.tb_ml_traducoes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_traducoes]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_traducoes](
	[tds_cd_traducao] [smallint] IDENTITY(1,1) NOT NULL,
	[tds_nm_tabela] [varchar](60) NOT NULL,
	[tds_nm_campo] [varchar](60) NOT NULL,
	[tds_vl_json] [varchar](60) NOT NULL,
	[tds_ds_traducao] [varchar](60) NOT NULL,
 CONSTRAINT [PK_tb_ml_traducoes] PRIMARY KEY CLUSTERED 
(
	[tds_cd_traducao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Traducao] UNIQUE NONCLUSTERED 
(
	[tds_nm_tabela] ASC,
	[tds_nm_campo] ASC,
	[tds_vl_json] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
