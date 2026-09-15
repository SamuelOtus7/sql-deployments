-- ============================================================
-- BASELINE: dbo.tb_cidades_regiao_nao_identificadas_api
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_cidades_regiao_nao_identificadas_api]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_cidades_regiao_nao_identificadas_api](
	[IdCidadeRegiao] [int] IDENTITY(1,1) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[Cidade] [varchar](100) NOT NULL,
	[LatitudeMin] [decimal](9, 6) NOT NULL,
	[LatitudeMax] [decimal](9, 6) NOT NULL,
	[LongitudeMin] [decimal](9, 6) NOT NULL,
	[LongitudeMax] [decimal](9, 6) NOT NULL,
	[Ativo] [bit] NOT NULL,
	[DataCriacao] [datetime] NOT NULL,
	[DataAtualizacao] [datetime] NULL,
 CONSTRAINT [PK_tb_cidades_regiao_nao_identificadas_api] PRIMARY KEY CLUSTERED 
(
	[IdCidadeRegiao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_cidade_cliente] UNIQUE NONCLUSTERED 
(
	[IdTransportadora] ASC,
	[Cidade] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
