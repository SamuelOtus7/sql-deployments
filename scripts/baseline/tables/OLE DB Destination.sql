-- ============================================================
-- BASELINE: dbo.OLE DB Destination
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[OLE DB Destination]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OLE DB Destination](
	[Tipo do Serviço] [varchar](50) NULL,
	[Operação] [varchar](50) NULL,
	[SOC] [varchar](50) NULL,
	[Hub] [varchar](50) NULL,
	[Rota] [varchar](50) NULL,
	[Período (Ano_Mês_Quinzena)] [varchar](50) NULL,
	[3PL Tracking Number   Número Etiqueta   Ordem (Shopee)] [varchar](50) NULL,
	[3PL Tracking Number (Enviado por API pela Transportadora)] [varchar](50) NULL,
	[Data da Prestação do Serviço] [varchar](50) NULL,
	[Nome Tomador do Serviço] [varchar](50) NULL,
	[CNPJ Tomador] [varchar](50) NULL,
	[Nome Transportadora (3PL)] [varchar](50) NULL,
	[CNPJ Emitente (3PL)] [varchar](50) NULL,
	[CEP Origem] [varchar](50) NULL,
	[Cidade Origem] [varchar](50) NULL,
	[UF Origem] [varchar](50) NULL,
	[CEP Entrega] [varchar](50) NULL,
	[Cidade Entrega] [varchar](50) NULL,
	[UF Entrega] [varchar](50) NULL,
	[Dados do Seller] [varchar](50) NULL,
	[Data da Entrega] [varchar](50) NULL,
	[Quantidade Volume] [varchar](50) NULL,
	[Peso Real] [varchar](50) NULL,
	[Peso Cubado] [varchar](50) NULL,
	[Peso Calculado Cobrado] [varchar](50) NULL,
	[KM Rodado] [varchar](50) NULL,
	[Tipo do Veículo] [varchar](50) NULL,
	[Fator Agrupador (p  Cobrança por Veiculo)] [varchar](50) NULL,
	[Placa] [varchar](50) NULL,
	[Valor nota Fiscal Mercadoria] [varchar](50) NULL,
	[Tarifa Aplicada] [varchar](50) NULL,
	[Frete Tarifa Base (Peso KM Veículo)] [varchar](50) NULL,
	[Frete Calculado] [varchar](50) NULL,
	[ADV] [varchar](50) NULL,
	[GRIS] [varchar](50) NULL,
	[Aliquota ICMS ISS] [varchar](50) NULL,
	[Base Calc ICMS ISS] [varchar](50) NULL,
	[Valor ICMS ISS] [varchar](50) NULL,
	[ICMS Subst] [varchar](50) NULL,
	[Outros Valores] [varchar](50) NULL,
	[Descontos] [varchar](50) NULL,
	[Valor Final à Receber] [varchar](50) NULL,
	[Data Emissão Cte NF] [varchar](50) NULL,
	[Fatura] [varchar](50) NULL,
	[Número Cte] [varchar](50) NULL,
	[Número NF] [varchar](50) NULL,
	[Serie Cte  Nf] [varchar](50) NULL,
	[Chave de Acesso Cte] [varchar](50) NULL,
	[Motivo Rejeição CTE] [varchar](50) NULL,
	[Prefeitura NFSe] [varchar](50) NULL,
	[Comentários] [varchar](50) NULL,
	[De acordo (Sim Não)] [varchar](50) NULL,
	[Motivo (Valor incorreto número de ordens incorreta no protocolo)] [varchar](50) NULL,
	[Valor Negociado (Caso para valor incorreto)] [varchar](50) NULL,
	[Observações] [varchar](50) NULL
) ON [PRIMARY]
GO
