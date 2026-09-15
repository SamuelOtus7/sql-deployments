-- ============================================================
-- BASELINE: dbo.tb_integracao_flex_parametros
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_integracao_flex_parametros]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_integracao_flex_parametros](
	[ifp_cd_parametro] [int] IDENTITY(1,1) NOT NULL,
	[ifp_cd_cliente] [int] NOT NULL,
	[ifp_cd_tipo_veiculo] [int] NULL,
	[ifp_vl_limite_reais] [decimal](18, 8) NOT NULL,
	[ifp_vl_limite_litros] [decimal](18, 8) NOT NULL,
	[ifp_qt_minutos_bloqueio] [smallint] NOT NULL,
	[ifp_cd_base] [int] NULL,
 CONSTRAINT [pk_integracao_flex_parametros] PRIMARY KEY CLUSTERED 
(
	[ifp_cd_parametro] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
