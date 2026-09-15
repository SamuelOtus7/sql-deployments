-- ============================================================
-- BASELINE: dbo.tb_ssrs_spe_monitoramento_status_pacote
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ssrs_spe_monitoramento_status_pacote]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ssrs_spe_monitoramento_status_pacote](
	[CodStatus] [int] IDENTITY(1,1) NOT NULL,
	[datareferencia] [date] NULL,
	[idtransportadora] [int] NULL,
	[servicecenter] [varchar](150) NULL,
	[CompradorAusente] [int] NULL,
	[NegocioFechado] [int] NULL,
	[EnderecoRuim] [int] NULL,
	[Compradorrejeitado] [int] NULL,
	[ForaRota] [int] NULL,
	[ProblemasMecanicos] [int] NULL,
	[MotoristaSemTempo] [int] NULL,
	[FalhaAplicativo] [int] NULL,
	[AreaRisco] [int] NULL,
	[ClienteMudou] [int] NULL,
	[Outros] [int] NULL,
	[Perdido] [int] NULL
) ON [PRIMARY]
GO
