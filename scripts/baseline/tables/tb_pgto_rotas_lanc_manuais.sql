-- ============================================================
-- BASELINE: dbo.tb_pgto_rotas_lanc_manuais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_rotas_lanc_manuais]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_rotas_lanc_manuais](
	[plm_cd_lancamentos] [int] IDENTITY(1,1) NOT NULL,
	[plm_cd_espelhos] [int] NOT NULL,
	[plm_cd_rota] [varchar](50) NULL,
	[plm_cd_lancamento] [int] NULL,
 CONSTRAINT [PK_tb_pgto_rotas_lanc_manuais] PRIMARY KEY CLUSTERED 
(
	[plm_cd_lancamentos] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
