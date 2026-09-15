-- ============================================================
-- BASELINE: dbo.ado_veiculos2
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[ado_veiculos2]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ado_veiculos2](
	[placa] [varchar](max) NULL,
	[base (sigla do service center ou hub)] [varchar](max) NULL,
	[tipo de veículo] [varchar](max) NULL,
	[tipo de frota] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
