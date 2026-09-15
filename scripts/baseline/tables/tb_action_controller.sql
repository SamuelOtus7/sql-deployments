-- ============================================================
-- BASELINE: dbo.tb_action_controller
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_action_controller]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_action_controller](
	[acc_cd_action_controller] [int] IDENTITY(1,1) NOT NULL,
	[acc_cd_action] [smallint] NOT NULL,
	[acc_cd_controller] [smallint] NOT NULL,
	[acc_in_ativo] [bit] NOT NULL,
	[acc_dh_criacao] [datetime] NOT NULL,
	[acc_dh_modificacao] [datetime] NOT NULL,
 CONSTRAINT [pk_action_controller] PRIMARY KEY CLUSTERED 
(
	[acc_cd_action_controller] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
