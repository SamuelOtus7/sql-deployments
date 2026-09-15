-- ============================================================
-- BASELINE: dbo.tb_decargo_gr
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_decargo_gr]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_decargo_gr](
	[Matrícula] [varchar](max) NULL,
	[Nome] [varchar](max) NULL,
	[CPF/CNPJ] [varchar](max) NULL,
	[Email] [varchar](max) NULL,
	[Status] [varchar](max) NULL,
	[Motivo Inativacao] [varchar](max) NULL,
	[Contrato] [varchar](max) NULL,
	[CNH Válida] [varchar](max) NULL,
	[Tipo de Usuário] [varchar](max) NULL,
	[Tipo de Veículo] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[Base] [varchar](max) NULL,
	[Data de Criação] [varchar](max) NULL,
	[Status validade do GR] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
