-- ============================================================
-- BASELINE: dbo.tb_rcto_periodo
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rcto_periodo]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rcto_periodo](
	[rcb_cd_periodo] [int] IDENTITY(1,1) NOT NULL,
	[rcb_nm_periodo] [varchar](50) NOT NULL,
	[rcb_dt_inicio] [date] NOT NULL,
	[rcb_dt_fim] [date] NULL,
	[rcb_cd_status] [int] NOT NULL,
	[rcb_dh_criacao] [datetime] NOT NULL,
	[rcb_cd_usr_criacao] [int] NOT NULL,
	[rcb_dh_modificacao] [datetime] NOT NULL,
	[rcb_cd_usr_modificacao] [int] NOT NULL,
	[rcb_cd_cliente] [int] NOT NULL,
	[rcb_in_ativo] [bit] NOT NULL,
	[rcb_in_excluido] [bit] NOT NULL,
	[rcb_cd_tipo_contratos] [varchar](200) NULL,
PRIMARY KEY CLUSTERED 
(
	[rcb_cd_periodo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
