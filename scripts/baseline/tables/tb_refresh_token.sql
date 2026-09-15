-- ============================================================
-- BASELINE: dbo.tb_refresh_token
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_refresh_token]    Script Date: 14/09/2026 12:12:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_refresh_token](
	[rft_cd_refresh_token] [int] IDENTITY(1,1) NOT NULL,
	[rft_cd_usuario] [int] NOT NULL,
	[rft_tp_login] [int] NOT NULL,
	[rft_ds_token] [varchar](100) NOT NULL,
	[rft_dh_expires] [datetime] NOT NULL,
	[rft_dh_created] [datetime] NOT NULL,
	[rft_ds_created_by_ip] [varchar](100) NOT NULL,
	[rft_dh_revoked] [datetime] NULL,
	[rft_ds_revoked_by_ip] [varchar](100) NULL,
	[rft_ds_replaced_by_token] [varchar](100) NULL,
 CONSTRAINT [pk_refresh_token] PRIMARY KEY CLUSTERED 
(
	[rft_cd_refresh_token] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
