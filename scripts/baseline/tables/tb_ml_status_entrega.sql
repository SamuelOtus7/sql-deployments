-- ============================================================
-- BASELINE: dbo.tb_ml_status_entrega
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_ml_status_entrega]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_ml_status_entrega](
	[se_cd_status] [int] IDENTITY(1,1) NOT NULL,
	[se_ds_status_entrega] [nvarchar](255) NOT NULL,
	[se_ds_classificacao] [nvarchar](50) NOT NULL,
	[TenantID] [int] NOT NULL,
	[se_nm_tabela] [varchar](128) NOT NULL,
	[se_nm_campo] [varchar](128) NOT NULL,
	[se_vl_substatus_json] [varchar](100) NOT NULL,
	[se_ds_status_traduzido] [nvarchar](255) NOT NULL,
	[se_ds_classificacao_tenant] [nvarchar](50) NULL,
	[se_ds_conta_endereco_visitado] [varchar](3) NOT NULL,
	[se_dt_criacao] [datetime2](3) NOT NULL,
	[se_dt_atualizacao] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_tb_ml_status_entrega] PRIMARY KEY CLUSTERED 
(
	[se_cd_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_ml_status_entrega_tenant_substatus] UNIQUE NONCLUSTERED 
(
	[TenantID] ASC,
	[se_vl_substatus_json] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
