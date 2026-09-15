-- ============================================================
-- BASELINE: dbo.tb_map_minutas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_map_minutas]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_map_minutas](
	[mmi_cd_mapeamento] [int] IDENTITY(1,1) NOT NULL,
	[mmi_cd_motorista] [int] NOT NULL,
	[mmi_cd_cliente] [int] NOT NULL,
	[mmi_ds_chave] [varchar](150) NOT NULL,
	[mmi_ds_valor] [varchar](200) NULL,
 CONSTRAINT [PK__tb_map_minutas] PRIMARY KEY CLUSTERED 
(
	[mmi_cd_mapeamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [tb_map_minutas_unique] UNIQUE NONCLUSTERED 
(
	[mmi_cd_motorista] ASC,
	[mmi_cd_cliente] ASC,
	[mmi_ds_chave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
