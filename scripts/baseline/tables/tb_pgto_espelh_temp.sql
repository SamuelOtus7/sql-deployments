-- ============================================================
-- BASELINE: dbo.tb_pgto_espelh_temp
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_espelh_temp]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_espelh_temp](
	[Periodo] [nvarchar](200) NULL,
	[rota] [varchar](100) NULL,
	[placa] [varchar](100) NULL,
	[veiculo] [varchar](100) NULL,
	[svc] [varchar](100) NULL,
	[pacotes] [varchar](100) NULL,
	[insuscesso] [varchar](100) NULL,
	[paradas] [varchar](100) NULL,
	[Profissional] [nvarchar](200) NULL,
	[Matricula] [nvarchar](200) NULL,
	[Observacao] [nvarchar](510) NULL,
	[ValorTotal] [nvarchar](200) NULL,
	[CPF] [nvarchar](200) NULL
) ON [PRIMARY]
GO
