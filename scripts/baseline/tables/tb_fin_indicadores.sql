-- ============================================================
-- BASELINE: dbo.tb_fin_indicadores
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_indicadores]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_indicadores](
	[fid_cd_indicador] [int] IDENTITY(1,1) NOT NULL,
	[fid_cd_transportadora] [int] NOT NULL,
	[fid_nr_ano] [int] NOT NULL,
	[fid_nr_mes] [tinyint] NOT NULL,
	[fid_nr_quinzena] [tinyint] NOT NULL,
	[fid_nm_etapa] [varchar](50) NOT NULL,
	[fid_nm_indicador] [varchar](50) NOT NULL,
	[fid_vl_indicador] [decimal](10, 2) NOT NULL,
	[fid_vl_tipo] [varchar](30) NOT NULL,
	[fid_nr_ordem] [int] NOT NULL,
	[fid_vl_largura] [tinyint] NOT NULL,
	[fid_cd_cliente] [int] NULL,
	[fid_marketplace] [varchar](50) NULL,
	[fid_operacao] [varchar](50) NULL,
 CONSTRAINT [pk_tb_fin_indicadores] PRIMARY KEY CLUSTERED 
(
	[fid_cd_indicador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
