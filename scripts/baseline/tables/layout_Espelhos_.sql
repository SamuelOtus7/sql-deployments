-- ============================================================
-- BASELINE: dbo.layout_Espelhos_
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[layout_Espelhos_]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[layout_Espelhos_](
	[Periodo] [date] NULL,
	[Rota] [int] NULL,
	[Placa] [nvarchar](50) NULL,
	[Veiculo] [nvarchar](50) NULL,
	[Hub_SVC] [nvarchar](50) NULL,
	[Pacotes] [smallint] NULL,
	[Insucessos] [int] NULL,
	[Paradas] [varchar](50) NULL,
	[Motorista] [nvarchar](50) NULL,
	[Matricula] [int] NULL,
	[Observacao] [nvarchar](500) NULL,
	[ValorTotal] [decimal](8, 2) NULL,
	[CPF] [bigint] NULL
) ON [PRIMARY]
GO
