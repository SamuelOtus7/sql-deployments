-- ============================================================
-- BASELINE: dbo.tb_fin_dds
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_dds]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_dds](
	[Base] [nvarchar](255) NULL,
	[Data] [datetime] NULL,
	[Placa] [nvarchar](255) NULL,
	[Motorista] [nvarchar](255) NULL,
	[Destino] [nvarchar](255) NULL,
	[Rota Logistics] [float] NULL,
	[Cluster] [nvarchar](255) NULL,
	[Qtd# Pacotes] [float] NULL,
	[Qtd# Paradas] [float] NULL,
	[Pgto# Saída] [float] NULL,
	[Pgto# Paradas] [float] NULL,
	[Adicional] [float] NULL,
	[Pgto# Total Motorista] [float] NULL,
	[Faixa KM] [nvarchar](255) NULL,
	[Receb# Meli] [float] NULL,
	[Receb# Paradas] [float] NULL,
	[Adicional1] [float] NULL,
	[Pedágio] [float] NULL,
	[Receita Total] [float] NULL,
	[Faixa KM1] [nvarchar](255) NULL,
	[Lucro (R$)] [float] NULL,
	[Lucro (%)] [float] NULL,
	[Ciclo PM] [nvarchar](255) NULL,
	[Tipo de Minuta] [nvarchar](255) NULL,
	[Minuta] [float] NULL,
	[Observação] [nvarchar](255) NULL,
	[Classificação do Veículo] [nvarchar](255) NULL,
	[Link Rota] [nvarchar](255) NULL,
	[Km Percorrido] [float] NULL,
	[LINK PEDÁGIO] [nvarchar](255) NULL,
	[LINK STRAVA] [nvarchar](255) NULL
) ON [PRIMARY]
GO
