-- ============================================================
-- BASELINE: dbo.tb_mapa_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_mapa_rotas]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_mapa_rotas](
	[rota_hash] [varchar](255) NOT NULL,
	[rota_pontos] [varchar](max) NULL,
	[url] [varchar](max) NULL,
 CONSTRAINT [PK_tb_mapa_rotas] PRIMARY KEY CLUSTERED 
(
	[rota_hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
