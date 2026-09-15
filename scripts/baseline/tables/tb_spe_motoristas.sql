-- ============================================================
-- BASELINE: dbo.tb_spe_motoristas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_motoristas]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_motoristas](
	[IdMotorista] [int] NOT NULL,
	[IdTransportadora] [int] NULL,
	[IdStation] [int] NULL,
	[Nome] [varchar](80) NOT NULL,
	[TipoVeiculo] [int] NULL,
	[TotalEntregas] [smallint] NULL,
	[Latitude] [varchar](15) NULL,
	[Longitude] [varchar](15) NULL,
	[Transportadora] [varchar](60) NULL,
	[NomeMotorista] [varchar](60) NULL,
	[FotoDocumento] [varchar](100) NULL,
	[FotoMotorista] [varchar](100) NULL,
	[Ativo] [bit] NOT NULL,
	[DataInativo] [date] NULL,
	[NomeTipoVeiculo] [varchar](100) NULL,
	[CPF] [varchar](14) NULL,
	[Status] [int] NULL,
	[Email] [varchar](100) NULL,
	[SubStatus] [int] NULL,
	[StatusLogin] [int] NULL,
	[Renavam] [varchar](30) NULL,
	[ModificacaoSPX] [date] NULL,
	[DisplayStatus] [varchar](100) NULL,
	[Aniversario] [date] NULL,
	[NomeStation] [varchar](100) NULL,
	[UltimoLoginSPX] [date] NULL,
	[Cidade] [varchar](100) NULL,
	[Rua] [varchar](100) NULL,
	[Numero] [varchar](50) NULL,
	[Cep] [int] NULL,
	[FlagAgencia] [varchar](10) NULL,
 CONSTRAINT [uni_spe_motorista] UNIQUE NONCLUSTERED 
(
	[IdMotorista] ASC,
	[IdTransportadora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
