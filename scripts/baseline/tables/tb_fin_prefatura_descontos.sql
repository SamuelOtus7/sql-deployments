-- ============================================================
-- BASELINE: dbo.tb_fin_prefatura_descontos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_prefatura_descontos]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_prefatura_descontos](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IdTransportadora] [int] NOT NULL,
	[Ano] [int] NOT NULL,
	[Mes] [tinyint] NOT NULL,
	[Quinzena] [tinyint] NOT NULL,
	[DataReferencia] [date] NOT NULL,
	[IdRota] [int] NOT NULL,
	[IdPacote] [bigint] NULL,
	[IdPenalidade] [int] NULL,
	[Descricao] [varchar](200) NULL,
	[Quantidade] [tinyint] NULL,
	[PrecoUnitario] [decimal](7, 2) NULL,
	[Total] [decimal](7, 2) NULL,
	[DataQuinzena] [date] NULL,
	[DataAtualizacao] [datetime] NOT NULL,
	[Motorista] [varchar](255) NULL,
	[UsuarioDA] [int] NULL
) ON [PRIMARY]
GO
