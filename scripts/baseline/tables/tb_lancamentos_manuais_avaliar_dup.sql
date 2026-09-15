-- ============================================================
-- BASELINE: dbo.tb_lancamentos_manuais_avaliar_dup
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_lancamentos_manuais_avaliar_dup]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_lancamentos_manuais_avaliar_dup](
	[StatusPrimeiro] [varchar](30) NULL,
	[StatusUltimo] [varchar](30) NULL,
	[cli_ds_nome] [varchar](50) NOT NULL,
	[cli_in_ativo] [bit] NOT NULL,
	[ultimolancamento] [int] NULL,
	[primeirolancamento] [int] NULL,
	[qtde] [int] NULL,
	[tlm_cd_rota] [varchar](50) NULL,
	[tlm_cd_service_center] [varchar](150) NULL,
	[tlm_cd_motorista] [varchar](100) NULL,
	[tlm_cd_tipo] [varchar](30) NULL,
	[tlm_cd_periodo] [varchar](8) NULL,
	[tlm_cd_cliente] [int] NULL,
	[tlm_dh_referencia] [datetime] NULL,
	[tlm_cd_operacao] [int] NOT NULL,
	[tlm_ds_observacao] [varchar](250) NULL,
	[tlm_vl_valor_adicional] [decimal](18, 2) NULL,
	[tlm_vl_valor_descontos] [decimal](18, 2) NULL,
	[tlm_vl_valor_apoio] [decimal](8, 2) NULL,
	[tlm_ds_placa] [nvarchar](255) NULL,
	[tlm_in_ativo] [bit] NOT NULL,
	[tlm_in_excluido] [bit] NOT NULL
) ON [PRIMARY]
GO
