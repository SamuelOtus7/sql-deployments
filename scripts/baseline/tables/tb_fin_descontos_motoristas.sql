-- ============================================================
-- BASELINE: dbo.tb_fin_descontos_motoristas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_descontos_motoristas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_descontos_motoristas](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[IdRota] [int] NOT NULL,
	[DataReferencia] [date] NULL,
	[ServiceCenter] [varchar](50) NULL,
	[Motorista] [varchar](100) NULL,
	[TipoVeiculo] [varchar](100) NULL,
	[Ciclo] [varchar](2) NULL,
	[Desconto] [decimal](7, 2) NULL,
	[Motivo] [varchar](30) NOT NULL,
	[IdPacote] [bigint] NOT NULL,
 CONSTRAINT [PK_tb_fin_descontos_motoristas] PRIMARY KEY CLUSTERED 
(
	[IdTransportadora] ASC,
	[IdRota] ASC,
	[IdPacote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
