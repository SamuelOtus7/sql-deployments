-- ============================================================
-- BASELINE: dbo.tb_dra_erros_coleta
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_dra_erros_coleta]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_dra_erros_coleta](
	[dec_cd_coleta] [bigint] IDENTITY(1,1) NOT NULL,
	[dec_cd_transportadora] [varchar](20) NOT NULL,
	[dec_ds_tipo_coleta] [varchar](50) NOT NULL,
	[dec_ds_contexto] [varchar](100) NOT NULL,
	[dec_ds_erro] [varchar](150) NOT NULL,
	[dec_dt_referencia] [datetime] NOT NULL,
	[dec_dh_coleta] [datetime] NOT NULL,
	[dec_dh_escrita] [datetime] NOT NULL,
	[dec_nr_tentativas] [int] NOT NULL,
 CONSTRAINT [pk_dra_erros_coleta] PRIMARY KEY CLUSTERED 
(
	[dec_cd_coleta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
