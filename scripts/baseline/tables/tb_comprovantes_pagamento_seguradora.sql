-- ============================================================
-- BASELINE: dbo.tb_comprovantes_pagamento_seguradora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_comprovantes_pagamento_seguradora]    Script Date: 14/09/2026 12:12:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_comprovantes_pagamento_seguradora](
	[cps_cd_comprovante_pagamento_seguradora] [int] IDENTITY(1,1) NOT NULL,
	[cps_cd_usuario] [int] NOT NULL,
	[cps_cd_cliente] [int] NOT NULL,
	[cps_ds_status] [varchar](30) NOT NULL,
	[cps_ds_motivo] [varchar](250) NULL,
	[cps_cd_arquivo] [int] NULL,
	[cps_ds_arquivo_link] [varchar](4000) NULL,
	[cps_in_ativo] [bit] NOT NULL,
	[cps_in_excluido] [bit] NOT NULL,
	[cps_cd_usuario_criacao] [int] NOT NULL,
	[cps_dh_criacao] [datetime] NOT NULL,
	[cps_cd_usuario_modificacao] [int] NOT NULL,
	[cps_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pkcomprovantes_pagamento_seguradora] PRIMARY KEY CLUSTERED 
(
	[cps_cd_comprovante_pagamento_seguradora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
