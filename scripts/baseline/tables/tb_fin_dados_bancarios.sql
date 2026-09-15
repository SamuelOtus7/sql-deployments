-- ============================================================
-- BASELINE: dbo.tb_fin_dados_bancarios
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_fin_dados_bancarios]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_fin_dados_bancarios](
	[cdb_cd_dados_bancarios] [int] IDENTITY(1,1) NOT NULL,
	[cdb_cd_cliente] [int] NOT NULL,
	[cdb_ds_tipo_validacao] [varchar](20) NOT NULL,
	[cdb_ds_pix_key] [varchar](100) NULL,
	[cdb_ds_pix_key_type] [varchar](20) NULL,
	[cdb_ds_nome] [varchar](50) NULL,
	[cdb_ds_cpf_cnpj] [varchar](14) NULL,
	[cdb_cd_bank] [varchar](3) NULL,
	[cdb_cd_agency] [varchar](4) NULL,
	[cdb_cd_account] [varchar](7) NULL,
	[cdb_cd_account_digit] [varchar](1) NULL,
	[cdb_ds_account_type] [varchar](20) NULL,
	[cdb_cd_processing_status] [int] NOT NULL,
	[cdb_dh_processing_datetime] [datetime] NULL,
	[cdb_ds_processing_result] [nvarchar](max) NULL,
	[cdb_dh_reference_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
