-- ============================================================
-- BASELINE: dbo.tb_pag_espelhos_exclusao_rodoprime_indevidos
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pag_espelhos_exclusao_rodoprime_indevidos]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pag_espelhos_exclusao_rodoprime_indevidos](
	[pgp_cd_cliente] [int] NULL,
	[mtn_cd_motorista_nfs] [int] NOT NULL,
	[mtn_cd_status] [int] NOT NULL,
	[usr_cd_tipo_contrato] [int] NULL,
	[pgp_cd_tipo_contratos] [varchar](200) NULL,
	[pgp_nm_periodo] [varchar](50) NOT NULL,
	[pgp_cd_periodo] [int] NOT NULL
) ON [PRIMARY]
GO
