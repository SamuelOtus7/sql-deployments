-- ============================================================
-- BASELINE: dbo.tb_fin_pagamento_adicional
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_pagamento_adicional]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_pagamento_adicional](
	[IdPagamentoAdicional] [int] IDENTITY(1,1) NOT NULL,
	[IdRota] [int] NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[FaixaParada] [decimal](25, 2) NULL,
	[FaixaPacote] [decimal](25, 2) NULL,
	[vl_quantidade] [decimal](10, 2) NULL,
	[IdPeriodo] [int] NULL
) ON [PRIMARY]
GO
