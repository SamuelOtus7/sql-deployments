-- ============================================================
-- BASELINE: dbo.prefatura_murici_fm(in)
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[prefatura_murici_fm(in)]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[prefatura_murici_fm(in)](
	[Per_odo_Ano_M_s_Quinzena] [nvarchar](50) NULL,
	[Tipo_do_Servi_o] [nvarchar](50) NULL,
	[Opera_o] [nvarchar](50) NULL,
	[Hub_SOC] [nvarchar](50) NULL,
	[Station_Code] [nvarchar](50) NULL,
	[Rota] [int] NULL,
	[Driver_ID] [int] NULL,
	[Data_da_Presta_o_do_Servi_o] [datetime2](7) NULL,
	[Nome_Tomador_do_Servi_o] [nvarchar](50) NULL,
	[CNPJ_Tomador] [float] NULL,
	[Nome_Transportadora_3PL] [nvarchar](50) NULL,
	[KM_Rodado] [float] NULL,
	[Tipo_do_Ve_culo] [nvarchar](50) NULL,
	[Pacotes_atribu_dos] [nvarchar](50) NULL,
	[Pacotes_Entregues] [smallint] NULL,
	[Frete_Tarifa_Base_Peso_KM_Ve_culo] [float] NULL,
	[Frete_Calculado] [float] NULL,
	[Valor_Nota_Fiscal_Mercadoria] [nvarchar](50) NULL,
	[GRIS] [nvarchar](50) NULL,
	[Valor_ICMS_ISS] [nvarchar](50) NULL,
	[Ped_gio] [nvarchar](50) NULL,
	[Ajudante] [nvarchar](50) NULL,
	[Incentivo_Feriado_e_Domingo] [nvarchar](50) NULL,
	[Incentivo_Entrega] [nvarchar](50) NULL,
	[Desconto_Infrut_fera] [float] NULL,
	[Desconto_Segunda_Sa_da] [float] NULL,
	[Data_Emiss_o_Cte_NF] [nvarchar](50) NULL,
	[Fatura] [nvarchar](50) NULL,
	[N_mero_Cte] [nvarchar](50) NULL,
	[N_mero_NF] [nvarchar](50) NULL,
	[Serie_Cte_Nf] [nvarchar](50) NULL,
	[Chave_de_Acesso_Cte] [nvarchar](50) NULL,
	[Motivo_Rejei_o_CTE] [nvarchar](50) NULL,
	[Prefeitura_NFSe] [nvarchar](50) NULL,
	[Coment_rios] [nvarchar](50) NULL,
	[De_acordo_Sim_N_o] [nvarchar](50) NULL,
	[Motivo_Valor_incorreto_n_mero_de_ordens_incorreta_no_protocolo] [nvarchar](50) NULL,
	[Valor_Negociado_Caso_para_valor_incorreto] [nvarchar](50) NULL,
	[Observa_es] [nvarchar](50) NULL
) ON [PRIMARY]
GO
