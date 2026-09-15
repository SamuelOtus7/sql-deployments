-- ============================================================
-- BASELINE: dbo.drivercsv
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[drivercsv]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[drivercsv](
	[Numero] [int] NULL,
	[Motorista] [varchar](100) NULL,
	[STATUS] [nvarchar](50) NULL,
	[E_MAIL] [nvarchar](50) NULL,
	[CONTATO] [nvarchar](50) NULL,
	[CPF] [nvarchar](50) NULL,
	[Renavan] [nvarchar](50) NULL,
	[Placa] [nvarchar](50) NULL,
	[Tipo] [nvarchar](50) NULL,
	[Modelo_do_Veiculo] [nvarchar](50) NULL,
	[Ano_Veic] [nvarchar](50) NULL,
	[Tipo_de_Contrato] [nvarchar](50) NULL,
	[Contrato] [nvarchar](50) NULL,
	[StatusGR] [nvarchar](50) NULL,
	[Cor_do_Veiculo] [nvarchar](50) NULL,
	[SVC_HUB] [nvarchar](50) NULL,
	[Residência] [nvarchar](max) NULL,
	[CEP] [nvarchar](50) NULL,
	[VAZIA] [nvarchar](50) NULL,
	[Pagamento] [nvarchar](50) NULL,
	[Banco] [nvarchar](max) NULL,
	[Nome] [nvarchar](50) NULL,
	[CPF2] [nvarchar](50) NULL,
	[AG] [nvarchar](50) NULL,
	[Conta] [nvarchar](50) NULL,
	[Tipo_de_Conta] [nvarchar](50) NULL,
	[MEI_CNPJ] [nvarchar](50) NULL,
	[NUMERO2] [nvarchar](50) NULL,
	[SVC_HUB2] [nvarchar](50) NULL,
	[SETOR] [nvarchar](50) NULL,
	[FOCAL] [nvarchar](50) NULL,
	[CNPJ] [nvarchar](50) NULL,
	[TIPO_MEI_SIMPLES_NACIONAL] [nvarchar](50) NULL,
	[MEI_PRÓPRIO_OU_DE_TERCEIRO] [nvarchar](50) NULL,
	[column35] [nvarchar](50) NULL,
	[column36] [nvarchar](1) NULL,
	[column37] [nvarchar](1) NULL,
	[column38] [nvarchar](1) NULL,
	[column39] [nvarchar](1) NULL,
	[column40] [nvarchar](1) NULL,
	[column41] [nvarchar](1) NULL,
	[column42] [nvarchar](1) NULL,
	[column43] [nvarchar](1) NULL,
	[column44] [nvarchar](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
