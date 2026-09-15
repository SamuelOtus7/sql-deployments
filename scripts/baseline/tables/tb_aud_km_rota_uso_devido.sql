-- ============================================================
-- BASELINE: dbo.tb_aud_km_rota_uso_devido
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_aud_km_rota_uso_devido]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_aud_km_rota_uso_devido](
	[akr_cd_aud_km_rota_uso_devido] [bigint] IDENTITY(1,1) NOT NULL,
	[akr_cd_cliente] [int] NOT NULL,
	[akr_id_rota] [bigint] NOT NULL,
	[akr_in_uso_devido] [bit] NOT NULL,
	[akr_cd_usuario_edicao] [int] NOT NULL,
	[akr_nm_usuario_edicao] [nvarchar](200) NOT NULL,
	[akr_dh_edicao] [datetime2](3) NOT NULL,
	[ValidFrom] [datetime2](3) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](3) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_tb_aud_km_rota_uso_devido] PRIMARY KEY CLUSTERED 
(
	[akr_cd_aud_km_rota_uso_devido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_tb_aud_km_rota_uso_devido_cliente_rota] UNIQUE NONCLUSTERED 
(
	[akr_cd_cliente] ASC,
	[akr_id_rota] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tb_aud_km_rota_uso_devido_hist])
)
GO
