-- ============================================================
-- BASELINE: dbo.EspelhoCPFFCA
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[EspelhoCPFFCA]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EspelhoCPFFCA](
	[Periodo] [nvarchar](50) NULL,
	[Rota] [nvarchar](50) NULL,
	[Placa] [nvarchar](50) NULL,
	[Veiculo] [nvarchar](50) NULL,
	[Hub_SVC] [nvarchar](50) NULL,
	[Pacotes] [nvarchar](50) NULL,
	[Pacotes_Entregas] [nvarchar](50) NULL,
	[Insucessos] [tinyint] NULL,
	[Paradas] [tinyint] NULL,
	[Região] [nvarchar](50) NULL,
	[nomepro] [nvarchar](50) NULL,
	[Matricula] [smallint] NULL,
	[Observacao] [nvarchar](max) NULL,
	[ValorTotal] [float] NULL,
	[CPF] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
