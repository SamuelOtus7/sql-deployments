-- ============================================================
-- BASELINE: dbo.tb_fin_ficha_motorista
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_ficha_motorista]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_ficha_motorista](
	[Service Center] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[Cluster] [varchar](max) NULL,
	[Valor Saida] [decimal](9, 2) NULL,
	[Hora Incio] [varchar](max) NULL,
	[ID] [varchar](50) NULL,
	[Categoria] [varchar](max) NULL,
	[KM] [decimal](10, 2) NULL,
	[Prazo] [varchar](max) NULL,
	[Ciclo] [varchar](max) NULL,
	[Tipo de Contrato] [varchar](max) NULL,
	[Tipo de rota] [varchar](max) NULL,
	[Motorista recebedor] [int] NULL,
	[Motorista recebedor 2] [int] NULL,
	[Valores Extras] [decimal](9, 2) NULL,
	[Valor de apoio] [decimal](9, 2) NULL,
	[OBS Valor de apoio] [varchar](max) NULL,
	[Valor Pedágio] [decimal](9, 2) NULL,
	[OBS Valor Pedágio] [varchar](max) NULL,
	[Valor Desconto] [decimal](9, 2) NULL,
	[OBS Valor Desconto] [varchar](max) NULL,
	[Valor Extra] [decimal](9, 2) NULL,
	[OBS Valor Extra] [varchar](max) NULL,
	[IdTransportadora] [int] NULL,
	[Ano] [int] NULL,
	[Mes] [int] NULL,
	[Quinzena] [int] NULL,
	[faixakm] [varchar](50) NULL,
	[ValorApoio_mt_apoio] [decimal](10, 2) NULL,
	[OBSValordeapoio_mt_apoio] [varchar](200) NULL,
	[ValorPedágio_mt_apoio] [decimal](10, 2) NULL,
	[OBSValorPedágio_mt_apoio] [varchar](200) NULL,
	[ValorDesconto_mt_apoio] [decimal](10, 2) NULL,
	[OBSValorDesconto_mt_apoio] [varchar](200) NULL,
	[ValorExtra_mt_apoio] [decimal](9, 2) NULL,
	[OBSValorExtra_mt_apoio] [varchar](200) NULL,
	[PrazoMotoristaRecebedor2] [varchar](150) NULL,
	[TipoContratoMotoristaRecebedor2] [varchar](150) NULL,
	[MotoristaRecebedor2] [int] NULL,
	[ValorApoio2] [decimal](9, 2) NULL,
	[OBSValordeapoio2] [varchar](150) NULL,
	[ValorPedagio2] [decimal](9, 2) NULL,
	[ObsValorPedagio2] [varchar](150) NULL,
	[ValorDesconto2] [decimal](9, 2) NULL,
	[ObsValorDesconto2] [varchar](150) NULL,
	[ValorExtra2] [decimal](9, 2) NULL,
	[ObsValorExtra2] [varchar](150) NULL,
	[PrazoMotoristaRecebedorApoio] [varchar](150) NULL,
	[TipoContratoMotoristaRecebedorApoio] [varchar](150) NULL,
	[MotoristaRecebedorApoio] [int] NULL,
 CONSTRAINT [un_id] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
