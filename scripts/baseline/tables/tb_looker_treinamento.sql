-- ============================================================
-- BASELINE: dbo.tb_looker_treinamento
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_looker_treinamento]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_looker_treinamento](
	[tnm_cd_treinamento] [int] IDENTITY(1,1) NOT NULL,
	[tnm_cd_cliente] [varchar](100) NOT NULL,
	[tnm_nome_treinamento] [varchar](100) NOT NULL,
	[tnm_data_inicio] [date] NOT NULL,
	[tnm_data_fim] [date] NULL,
	[tnm_observacao] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[tnm_cd_treinamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_nome_data] UNIQUE NONCLUSTERED 
(
	[tnm_nome_treinamento] ASC,
	[tnm_data_inicio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
