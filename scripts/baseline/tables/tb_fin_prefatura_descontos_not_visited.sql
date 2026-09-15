-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura_descontos_not_visited
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura_descontos_not_visited]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura_descontos_not_visited](
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[IdRota] [int] NOT NULL,
	[Descricao] [varchar](120) NOT NULL,
	[Quantidade] [tinyint] NOT NULL,
	[PrecoUnitario] [decimal](7, 2) NULL,
	[Total] [decimal](7, 2) NULL,
 CONSTRAINT [PK_tb_fin_prefatura_descontos_not_visited] PRIMARY KEY CLUSTERED 
(
	[IdTransportadora] ASC,
	[Ano] ASC,
	[Mes] ASC,
	[Quinzena] ASC,
	[IdRota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
