-- ============================================================
-- BASELINE: dbo.tb_fin_modelo_ModeloExtras
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_modelo_ModeloExtras]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_modelo_ModeloExtras](
	[CodExtas] [int] IDENTITY(1,1) NOT NULL,
	[Responsavel] [nvarchar](100) NULL,
	[Data] [date] NULL,
	[Rota] [nvarchar](50) NULL,
	[Motorista] [nvarchar](150) NULL,
	[Observacoes] [nvarchar](255) NULL,
	[Valor] [nvarchar](50) NULL
) ON [PRIMARY]
GO
