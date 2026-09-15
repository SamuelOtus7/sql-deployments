-- ============================================================
-- BASELINE: dbo.tb_ml_service_center_drop
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_service_center_drop]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_service_center_drop](
	[svc_cd_service_center] [varchar](50) NOT NULL,
	[svc_nm_service_center] [varchar](50) NOT NULL,
	[svc_nm_sigla] [varchar](50) NOT NULL,
	[svc_nm_region] [varchar](20) NULL,
	[Latitude] [varchar](15) NULL,
	[Longitude] [varchar](15) NULL,
	[svc_tipo] [varchar](30) NULL,
	[svc_nm_cidade] [varchar](30) NULL,
	[svc_nm_estado] [char](2) NULL,
	[svc_in_ativo] [bit] NULL,
 CONSTRAINT [PK_tb_ml_service_center] PRIMARY KEY CLUSTERED 
(
	[svc_cd_service_center] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
