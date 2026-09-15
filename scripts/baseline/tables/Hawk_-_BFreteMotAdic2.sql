-- ============================================================
-- BASELINE: dbo.Hawk_-_BFreteMotAdic2
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[Hawk_-_BFreteMotAdic2]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hawk_-_BFreteMotAdic2](
	[Tipo de contrato] [varchar](max) NULL,
	[Service Center] [varchar](max) NULL,
	[Cidade] [float] NULL,
	[Tipo de veículo] [float] NULL,
	[Tipo adicional domingo] [bigint] NULL,
	[Valor adicional domingo/feriado] [bigint] NULL,
	[Tipo adicional ciclo PM] [bigint] NULL,
	[Valor adicional ciclo] [bigint] NULL,
	[Tipo adicional ajudante] [bigint] NULL,
	[Valor adicional ajudante] [bigint] NULL,
	[Valor adicional bônus por rota] [varchar](max) NULL,
	[Valor adicional bônus por rota.1] [bigint] NULL,
	[Tipo adicional risco] [bigint] NULL,
	[Valor adicional risco] [bigint] NULL,
	[Valor adicional pool] [bigint] NULL,
	[Valor adicional 1-59] [bigint] NULL,
	[Valor adicional 60-69] [bigint] NULL,
	[Valor adicional 70-79] [bigint] NULL,
	[Valor adicional 80 a 99- no km de 0 a 150] [bigint] NULL,
	[Valor adicional 80 a 99 -km 151 a 9999] [bigint] NULL,
	[Valor adicional 100 a 99999 - no km de 0 a 150 ] [bigint] NULL,
	[Valor adicional 100 a 99999 - no km de 151 a 9999] [bigint] NULL,
	[Tipo de adicional itens] [varchar](max) NULL,
	[bfa_cd_transportadora] [bigint] NULL,
	[bfa_cd_codigo_cliente] [bigint] NULL,
	[cd_operacao] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
