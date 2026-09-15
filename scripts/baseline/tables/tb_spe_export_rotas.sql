-- ============================================================
-- BASELINE: dbo.tb_spe_export_rotas
-- Tipo: Table
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  Table [dbo].[tb_spe_export_rotas]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tb_spe_export_rotas](
	[ser_cd_export] [bigint] IDENTITY(1,1) NOT NULL,
	[ser_order_id] [nvarchar](255) NULL,
	[ser_carrier_id] [int] NULL,
	[ser_station_id] [int] NULL,
	[ser_data_exportacao] [datetime] NULL,
	[ser_sls_tracking_number] [nvarchar](255) NULL,
	[ser_shopee_order_sn] [nvarchar](255) NULL,
	[ser_longitude] [float] NULL,
	[ser_latitude] [float] NULL,
	[ser_sort_code_name] [nvarchar](255) NULL,
	[ser_zipcode_name] [int] NULL,
	[ser_buyer_name] [nvarchar](255) NULL,
	[ser_buyer_phone] [nvarchar](20) NULL,
	[ser_buyer_address] [nvarchar](255) NULL,
	[ser_location_type] [nvarchar](255) NULL,
	[ser_postal_code] [nvarchar](20) NULL,
	[ser_driver_id] [int] NULL,
	[ser_driver_name] [nvarchar](255) NULL,
	[ser_driver_phone] [nvarchar](20) NULL,
	[ser_lm_hub_receive_time] [datetime] NULL,
	[ser_delivering_time] [datetime] NULL,
	[ser_delivered_time] [datetime] NULL,
	[ser_onhold_time] [datetime] NULL,
	[ser_onhold_reason] [nvarchar](255) NULL,
	[ser_reschedule_date] [date] NULL,
	[ser_status] [nvarchar](255) NULL,
	[ser_reject_remark] [nvarchar](255) NULL,
	[ser_cod_amount] [int] NULL,
	[ser_is_sbs] [nvarchar](255) NULL,
	[ser_manifest_number] [nvarchar](255) NULL,
	[ser_order_account] [nvarchar](255) NULL,
	[ser_original_asf] [int] NULL,
	[ser_rounding_asf] [int] NULL,
	[ser_the_number_of_on_hold] [int] NULL,
	[ser_reschedule_time] [datetime] NULL,
	[ser_delivery_attempts] [int] NULL,
	[ser_bulky_type] [nvarchar](255) NULL,
	[ser_sla_target_date] [nvarchar](255) NULL,
	[ser_time_to_sla] [nvarchar](255) NULL,
	[ser_payment_method] [nvarchar](255) NULL,
	[ser_current_station] [nvarchar](255) NULL,
	[ser_shop_id] [bigint] NULL,
	[ser_shop_category] [nvarchar](255) NULL,
	[ser_inbound_3pl] [nvarchar](255) NULL,
	[ser_outbound_3pl] [nvarchar](255) NULL,
	[ser_channel] [nvarchar](255) NULL,
	[ser_3pl_tn] [nvarchar](255) NULL,
	[ser_destination_hub] [nvarchar](255) NULL,
	[ser_calculation_status] [nvarchar](255) NULL,
	[ser_dh_processamento] [datetime] NULL,
	[ser_in_processado] [bit] NULL,
	[ser_in_erro] [bit] NULL,
	[ser_dt_referencia] [date] NULL,
	[ser_gerado_pacote] [bit] NULL,
 CONSTRAINT [PK_tb_spe_export_rotas] PRIMARY KEY CLUSTERED 
(
	[ser_cd_export] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
