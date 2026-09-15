-- ============================================================
-- BASELINE: dbo.tb_envio_boas_vindas_lote_detalhe
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_envio_boas_vindas_lote_detalhe]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_envio_boas_vindas_lote_detalhe](
	[evld_cd_detalhe] [bigint] IDENTITY(1,1) NOT NULL,
	[evld_cd_lote] [bigint] NOT NULL,
	[evld_nu_ordem] [int] NOT NULL,
	[evld_ds_email] [nvarchar](320) NOT NULL,
	[evld_cd_usuario] [int] NULL,
	[evld_ds_status] [nvarchar](20) NOT NULL,
	[evld_ds_motivo_erro] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[evld_cd_detalhe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
