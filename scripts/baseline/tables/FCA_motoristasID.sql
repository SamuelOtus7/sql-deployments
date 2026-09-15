-- ============================================================
-- BASELINE: dbo.FCA_motoristasID
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[FCA_motoristasID]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FCA_motoristasID](
	[MatriculaID] [int] IDENTITY(1,1) NOT NULL,
	[matricula] [int] NULL,
	[status] [int] NOT NULL,
	[e-mail] [varchar](max) NULL,
	[contato] [varchar](max) NULL,
	[cpf] [varchar](max) NULL,
	[svc] [varchar](max) NULL,
	[Motorista] [varchar](max) NULL,
	[ag] [varchar](max) NULL,
	[conta] [varchar](max) NULL,
	[SVCHub] [varchar](max) NULL,
	[cep] [varchar](max) NULL,
	[residência] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
