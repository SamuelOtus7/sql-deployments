-- ============================================================
-- BASELINE: dbo.tb_ml_veiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_veiculos]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_veiculos](
	[IdVeiculo] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[Placa] [varchar](7) NOT NULL,
	[IdTipo] [int] NOT NULL,
	[Tipo] [varchar](60) NOT NULL,
	[Capacidade] [decimal](5, 2) NULL,
	[Tracao] [bit] NOT NULL,
	[QuantidadePlacaUtilizacao] [tinyint] NOT NULL,
	[UltimaAtualizacao] [datetime] NOT NULL,
	[DataColeta] [datetime] NOT NULL,
 CONSTRAINT [pk_tb_ml_veiculos] PRIMARY KEY CLUSTERED 
(
	[IdVeiculo] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_tb_ml_veiculos_placa] UNIQUE NONCLUSTERED 
(
	[Placa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
