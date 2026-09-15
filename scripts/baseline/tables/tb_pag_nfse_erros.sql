-- ============================================================
-- BASELINE: dbo.tb_pag_nfse_erros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_nfse_erros]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_nfse_erros](
	[pne_cd_erro] [int] IDENTITY(1,1) NOT NULL,
	[pne_ds_erro] [varchar](250) NOT NULL,
	[pne_qt_tentativas] [tinyint] NOT NULL,
 CONSTRAINT [pk_pag_nfse_erros] PRIMARY KEY CLUSTERED 
(
	[pne_cd_erro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_pag_nfse_erros] UNIQUE NONCLUSTERED 
(
	[pne_ds_erro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
