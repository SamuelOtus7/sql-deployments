-- ============================================================
-- BASELINE: dbo.tb_login_errado
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_login_errado]    Script Date: 14/09/2026 12:12:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_login_errado](
	[datareferencia] [date] NOT NULL,
	[idrota] [int] NOT NULL,
	[UsuarioDA] [varchar](5) NULL,
	[NomeMotorista] [varchar](100) NOT NULL,
	[usr_cd_usuario] [int] NOT NULL,
	[usr_nm_usuario] [varchar](50) NOT NULL
) ON [PRIMARY]
GO
