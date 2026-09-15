-- ============================================================
-- BASELINE: dbo.tb_log_envios_relatorios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_log_envios_relatorios]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_log_envios_relatorios](
	[ler_cd_log_envio] [int] IDENTITY(1,1) NOT NULL,
	[ler_cd_envio_relatorio] [int] NULL,
	[ler_cd_relatorio] [int] NOT NULL,
	[ler_cd_transportadora] [int] NOT NULL,
	[ler_ds_parametro1] [varchar](250) NOT NULL,
	[ler_ds_parametro2] [varchar](250) NOT NULL,
	[ler_ds_parametro3] [varchar](250) NOT NULL,
	[ler_ds_parametro4] [varchar](250) NOT NULL,
	[ler_ds_parametro5] [varchar](250) NOT NULL,
	[ler_ds_parametro6] [varchar](250) NOT NULL,
	[ler_ds_parametro7] [varchar](250) NOT NULL,
	[ler_ds_parametro8] [varchar](250) NOT NULL,
	[ler_ds_parametro9] [varchar](250) NOT NULL,
	[ler_ds_parametro10] [varchar](250) NOT NULL,
	[ler_dh_envio] [datetime] NOT NULL,
	[ler_ds_status_envio] [varchar](100) NOT NULL,
	[ler_ds_erro] [varchar](250) NULL,
	[ler_in_finalizado] [bit] NOT NULL,
 CONSTRAINT [pk_log_envios_relatorios] PRIMARY KEY CLUSTERED 
(
	[ler_cd_log_envio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
