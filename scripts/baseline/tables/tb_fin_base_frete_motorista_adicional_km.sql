-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_motorista_adicional_km
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_motorista_adicional_km]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_motorista_adicional_km](
	[CodFrete] [int] IDENTITY(1,1) NOT NULL,
	[idtransportadora] [int] NULL,
	[ServiceCenter] [varchar](255) NULL,
	[Cidade] [varchar](255) NULL,
	[TipoVeiculo] [varchar](50) NULL,
	[InicioFaixa] [int] NULL,
	[FimFaixa] [int] NULL,
	[ValorFrete] [decimal](10, 2) NULL,
	[ValorFretePM] [decimal](10, 2) NULL,
	[ValorFreteFixo] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
