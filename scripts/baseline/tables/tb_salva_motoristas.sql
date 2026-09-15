-- ============================================================
-- BASELINE: dbo.tb_salva_motoristas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_salva_motoristas]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_salva_motoristas](
	[mot_cd_motorista] [int] IDENTITY(1,1) NOT NULL,
	[mot_cd_cliente] [int] NOT NULL,
	[mot_cd_matricula] [int] NULL,
	[mot_cd_foto] [int] NULL,
	[mot_nm_motorista] [varchar](100) NULL,
	[mot_cpf] [varchar](20) NULL,
	[mot_cd_status] [int] NULL,
	[mot_dt_nascimento] [datetime] NULL,
	[mot_ctn_cd_tipo_contrato] [int] NULL,
	[mot_ctn_in_status_contrato] [bit] NULL,
	[mot_nm_ajudante] [varchar](100) NULL,
	[mot_cd_ajudante] [int] NULL,
	[mot_cpf_ajudante] [varchar](11) NULL,
	[mot_contato_ajudante] [varchar](15) NULL,
	[mot_end_nm_residencia] [varchar](50) NULL,
	[mot_end_vl_cep] [varchar](11) NULL,
	[mot_end_ds_rua] [varchar](100) NULL,
	[mot_end_vl_numero] [int] NULL,
	[mot_end_ds_complemento] [varchar](100) NULL,
	[mot_end_nm_bairro] [varchar](100) NULL,
	[mot_end_nm_cidade] [int] NULL,
	[mot_end_nm_estado] [int] NULL,
	[mot_pag_nm_empresa] [varchar](20) NULL,
	[mot_pag_nm_banco] [varchar](20) NULL,
	[mot_pag_nm_titular] [varchar](100) NULL,
	[mot_pag_cpf_titular] [varchar](20) NULL,
	[mot_pag_cd_agencia] [char](4) NULL,
	[mot_pag_cd_conta] [varchar](20) NULL,
	[mot_pag_ds_tipo_conta] [varchar](10) NULL,
	[mot_cnt_vl_celular] [varchar](20) NULL,
	[mot_cnt_vl_telefone] [varchar](20) NULL,
	[mot_cnt_vl_celular_2] [varchar](20) NULL,
	[mot_cnt_vl_email] [varchar](150) NULL,
	[mot_cnt_emg_nm_contato] [varchar](100) NULL,
	[mot_cnt_emg_vl_telefone] [varchar](11) NULL,
	[mot_cnt_emg_vl_celular] [varchar](11) NULL,
	[mot_cnt_emg_vl_celular_2] [varchar](11) NULL,
	[mot_cnt_emg_grau_parentesco] [varchar](10) NULL,
	[mot_emp_ds_tipo] [varchar](30) NULL,
	[mot_emp_in_propria] [bit] NULL,
	[mot_gr_nm_mae] [varchar](100) NULL,
	[mot_gr_nm_pai] [varchar](100) NULL,
	[mot_gr_cd_status] [int] NULL,
	[mot_gr_dt_renovacao] [date] NULL,
	[mot_gr_nm_tipo_motorista] [int] NULL,
	[mot_gr_nm_tipo_nacionalidade] [int] NULL,
	[mot_gr_nm_pais_motorista] [int] NULL,
	[mot_gr_vl_rg_motorista] [varchar](10) NULL,
	[mot_gr_nm_estado_rg_motorista] [int] NULL,
	[mot_gr_vl_cnh_prontuario_motorista] [varchar](11) NULL,
	[mot_gr_vl_cnh_motorista] [varchar](11) NULL,
	[mot_gr_dt_primeira_cnh_motorista] [date] NULL,
	[mot_gr_dt_vencimento_cnh_motorista] [date] NULL,
	[mot_gr_nm_tipo_cnh_motorista] [int] NULL,
	[mot_gr_vl_renach_cnh_motorista] [varchar](15) NULL,
	[mot_nm_svc] [varchar](50) NULL,
	[mot_percentual_cadastro] [decimal](10, 2) NULL,
	[mot_ds_status_cadastro] [varchar](50) NULL,
	[mot_cd_usuario] [int] NULL,
	[mot_celular_ajudante] [varchar](15) NULL,
	[mot_end_nm_pais] [int] NULL,
	[mot_gr_vl_estado_cnh_motorista] [int] NULL
) ON [PRIMARY]
GO
