-- ============================================================
-- BASELINE: dbo.tb_pl_monitoramento_stg
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pl_monitoramento_stg]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pl_monitoramento_stg](
	[id] [varchar](max) NULL,
	[pedido] [varchar](max) NULL,
	[data_do_carregamento_lista] [varchar](max) NULL,
	[lista_entrega] [varchar](max) NULL,
	[motorista_lista] [varchar](max) NULL,
	[tipo_do_veiculo] [varchar](max) NULL,
	[ultima_ocorrencia] [varchar](max) NULL,
	[data_ultima_ocorrencia] [varchar](max) NULL,
	[tipo_da_ocorrencia] [varchar](max) NULL,
	[possui_comprovante] [varchar](max) NULL,
	[filial_entrega] [varchar](max) NULL,
	[rota_entrega] [varchar](max) NULL,
	[usuario_da_ocorrencia] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
