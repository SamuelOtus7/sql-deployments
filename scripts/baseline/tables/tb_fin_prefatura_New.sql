-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura_New
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura_New]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura_New](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[Veiculo] [varchar](100) NULL,
	[ContinuacaoVeiculo] [varchar](100) NULL,
	[ServiceCenter] [varchar](50) NULL,
	[KmCiclo] [varchar](50) NULL,
	[CicloPM] [char](2) NULL,
	[IntervaloFaixa] [varchar](10) NULL,
	[InicioIntervalo] [int] NULL,
	[FimIntervalo] [int] NULL,
	[Dia] [varchar](10) NULL,
	[IdRota] [varchar](50) NOT NULL,
	[DataInicio] [date] NOT NULL,
	[DataTermino] [date] NOT NULL,
	[Placa] [varchar](15) NULL,
	[Motorista] [varchar](60) NOT NULL,
	[Quantidade] [tinyint] NULL,
	[PrecoUnitario] [decimal](7, 2) NULL,
	[Total] [decimal](7, 2) NULL,
	[Parada] [int] NULL,
	[VLParada] [decimal](7, 2) NULL,
	[DataAtualizacao] [datetime] NULL,
	[EnderecoNaoVisitado] [int] NULL
) ON [PRIMARY]
GO
