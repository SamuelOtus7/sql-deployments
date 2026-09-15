-- ============================================================
-- BASELINE: dbo.tb_pgto_lancamento_desc_cartao_flex_frota
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_pgto_lancamento_desc_cartao_flex_frota](
	[pcf_cd_lc_cartao] [int] IDENTITY(1,1) NOT NULL,
	[pcf_cd_periodo] [int] NOT NULL,
	[pcf_cd_motorista_nfs] [int] NOT NULL,
	[pcf_vl_desconto_cartao_flex_frota] [decimal](18, 2) NOT NULL,
	[pcf_vl_total] [decimal](18, 2) NOT NULL,
	[pcf_dh_criacao] [datetime] NOT NULL,
	[pcf_cd_usr_criacao] [int] NOT NULL,
	[pcf_dh_modificacao] [datetime] NOT NULL,
	[pcf_cd_usr_modificacao] [int] NOT NULL,
	[pcf_in_ativo] [bit] NOT NULL,
	[pcf_in_excluido] [bit] NOT NULL,
	[pcf_base_principal] [varchar](20) NULL,
	[pcf_lcto_observacao] [varchar](255) NULL,
	[pcf_nome_motorista] [varchar](100) NULL,
	[pcf_cd_motorista] [int] NULL,
	[pcf_data_referencia] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[pcf_cd_lc_cartao] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
