-- ============================================================
-- BASELINE: dbo.tb_acessos_indicadores
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_acessos_indicadores]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_acessos_indicadores](
	[aci_cd_acessos_indicadores] [int] IDENTITY(1,1) NOT NULL,
	[aci_cd_transportadora] [int] NOT NULL,
	[aci_cd_usuario] [int] NOT NULL,
	[aci_in_marketplace] [varchar](30) NOT NULL,
	[aci_cd_base] [varchar](100) NOT NULL,
	[aci_in_ativo] [bit] NOT NULL,
	[aci_dh_criacao] [datetime] NOT NULL,
	[aci_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_acessos_indicadores] PRIMARY KEY CLUSTERED 
(
	[aci_cd_acessos_indicadores] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
