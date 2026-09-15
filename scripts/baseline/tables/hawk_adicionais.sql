-- ============================================================
-- BASELINE: dbo.hawk_adicionais
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[hawk_adicionais]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hawk_adicionais](
	[tipo de contrato] [varchar](max) NULL,
	[service center] [varchar](max) NULL,
	[cidade] [float] NULL,
	[tipo de veículo] [varchar](max) NULL,
	[tipo adicional domingo] [float] NULL,
	[valor adicional domingo/feriado] [float] NULL,
	[tipo adicional ciclo pm] [float] NULL,
	[valor adicional ciclo] [float] NULL,
	[tipo adicional ajudante] [float] NULL,
	[valor adicional ajudante] [float] NULL,
	[tipo adicional risco] [float] NULL,
	[valor adicional risco] [float] NULL,
	[valor adicional bônus por rota] [varchar](max) NULL,
	[valor adicional bônus por rota.1] [float] NULL,
	[tipo de adicional itens] [float] NULL,
	[tipo adicional ajudante domingo] [float] NULL,
	[valor adicional ajudante domingo] [float] NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
