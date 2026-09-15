-- ============================================================
-- BASELINE: dbo.veiculos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[veiculos]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[veiculos](
	[numero] [varchar](10) NULL,
	[motorista] [varchar](100) NULL,
	[status] [varchar](20) NULL,
	[contato] [varchar](20) NULL,
	[cpf] [varchar](20) NULL,
	[renavan] [varchar](20) NULL,
	[placa] [varchar](10) NULL,
	[tipo] [varchar](20) NULL,
	[modelo_veiculo] [varchar](50) NULL,
	[ano_veic] [int] NULL,
	[svc] [varchar](20) NULL,
	[contrato] [varchar](20) NULL,
	[status_gr] [varchar](20) NULL,
	[cor_veiculo] [varchar](20) NULL,
	[svc_hub] [varchar](50) NULL,
	[residencia] [varchar](100) NULL,
	[cep] [varchar](10) NULL,
	[pagamento] [varchar](20) NULL,
	[banco] [varchar](50) NULL,
	[nome_banco] [varchar](100) NULL,
	[cpf_banco] [varchar](20) NULL,
	[agencia] [varchar](10) NULL,
	[conta] [varchar](20) NULL,
	[tipo_conta] [varchar](20) NULL,
	[cnpj_cpf] [varchar](20) NULL,
	[mei_cnpj] [varchar](20) NULL,
	[numero_veic] [varchar](10) NULL,
	[svc_hub_2] [varchar](50) NULL,
	[cnpj] [varchar](20) NULL,
	[tipo_empresa] [varchar](50) NULL,
	[mei_proprio] [varchar](20) NULL
) ON [PRIMARY]
GO
