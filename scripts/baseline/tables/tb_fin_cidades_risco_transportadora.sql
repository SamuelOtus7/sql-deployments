-- ============================================================
-- BASELINE: dbo.tb_fin_cidades_risco_transportadora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_cidades_risco_transportadora]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_cidades_risco_transportadora](
	[crt_cd_risco_transportadora] [int] IDENTITY(1,1) NOT NULL,
	[crt_cd_transportadora] [int] NOT NULL,
	[crt_cd_service_center] [varchar](50) NOT NULL,
	[crt_nm_cidade] [varchar](150) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[crt_cd_risco_transportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
