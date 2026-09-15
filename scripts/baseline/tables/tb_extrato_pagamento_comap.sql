-- ============================================================
-- BASELINE: dbo.tb_extrato_pagamento_comap
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_extrato_pagamento_comap]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_extrato_pagamento_comap](
	[mtn_cd_pgto_periodo] [int] NOT NULL,
	[Base] [varchar](50) NULL,
	[Motorista] [varchar](200) NULL,
	[Responsavel] [varchar](100) NULL,
	[Placa] [varchar](50) NULL,
	[QtdRotas] [int] NULL,
	[TotalReceber] [decimal](38, 2) NULL,
	[TotalDiariaLiqPre] [decimal](38, 2) NULL,
	[Parada] [decimal](38, 2) NULL,
	[Pedagio] [decimal](38, 2) NULL,
	[PacotePerdido] [decimal](38, 2) NOT NULL,
	[PNR] [decimal](38, 2) NOT NULL,
	[EnderecaoNaoVisitado] [decimal](38, 2) NOT NULL,
	[ppr_vl_risco] [decimal](38, 2) NULL,
	[ppr_vl_ajudante] [decimal](38, 2) NULL,
	[ppr_vl_dom_fer] [decimal](38, 2) NULL,
	[ppr_vl_lancamentos] [decimal](38, 2) NULL,
	[ValorAvulso] [decimal](38, 2) NOT NULL
) ON [PRIMARY]
GO
