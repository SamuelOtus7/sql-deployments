-- ============================================================
-- BASELINE: dbo.tb_motoristas_stg
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_motoristas_stg]    Script Date: 14/09/2026 12:12:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_motoristas_stg](
	[mot_nm_motorista] [nvarchar](255) NULL,
	[mot_nm_motorista_original] [nvarchar](510) NULL,
	[mot_cpf] [nvarchar](30) NULL,
	[mot_tipo_pessoa] [nvarchar](20) NULL,
	[mot_ctn_cd_tipo_contrato] [nvarchar](50) NULL,
	[mot_ctn_in_status_contrato] [nvarchar](20) NULL,
	[mot_ds_marketplace] [nvarchar](100) NULL,
	[mot_pag_nm_titular] [nvarchar](100) NULL,
	[mot_ds_pix_key] [nvarchar](100) NULL,
	[mot_ds_pix_key_type] [nvarchar](50) NULL,
	[mot_ds_status_oxpay] [nvarchar](50) NULL,
	[mot_ds_status_oxpay_2] [nvarchar](100) NULL,
	[mot_cnt_vl_email] [nvarchar](150) NULL,
	[mot_ds_empresa_razao_social] [nvarchar](200) NULL,
	[mot_ds_empresa_cnpj] [nvarchar](30) NULL,
	[mot_ds_empresa_cnae] [nvarchar](150) NULL,
	[mot_ds_status_cnpj] [nvarchar](100) NULL,
	[mot_ds_status_cnpj_terceiros] [nvarchar](100) NULL,
	[mot_ds_observacao_contrato] [nvarchar](1000) NULL,
	[mot_gr_dt_renovacao] [nvarchar](20) NULL,
	[mot_gr_cd_status] [nvarchar](50) NULL,
	[mot_gr_dt_vencimento_cnh_motorista] [nvarchar](20) NULL,
	[situacao_cnh] [nvarchar](50) NULL,
	[mot_ds_plate] [nvarchar](20) NULL,
	[mot_nm_svc] [nvarchar](50) NULL
) ON [PRIMARY]
GO
