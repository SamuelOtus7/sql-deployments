-- ============================================================
-- BASELINE: dbo.tb_pag_espelhos_logs_nfse
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_espelhos_logs_nfse]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_espelhos_logs_nfse](
	[pln_cd_log] [int] IDENTITY(1,1) NOT NULL,
	[pln_cd_espelho] [int] NOT NULL,
	[pln_cd_status_anterior] [int] NOT NULL,
	[pln_cd_status_novo] [int] NOT NULL,
	[pln_dh_alteracao] [datetime] NOT NULL,
	[pln_ds_alteracao] [varchar](250) NOT NULL,
	[pln_ds_motivo_reprovacao] [varchar](150) NULL,
 CONSTRAINT [pk_pag_espelhos_logs_nfse] PRIMARY KEY CLUSTERED 
(
	[pln_cd_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
