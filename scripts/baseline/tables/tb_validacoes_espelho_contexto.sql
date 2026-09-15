-- ============================================================
-- BASELINE: dbo.tb_validacoes_espelho_contexto
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_validacoes_espelho_contexto]    Script Date: 14/09/2026 12:12:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_validacoes_espelho_contexto](
	[vec_cd_validacao_contexto] [int] IDENTITY(1,1) NOT NULL,
	[vec_cd_validacao] [int] NOT NULL,
	[vec_cd_cliente_transportadora] [int] NOT NULL,
	[vec_cd_operacao] [int] NOT NULL,
	[vec_in_ativo] [bit] NOT NULL,
	[vec_dh_criacao] [datetime] NOT NULL,
	[vec_cd_usuario_criacao] [int] NOT NULL,
	[vec_dh_modificacao] [datetime] NOT NULL,
	[vec_cd_usuario_modificacao] [int] NOT NULL,
 CONSTRAINT [pk_tb_validacoes_espelho_contexto] PRIMARY KEY CLUSTERED 
(
	[vec_cd_validacao_contexto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
) ON [PRIMARY]
GO
