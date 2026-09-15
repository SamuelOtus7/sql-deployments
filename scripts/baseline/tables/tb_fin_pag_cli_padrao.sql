-- ============================================================
-- BASELINE: dbo.tb_fin_pag_cli_padrao
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_pag_cli_padrao]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_pag_cli_padrao](
	[Data] [date] NULL,
	[SVC] [nvarchar](50) NULL,
	[Tipo_Veiculo] [nvarchar](50) NULL,
	[Motorista] [nvarchar](255) NULL,
	[FaixaKM] [nvarchar](50) NULL,
	[Rota] [nvarchar](50) NULL,
	[Cidade] [nvarchar](50) NULL,
	[Ciclo] [nvarchar](50) NULL,
	[Pacotes] [int] NULL,
	[Pacotes_Entregues] [int] NULL,
	[Pacotes_Nao_Entregues] [int] NULL,
	[Qtd_Paradas] [int] NULL,
	[Qtd_Pontos] [int] NULL,
	[Valor_Total] [decimal](10, 2) NULL,
	[Valor_Base] [decimal](10, 2) NULL,
	[Adicional] [decimal](10, 2) NULL,
	[Dom_Fer] [decimal](10, 2) NULL,
	[Bonus] [decimal](10, 2) NULL,
	[Risco] [decimal](10, 2) NULL,
	[Desconto] [decimal](10, 2) NULL,
	[Periodo] [int] NULL
) ON [PRIMARY]
GO
