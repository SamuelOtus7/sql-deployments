-- ============================================================
-- BASELINE: dbo.tb_crud
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_crud]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_crud](
	[crd_cd_crud] [int] IDENTITY(1,1) NOT NULL,
	[crd_cd_controller] [smallint] NOT NULL,
	[crd_nm_rota] [varchar](300) NOT NULL,
	[crd_nm_rota_params] [varchar](150) NOT NULL,
	[crd_nm_tabela] [varchar](300) NOT NULL,
	[crd_nm_delete_logico] [varchar](100) NULL,
	[crd_nm_filtro_cliente] [varchar](30) NULL,
 CONSTRAINT [PK_tb_crud] PRIMARY KEY CLUSTERED 
(
	[crd_cd_crud] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
