-- ============================================================
-- BASELINE: dbo.Importacao_Veiculos_Torres
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Importacao_Veiculos_Torres]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Importacao_Veiculos_Torres](
	[PLACA] [varchar](255) NULL,
	[TIPO FROTA] [varchar](255) NULL,
	[BASE] [varchar](255) NULL,
	[TIPO VEÍCULO] [varchar](255) NULL,
	[ANO DO VEÍCULO] [varchar](255) NULL,
	[UF VEÍCULO] [varchar](255) NULL,
	[TIPO RODADO] [varchar](255) NULL,
	[TIPO CARROCERIA] [varchar](255) NULL,
	[CAPACIDADE] [varchar](255) NULL,
	[RENAVAM] [varchar](255) NULL,
	[SEGURADORA] [varchar](255) NULL,
	[NOME DO PROPRIETÁRIO] [varchar](255) NULL,
	[RNTRC] [varchar](255) NULL,
	[UF] [varchar](255) NULL,
	[CPF CNPJ] [varchar](255) NULL,
	[VALOR MENSAL DO ALUGUEL] [varchar](255) NULL,
	[MODELO DE COBRANÇA] [varchar](255) NULL,
	[DATA INÍCIO DO ALUGUEL] [varchar](255) NULL,
	[DATA FIM DO ALUGUEL] [varchar](255) NULL
) ON [PRIMARY]
GO
