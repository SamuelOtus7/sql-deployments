-- ============================================================
-- BASELINE: dbo.tb_fin_base_frete_parametro_indicadores
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_base_frete_parametro_indicadores]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_base_frete_parametro_indicadores](
	[idParametro] [int] IDENTITY(1,1) NOT NULL,
	[TipoContrato] [varchar](50) NULL,
	[ServiceCenter] [varchar](50) NULL,
	[Cidade] [varchar](50) NULL,
	[TipoVeiculo] [varchar](50) NULL,
	[OrdemFaixa] [int] NULL,
	[Adicional] [nvarchar](128) NULL,
	[Faixa] [nvarchar](4000) NULL,
	[Valor] [varchar](8000) NULL,
	[idtransportadora] [int] NULL
) ON [PRIMARY]
GO
