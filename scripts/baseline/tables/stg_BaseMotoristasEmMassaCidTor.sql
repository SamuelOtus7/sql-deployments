-- ============================================================
-- BASELINE: dbo.stg_BaseMotoristasEmMassaCidTor
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[stg_BaseMotoristasEmMassaCidTor]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stg_BaseMotoristasEmMassaCidTor](
	[Motorista] [varchar](max) NULL,
	[Proprietário ] [varchar](max) NULL,
	[Proprietario e Motorista] [varchar](max) NULL,
	[CPF] [varchar](max) NULL,
	[RG] [varchar](max) NULL,
	[Endereço] [varchar](max) NULL,
	[Cidade] [varchar](max) NULL,
	[UF] [varchar](max) NULL,
	[celular] [varchar](max) NULL,
	[telefone] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
