-- ============================================================
-- BASELINE: dbo.tb_ml_rotas_fora_area_entrega
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_rotas_fora_area_entrega]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_rotas_fora_area_entrega](
	[idAreaEntrega] [int] IDENTITY(1,1) NOT NULL,
	[idtransportadora] [int] NOT NULL,
	[datareferencia] [date] NOT NULL,
	[Rota] [int] NOT NULL,
	[CidadeApp] [varchar](150) NULL,
	[AreaDeEntrega] [varchar](150) NULL,
	[pontosAppRotasTotalKm] [float] NULL,
	[pontosRotasPacotesKm] [float] NULL,
	[delta] [float] NULL
) ON [PRIMARY]
GO
