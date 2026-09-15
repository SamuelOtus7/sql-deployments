-- ============================================================
-- BASELINE: dbo.tb_contratos_integracao_log
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_contratos_integracao_log]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_contratos_integracao_log](
	[cil_cd_log] [bigint] IDENTITY(1,1) NOT NULL,
	[cil_cd_usuario] [int] NOT NULL,
	[cil_cd_contrato] [int] NOT NULL,
	[cil_dh_integracao] [datetime] NOT NULL,
	[cil_in_sucesso] [bit] NOT NULL,
	[cil_ds_erro] [varchar](250) NOT NULL,
 CONSTRAINT [pk_contratos_integracao_log] PRIMARY KEY CLUSTERED 
(
	[cil_cd_log] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
