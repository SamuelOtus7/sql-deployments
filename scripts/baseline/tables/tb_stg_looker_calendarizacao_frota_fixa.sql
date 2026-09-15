-- ============================================================
-- BASELINE: dbo.tb_stg_looker_calendarizacao_frota_fixa
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_stg_looker_calendarizacao_frota_fixa]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_stg_looker_calendarizacao_frota_fixa](
	[DataExtracao] [datetime] NULL,
	[CodigoCliente] [bigint] NULL,
	[Arquivo] [varchar](max) NULL,
	[Semana] [bigint] NULL,
	[MLP] [varchar](max) NULL,
	[Regional] [varchar](max) NULL,
	[Facility] [varchar](max) NULL,
	[Cadastro_como_Deveria_Ser] [varchar](max) NULL,
	[Modal_reserva_como_deveria_ser] [varchar](max) NULL,
	[Tipo_de_Veiculo] [varchar](max) NULL,
	[Placa] [varchar](max) NULL,
	[Contrato] [varchar](max) NULL,
	[Sinergia_1_Dia] [varchar](max) NULL,
	[Sinergia_2_Dia] [varchar](max) NULL,
	[Segunda] [varchar](max) NULL,
	[Terca] [varchar](max) NULL,
	[Quarta] [varchar](max) NULL,
	[Quinta] [varchar](max) NULL,
	[Sexta] [varchar](max) NULL,
	[Sabado] [varchar](max) NULL,
	[Domingo] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
