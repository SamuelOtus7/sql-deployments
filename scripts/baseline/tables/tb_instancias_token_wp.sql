-- ============================================================
-- BASELINE: dbo.tb_instancias_token_wp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_instancias_token_wp]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_instancias_token_wp](
	[titw_cd_intancia_id] [int] IDENTITY(1,1) NOT NULL,
	[titw_ds_intancia_nome] [nvarchar](255) NOT NULL,
	[titw_ds_intancia_token] [nvarchar](255) NOT NULL,
	[titw_cd_intancia_cliente] [int] NULL,
	[titw_cd_intancia_numero] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[titw_cd_intancia_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[titw_ds_intancia_token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Cliente_Numero] UNIQUE NONCLUSTERED 
(
	[titw_cd_intancia_cliente] ASC,
	[titw_cd_intancia_numero] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
