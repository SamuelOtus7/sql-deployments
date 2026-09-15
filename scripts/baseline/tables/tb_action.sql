-- ============================================================
-- BASELINE: dbo.tb_action
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_action]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_action](
	[act_cd_action] [smallint] IDENTITY(1,1) NOT NULL,
	[act_nm_action] [varchar](30) NOT NULL,
	[act_ds_action] [varchar](150) NOT NULL,
	[act_in_ativo] [bit] NOT NULL,
	[act_dh_criacao] [datetime] NOT NULL,
	[act_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_action] PRIMARY KEY CLUSTERED 
(
	[act_cd_action] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
