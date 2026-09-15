-- ============================================================
-- BASELINE: dbo.tb_feriados
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_feriados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_feriados](
	[tfd_cd_feriado] [int] IDENTITY(1,1) NOT NULL,
	[tfd_nm_feriado] [varchar](300) NULL,
	[tfd_tipo_feriado] [varchar](30) NULL,
	[tfd_ds_descricao] [varchar](300) NULL,
	[tfd_ds_municipio] [varchar](150) NULL,
	[tfd_dh_feriado] [date] NOT NULL,
	[tfd_cd_cliente] [int] NULL,
	[tfd_in_ativo] [bit] NOT NULL,
	[tfd_in_excluido] [bit] NOT NULL,
	[tfd_ds_estado] [varchar](150) NULL,
 CONSTRAINT [pk_feriados] PRIMARY KEY CLUSTERED 
(
	[tfd_cd_feriado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
