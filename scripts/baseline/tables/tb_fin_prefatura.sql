-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[Veiculo] [varchar](100) NOT NULL,
	[ContinuacaoVeiculo] [varchar](100) NULL,
	[ServiceCenter] [varchar](50) NOT NULL,
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
	[Quantidade] [int] NULL,
	[PrecoUnitario] [decimal](7, 2) NULL,
	[Total] [decimal](7, 2) NULL,
	[Parada] [int] NULL,
	[VLParada] [decimal](7, 2) NULL,
	[DataAtualizacao] [datetime] NULL,
	[EnderecoNaoVisitado] [int] NULL,
 CONSTRAINT [PK_tb_fin_prefatura] PRIMARY KEY CLUSTERED 
(
	[IdTransportadora] ASC,
	[IdRota] ASC,
	[DataTermino] ASC,
	[Quinzena] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
