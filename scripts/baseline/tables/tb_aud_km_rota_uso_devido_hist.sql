-- ============================================================
-- BASELINE: dbo.tb_aud_km_rota_uso_devido_hist
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_aud_km_rota_uso_devido_hist]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_aud_km_rota_uso_devido_hist](
	[akr_cd_aud_km_rota_uso_devido] [bigint] NOT NULL,
	[akr_cd_cliente] [int] NOT NULL,
	[akr_id_rota] [bigint] NOT NULL,
	[akr_in_uso_devido] [bit] NOT NULL,
	[akr_cd_usuario_edicao] [int] NOT NULL,
	[akr_nm_usuario_edicao] [nvarchar](200) NOT NULL,
	[akr_dh_edicao] [datetime2](3) NOT NULL,
	[ValidFrom] [datetime2](3) NOT NULL,
	[ValidTo] [datetime2](3) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
/****** Object:  Index [ix_tb_aud_km_rota_uso_devido_hist]    Script Date: 14/09/2026 12:12:48 ******/
CREATE CLUSTERED INDEX [ix_tb_aud_km_rota_uso_devido_hist] ON [dbo].[tb_aud_km_rota_uso_devido_hist]
(
	[ValidTo] ASC,
	[ValidFrom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
