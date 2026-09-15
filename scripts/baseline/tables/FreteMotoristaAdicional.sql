-- ============================================================
-- BASELINE: dbo.FreteMotoristaAdicional
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[FreteMotoristaAdicional]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FreteMotoristaAdicional](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TipoContrato] [varchar](50) NULL,
	[ServiceCenter] [varchar](50) NULL,
	[Cidade] [varchar](100) NULL,
	[TipoVeiculo] [varchar](50) NULL,
	[TipoAdicionalDomingo] [varchar](50) NULL,
	[ValorAdicionalDomingo] [varchar](50) NULL,
	[TipoAdicionalCicloPM] [varchar](50) NULL,
	[ValorAdicionalCicloPM] [varchar](50) NULL,
	[TipoAdicionalAjudante] [varchar](50) NULL,
	[ValorAdicionalAjudante] [varchar](50) NULL,
	[TipoAdicionalRisco] [varchar](50) NULL,
	[ValorAdicionalRisco] [varchar](50) NULL,
	[ValorAdicionalPool] [varchar](50) NULL,
	[ValorAdicional_0_60] [varchar](50) NULL,
	[ValorAdicional_61_75] [varchar](50) NULL,
	[ValorAdicional_76_85] [varchar](50) NULL,
	[ValorAdicional_86_90] [varchar](50) NULL,
	[ValorAdicionalAcimaDe90] [varchar](50) NULL,
	[TipoAdicionalItens] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
