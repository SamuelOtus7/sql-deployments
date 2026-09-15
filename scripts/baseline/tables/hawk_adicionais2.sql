-- ============================================================
-- BASELINE: dbo.hawk_adicionais2
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[hawk_adicionais2]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[hawk_adicionais2](
	[tipo de contrato] [varchar](max) NULL,
	[service center] [varchar](max) NULL,
	[cidade] [float] NULL,
	[tipo de veículo] [varchar](max) NULL,
	[tipo adicional domingo] [bigint] NULL,
	[valor adicional domingo/feriado] [bigint] NULL,
	[tipo adicional ciclo pm] [bigint] NULL,
	[valor adicional ciclo] [bigint] NULL,
	[tipo adicional ajudante] [bigint] NULL,
	[valor adicional ajudante] [bigint] NULL,
	[valor adicional bônus por rota] [varchar](max) NULL,
	[valor adicional bônus por rota.1] [bigint] NULL,
	[tipo adicional risco] [bigint] NULL,
	[valor adicional risco] [bigint] NULL,
	[valor adicional pool] [bigint] NULL,
	[valor adicional 1-59] [bigint] NULL,
	[valor adicional 60-69] [bigint] NULL,
	[valor adicional 70-79] [bigint] NULL,
	[valor adicional 80 a 99- no km de 0 a 150] [bigint] NULL,
	[valor adicional 80 a 99 -km 151 a 9999] [bigint] NULL,
	[valor adicional 100 a 99999 - no km de 0 a 150] [bigint] NULL,
	[valor adicional 100 a 99999 - no km de 151 a 9999] [bigint] NULL,
	[tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL,
	[tvl_cd_tipo_veiculo] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
