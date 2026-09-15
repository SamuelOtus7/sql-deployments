-- ============================================================
-- BASELINE: dbo.Motorista para Atualizar
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Motorista para Atualizar]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Motorista para Atualizar](
	[Data] [varchar](max) NULL,
	[ID da rota] [varchar](max) NULL,
	[Motorista] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[Diaria] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Fechamento] [varchar](max) NULL,
	[Tag: Operação] [varchar](max) NULL,
	[Observação: Operação] [varchar](max) NULL,
	[Quinzena] [varchar](max) NULL,
	[Milha] [varchar](max) NULL,
	[Valor (Not Visited)] [varchar](max) NULL,
	[CPF] [varchar](max) NULL,
	[Performance] [varchar](max) NULL,
	[CPF Verificado] [varchar](max) NULL,
	[Verificação] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
