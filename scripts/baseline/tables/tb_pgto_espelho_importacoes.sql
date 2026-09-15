-- ============================================================
-- BASELINE: dbo.tb_pgto_espelho_importacoes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_espelho_importacoes]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_espelho_importacoes](
	[pei_cd_importacao] [bigint] IDENTITY(1,1) NOT NULL,
	[pei_dt_envio] [datetime] NOT NULL,
	[pei_ds_caminho_blob] [nvarchar](2000) NULL,
	[pei_qt_total_linhas] [int] NOT NULL,
	[pei_qt_total_sucesso] [int] NOT NULL,
	[pei_qt_total_erro] [int] NOT NULL,
	[pei_cd_cliente] [int] NOT NULL,
	[pei_cd_periodo] [int] NOT NULL,
	[pei_cd_tipo_espelho] [int] NOT NULL,
	[pei_cd_usr_criacao] [int] NOT NULL,
	[pei_dh_criacao] [datetime] NOT NULL,
	[pei_in_excluido] [bit] NOT NULL,
	[pei_cd_marketplace] [int] NOT NULL,
	[pei_cd_tipo_operacao] [int] NOT NULL,
 CONSTRAINT [PK__tb_pgto___550E15089DF7B2EC] PRIMARY KEY CLUSTERED 
(
	[pei_cd_importacao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
