-- ============================================================
-- BASELINE: dbo.tb_descontos_prefatura_erros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_descontos_prefatura_erros]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_descontos_prefatura_erros](
	[dpe_id] [int] IDENTITY(1,1) NOT NULL,
	[dpe_id_transportadora] [int] NOT NULL,
	[dpe_ano] [int] NOT NULL,
	[dpe_mes] [tinyint] NOT NULL,
	[dpe_quinzena] [tinyint] NOT NULL,
	[dpe_cd_rota] [int] NOT NULL,
	[dpe_cd_pacote] [bigint] NULL,
	[dpe_ds_desconto] [varchar](200) NOT NULL,
	[dpe_nm_motorista] [varchar](200) NULL,
	[dpe_ds_erro] [varchar](500) NOT NULL,
	[dpe_dh_criacao] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[dpe_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
