-- ============================================================
-- BASELINE: dbo.tb_validacoes_espelho_resultados
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_espelho_resultados]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_espelho_resultados](
	[ver_cd_validacao_resultado] [int] IDENTITY(1,1) NOT NULL,
	[ver_cd_validacao_contexto] [int] NOT NULL,
	[ver_cd_periodo] [int] NOT NULL,
	[ver_cd_pagamento_rota] [int] NULL,
	[ver_cd_lancamento_manual] [int] NULL,
	[ver_in_resultado_sucesso] [bit] NOT NULL,
	[ver_cd_usuario_inativacao] [int] NULL,
	[ver_dh_inativacao] [datetime] NULL,
	[ver_cd_rota] [varchar](30) NULL,
	[ver_dh_sucesso] [datetime] NULL,
 CONSTRAINT [pk_tb_validacoes_espelho_resultados] PRIMARY KEY CLUSTERED 
(
	[ver_cd_validacao_resultado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_validacoes_espelho_resultados] UNIQUE NONCLUSTERED 
(
	[ver_cd_validacao_contexto] ASC,
	[ver_cd_periodo] ASC,
	[ver_cd_pagamento_rota] ASC,
	[ver_cd_rota] ASC,
	[ver_cd_lancamento_manual] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
