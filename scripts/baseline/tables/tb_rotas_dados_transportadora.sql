-- ============================================================
-- BASELINE: dbo.tb_rotas_dados_transportadora
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_rotas_dados_transportadora]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_rotas_dados_transportadora](
	[rdt_cd_rotas] [int] IDENTITY(1,1) NOT NULL,
	[rdt_id_rota] [varchar](50) NOT NULL,
	[rdt_cd_transportadora] [int] NOT NULL,
	[rdt_cd_cliente] [int] NOT NULL,
	[rdt_cd_status] [int] NOT NULL,
	[rdt_dh_criacao] [datetime] NOT NULL,
	[rdt_cd_usr_criacao] [int] NOT NULL,
	[rdt_dh_modificacao] [datetime] NOT NULL,
	[rdt_cd_usr_modificacao] [int] NOT NULL,
	[rdt_in_ativo] [bit] NOT NULL,
	[rdt_in_excluido] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rdt_cd_rotas] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
