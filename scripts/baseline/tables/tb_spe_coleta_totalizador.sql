-- ============================================================
-- BASELINE: dbo.tb_spe_coleta_totalizador
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_coleta_totalizador]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_coleta_totalizador](
	[cmt_cd_coleta] [bigint] IDENTITY(1,1) NOT NULL,
	[cmt_cd_transportadora] [varchar](20) NOT NULL,
	[cmt_cd_servicecenter] [varchar](20) NOT NULL,
	[cmt_ds_json] [varchar](max) NOT NULL,
	[cmt_dh_referencia] [date] NOT NULL,
	[cmt_dh_coleta] [datetime] NOT NULL,
	[cmt_dh_escrita] [datetime] NOT NULL,
	[cmt_dh_processamento] [datetime] NULL,
	[cmt_in_processado] [bit] NOT NULL,
 CONSTRAINT [pk_spe_coleta_totalizador] PRIMARY KEY CLUSTERED 
(
	[cmt_cd_coleta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
