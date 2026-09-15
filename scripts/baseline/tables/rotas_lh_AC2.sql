-- ============================================================
-- BASELINE: dbo.rotas_lh_AC2
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[rotas_lh_AC2]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[rotas_lh_AC2](
	[id_rota] [int] NOT NULL,
	[rostering_id] [int] NOT NULL,
	[codigo_rota] [varchar](100) NOT NULL,
	[fecha_servicio] [date] NOT NULL,
	[id_transportadora] [int] NOT NULL,
	[tipo_vehiculo] [varchar](60) NULL,
	[id_conductor_1] [int] NULL,
	[nombre_conductor_1] [varchar](120) NULL,
	[id_conductor_2] [int] NULL,
	[nombre_conductor_2] [varchar](120) NULL,
	[vehiculo_tractor] [varchar](20) NULL,
	[vehiculo_carga_1] [varchar](20) NULL,
	[vehiculo_carga_2] [varchar](20) NULL,
	[tramo] [int] NULL,
	[origen] [varchar](60) NULL,
	[origen_eta] [datetime] NULL,
	[origen_ata] [datetime] NULL,
	[origen_fuente_ata] [varchar](60) NULL,
	[origen_etd] [datetime] NULL,
	[origen_atd] [datetime] NULL,
	[origen_fuente_atd] [varchar](60) NULL,
	[pre_checkin_origen] [datetime] NULL,
	[timezone_origen] [varchar](80) NULL,
	[destino] [varchar](60) NULL,
	[destino_eta] [datetime] NULL,
	[destino_ata] [datetime] NULL,
	[destino_atd] [datetime] NULL,
	[destino_etd] [datetime] NULL,
	[destino_fuente_ata] [varchar](60) NULL,
	[prevision_llegada] [datetime] NULL,
	[ultima_actualizacion] [datetime] NULL,
	[pre_checkin_destino] [datetime] NULL,
	[timezone_destino] [varchar](80) NULL,
	[tiempo_transito_estimado] [varchar](20) NULL,
	[tiempo_transito_real] [varchar](20) NULL,
	[hus] [int] NULL,
	[paquetes] [int] NULL,
	[ocupacion] [int] NULL,
	[estado] [varchar](30) NULL,
	[subestado] [varchar](30) NULL,
	[nota] [varchar](500) NULL,
	[motivo_cancelacion] [varchar](200) NULL,
	[causa_raiz_incidente] [varchar](200) NULL,
	[ots] [varchar](60) NULL,
	[otd] [varchar](60) NULL,
	[ota] [varchar](60) NULL,
	[otr] [varchar](60) NULL,
	[destino_fuente_atd] [varchar](60) NULL
) ON [PRIMARY]
GO
