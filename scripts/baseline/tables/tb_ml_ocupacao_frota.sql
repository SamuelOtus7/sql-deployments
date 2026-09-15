-- ============================================================
-- BASELINE: dbo.tb_ml_ocupacao_frota
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_ocupacao_frota]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_ocupacao_frota](
	[codocupacao] [int] IDENTITY(1,1) NOT NULL,
	[data] [date] NOT NULL,
	[DiaDaSemana] [varchar](20) NULL,
	[DataCadastro] [date] NULL,
	[idtransportadora] [bigint] NOT NULL,
	[idcliente] [int] NULL,
	[placa] [varchar](20) NOT NULL,
	[tipoveiculo] [varchar](100) NULL,
	[servicecenter] [varchar](100) NULL,
	[DiasUteis] [int] NULL,
	[carregamento] [int] NULL,
	[Naocarregamento] [int] NULL,
	[TipoFrota] [varchar](100) NULL,
	[CategoriaVeiculo] [varchar](100) NULL,
	[NomeMotorista] [varchar](200) NULL,
	[tipoveiculocad] [varchar](200) NULL,
	[DataAtualizacao] [datetime] NULL,
	[codveiculo] [int] NULL,
	[Ciclo] [varchar](5) NULL,
 CONSTRAINT [PK_tbl_CarregamentoPlanilha] PRIMARY KEY CLUSTERED 
(
	[data] ASC,
	[placa] ASC,
	[idtransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
