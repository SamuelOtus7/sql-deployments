-- ============================================================
-- BASELINE: dbo.drivernew
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[drivernew]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[drivernew](
	[Numero] [int] NULL,
	[Motorista] [nvarchar](50) NULL,
	[STATUS] [nvarchar](50) NULL,
	[E_MAIL] [nvarchar](255) NULL,
	[CONTATO] [nvarchar](50) NULL,
	[CPF] [nvarchar](50) NULL,
	[Renavan] [nvarchar](50) NULL,
	[Placa] [nvarchar](50) NULL,
	[Tipo] [nvarchar](50) NULL,
	[Modelo_do_Veiculo] [nvarchar](50) NULL,
	[Ano_Veic] [nvarchar](max) NULL,
	[Tipo_de_Contrato] [nvarchar](50) NULL,
	[Contrato] [nvarchar](50) NULL,
	[StatusGR] [nvarchar](50) NULL,
	[Cor_do_Veiculo] [nvarchar](50) NULL,
	[SVC_HUB] [nvarchar](50) NULL,
	[Residência] [nvarchar](max) NULL,
	[CEP] [nvarchar](50) NULL,
	[VAZIA] [nvarchar](50) NULL,
	[Pagamento] [nvarchar](50) NULL,
	[Banco] [nvarchar](50) NULL,
	[Nome] [nvarchar](50) NULL,
	[CPFTITULAR] [nvarchar](50) NULL,
	[CNPJ_TITULAR] [nvarchar](50) NULL,
	[AG] [nvarchar](50) NULL,
	[Conta] [nvarchar](50) NULL,
	[Tipo_de_Conta] [nvarchar](50) NULL,
	[MEI_CNPJ] [nvarchar](50) NULL,
	[NUMERO2] [nvarchar](max) NULL,
	[SVC_HUB2] [nvarchar](50) NULL,
	[SETOR] [nvarchar](50) NULL,
	[FOCAL] [nvarchar](50) NULL,
	[CNPJ] [nvarchar](50) NULL,
	[TIPO_MEI_SIMPLES_NACIONAL] [nvarchar](50) NULL,
	[MEI_PRÓPRIO_OU_DE_TERCEIRO] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
