-- ============================================================
-- BASELINE: dbo.tb_dra_transportadora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_transportadora]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_transportadora](
	[tpr_cd_transportadora] [int] NOT NULL,
	[tpr_nome_transportadora] [varchar](60) NOT NULL,
	[tpr_cd_marketplace] [tinyint] NOT NULL,
 CONSTRAINT [pk_ml_transportadora] PRIMARY KEY CLUSTERED 
(
	[tpr_cd_transportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
