-- ============================================================
-- BASELINE: dbo.tb_spe_pacotes_prefatura
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_pacotes_prefatura]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_pacotes_prefatura](
	[IdTransportadora] [int] NULL,
	[Tipo_do_Servico] [varchar](50) NULL,
	[Operacao] [varchar](50) NULL,
	[SOC] [varchar](50) NULL,
	[Hub] [varchar](50) NULL,
	[Rota] [varchar](50) NULL,
	[Periodo_Ano_Mes_Quinzena] [varchar](50) NULL,
	[Tracking_Number_Numero_Etiqueta_Ordem_Shopee] [varchar](50) NULL,
	[Tracking_Number_Enviado_por_API_pela_Transportadora] [varchar](50) NULL,
	[Data_da_Prestacao_do_Servico] [date] NULL,
	[Nome_Tomador_do_Servico] [varchar](255) NULL,
	[CNPJ_Tomador] [varchar](50) NULL,
	[Nome_Transportadora_3PL] [varchar](255) NULL,
	[CNPJ_Emitente_3PL] [varchar](50) NULL,
	[CEP_Origem] [varchar](50) NULL,
	[Cidade_Origem] [varchar](100) NULL,
	[UF_Origem] [varchar](50) NULL,
	[CEP_Entrega] [varchar](50) NULL,
	[Cidade_Entrega] [varchar](100) NULL,
	[UF_Entrega] [varchar](50) NULL,
	[Dados_do_Seller] [varchar](255) NULL,
	[Data_da_Entrega] [date] NULL,
	[Quantidade_Volume] [int] NULL,
	[Peso_Real] [numeric](18, 8) NULL,
	[Peso_Cubado] [numeric](18, 8) NULL,
	[Peso_Calculado_Cobrado] [numeric](18, 8) NULL,
	[KM_Rodado] [numeric](18, 8) NULL,
	[Tipo_do_Veiculo] [varchar](50) NULL,
	[Fator_Agrupador_p_Cobranca_por_Veiculo] [varchar](50) NULL,
	[Placa] [varchar](50) NULL,
	[Valor_Nota_Fiscal_Mercadoria] [numeric](18, 8) NULL,
	[Tarifa_Aplicada] [numeric](18, 8) NULL,
	[Frete_Tarifa_Base_Peso_KM_Veiculo] [numeric](18, 8) NULL,
	[Frete_Calculado] [numeric](18, 8) NULL,
	[ADV] [numeric](18, 8) NULL,
	[GRIS] [numeric](18, 8) NULL,
	[Aliquota_ICMS_ISS] [numeric](18, 8) NULL,
	[Base_Calc_ICMS_ISS] [numeric](18, 8) NULL,
	[Valor_ICMS_ISS] [numeric](18, 8) NULL,
	[ICMS_Subst] [numeric](18, 8) NULL,
	[Outros_Valores] [numeric](18, 8) NULL,
	[Descontos] [numeric](18, 8) NULL,
	[Valor_Final_a_Receber] [numeric](18, 8) NULL,
	[Data_Emissao_Cte_NF] [datetime] NULL,
	[Fatura] [varchar](50) NULL,
	[Numero_Cte] [varchar](50) NULL,
	[Numero_NF] [varchar](50) NULL,
	[Serie_Cte_Nf] [varchar](50) NULL,
	[Chave_de_Acesso_Cte] [varchar](50) NULL,
	[Motivo_Rejeicao_CTE] [varchar](255) NULL,
	[Prefeitura_NFSe] [varchar](50) NULL,
	[Comentarios] [varchar](255) NULL,
	[De_acordo_Sim_Nao] [varchar](50) NULL,
	[Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo] [varchar](255) NULL,
	[Valor_Negociado_Caso_para_valor_incorreto] [numeric](18, 8) NULL,
	[Observacoes] [varchar](255) NULL,
	[UF_Tomador] [char](2) NULL,
	[Resultado] [varchar](250) NULL,
	[PackageUID] [int] NULL,
	[IdentityId] [int] NOT NULL,
	[ValorAjudante] [numeric](18, 8) NULL,
	[ValorIncentivo] [numeric](18, 8) NULL,
	[FlagRisco] [bit] NULL
) ON [PRIMARY]
GO
