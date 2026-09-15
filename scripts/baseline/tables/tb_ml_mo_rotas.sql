-- ============================================================
-- BASELINE: dbo.tb_ml_mo_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_mo_rotas]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_mo_rotas](
	[Id] [bigint] IDENTITY(1000000000000,1) NOT NULL,
	[IdTransportadora] [int] NULL,
	[IdRota] [int] NULL,
	[DataReferencia] [date] NULL,
	[DataHoraInicio] [datetime] NULL,
	[ServiceCenter] [varchar](10) NULL,
	[TipoVeiculo] [varchar](50) NULL,
	[NomeMotorista] [varchar](90) NULL,
	[PlacaVeiculo] [varchar](15) NULL,
	[UsuarioDA] [int] NULL,
	[Excluido] [bit] NOT NULL,
	[AmbulanciaStatus] [varchar](100) NULL,
	[AmbulanciaPagamento] [varchar](50) NULL,
	[AmbulanciaIdMotorista] [int] NULL,
 CONSTRAINT [PK_tb_ml_mo_rotas] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_ml_mo_rotas] UNIQUE NONCLUSTERED 
(
	[IdRota] ASC,
	[IdTransportadora] ASC,
	[DataReferencia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
