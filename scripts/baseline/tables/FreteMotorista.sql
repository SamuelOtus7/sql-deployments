-- ============================================================
-- BASELINE: dbo.FreteMotorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[FreteMotorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FreteMotorista](
	[TipoContrato] [nvarchar](50) NULL,
	[ServiceCenter] [nvarchar](50) NULL,
	[Cidade] [nvarchar](100) NULL,
	[TipoVeiculo] [nvarchar](100) NULL,
	[InicioFaixa] [int] NULL,
	[FimFaixa] [int] NULL,
	[ValorFrete] [decimal](10, 2) NULL,
	[ValorFretePM] [decimal](10, 2) NULL,
	[ValorFreteFixo] [decimal](10, 2) NULL
) ON [PRIMARY]
GO
