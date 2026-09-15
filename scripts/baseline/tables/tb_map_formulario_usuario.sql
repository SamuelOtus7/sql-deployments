-- ============================================================
-- BASELINE: dbo.tb_map_formulario_usuario
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_map_formulario_usuario]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_map_formulario_usuario](
	[fru_cd_mapeamento] [int] IDENTITY(1,1) NOT NULL,
	[fru_cd_formulario_usuario] [int] NULL,
	[fru_ds_chave] [varchar](60) NOT NULL,
	[fru_ds_valor_mot] [varchar](50) NOT NULL,
	[fru_ds_valor_usr] [varchar](50) NOT NULL,
	[fru_dh_criacao] [datetime] NOT NULL,
	[fru_dh_modificacao] [datetime] NULL,
	[fru_ds_nome_campo] [varchar](100) NULL,
	[fru_ds_valor_vei] [varchar](50) NULL,
	[fru_in_ativo] [bit] NOT NULL,
 CONSTRAINT [PK_tb_map_formulario_motorista] PRIMARY KEY CLUSTERED 
(
	[fru_cd_mapeamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
