-- ============================================================
-- BASELINE: dbo.tb_termos_aceites_confirmados
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_termos_aceites_confirmados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_termos_aceites_confirmados](
	[tac_cd_termo_aceite_confirmado] [int] IDENTITY(1,1) NOT NULL,
	[tac_cd_termo_aceite] [int] NOT NULL,
	[tac_cd_usuario] [int] NOT NULL,
	[tac_cd_cliente] [int] NOT NULL,
	[tac_ds_ip] [varchar](200) NULL,
	[tac_ds_user_agent] [varchar](200) NULL,
	[tac_in_ativo] [bit] NOT NULL,
	[tac_in_excluido] [bit] NOT NULL,
	[tac_cd_usuario_criacao] [int] NOT NULL,
	[tac_dh_criacao] [datetime] NOT NULL,
	[tac_cd_usuario_modificacao] [int] NOT NULL,
	[tac_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_termo_aceite_confirmado] PRIMARY KEY CLUSTERED 
(
	[tac_cd_termo_aceite_confirmado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uk_termos_aceite_confirmados] UNIQUE NONCLUSTERED 
(
	[tac_cd_termo_aceite] ASC,
	[tac_cd_usuario] ASC,
	[tac_cd_cliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
