-- ============================================================
-- BASELINE: dbo.tb_cte_lotes
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_cte_lotes]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_cte_lotes](
	[cte_cd_cte_lote] [int] IDENTITY(1,1) NOT NULL,
	[cte_nm_cte_lote] [varchar](50) NOT NULL,
	[cte_cd_cliente] [int] NOT NULL,
	[cte_cd_cliente_transportadora] [int] NOT NULL,
	[cte_cd_cte_tipo] [int] NOT NULL,
	[cte_cd_cte_tipo_lote] [int] NOT NULL,
	[cte_cd_cte_status] [int] NOT NULL,
	[cte_cd_prefatura] [int] NULL,
	[cte_cd_empresa] [int] NOT NULL,
	[cte_cd_usuario_autorizacao] [int] NULL,
	[cte_dh_autorizacao] [datetime] NULL,
	[cte_qt_pacotes] [int] NULL,
	[cte_vl_valor] [decimal](18, 2) NULL,
	[cte_cd_usr_criacao] [int] NOT NULL,
	[cte_dh_criacao] [datetime] NOT NULL,
	[cte_cd_usr_modificacao] [int] NOT NULL,
	[cte_dh_modificacao] [datetime] NOT NULL,
	[cte_in_ativo] [bit] NOT NULL,
	[cte_in_excluido] [bit] NOT NULL,
	[cte_in_unificar_ctes] [bit] NOT NULL,
	[cte_ds_tipo_veiculo] [varchar](50) NULL,
 CONSTRAINT [pk_cte_lotes] PRIMARY KEY CLUSTERED 
(
	[cte_cd_cte_lote] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
