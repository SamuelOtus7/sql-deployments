-- ============================================================
-- BASELINE: dbo.Usp_spe2_carrega_rotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_spe2_carrega_rotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_spe2_carrega_rotas]
as

declare @json varchar(max)
select @json = (dac_ds_contexto_json) from db_Irisys_Json.dbo.tb_dra_coleta where dac_cd_coleta = 772682

select *
from openjson(@json)
with (
		id varchar(1000)'$.id',
		assignment_task_id varchar(1000)'$.assignment_task_id',
		driver_id varchar(1000)'$.driver_id',
		shift_id varchar(1000)'$.shift_id',
		station_id varchar(1000)'$.station_id',
		order_count varchar(1000)'$.order_count',
		assigned_order_count varchar(1000)'$.assigned_order_count',
		operator_email varchar(1000)'$.operator_email',
		status varchar(1000)'$.status',
		zone_id varchar(1000)'$.zone_id',
		zone_auto_flag varchar(1000)'$.zone_auto_flag',
		delivery_time varchar(1000)'$.delivery_time',
		processing_time varchar(1000)'$.processing_time',
		processed_time varchar(1000)'$.processed_time',
		assigned_time varchar(1000)'$.assigned_time',
		partially_assigned_time varchar(1000)'$.partially_assigned_time',
		complete_time varchar(1000)'$.complete_time',
		at_type varchar(1000)'$.at_type',
		creator varchar(1000)'$.creator',
		vehicle_id varchar(1000)'$.vehicle_id',
		vehicle_name varchar(1000)'$.vehicle_name',
		extra varchar(1000)'$.extra',
		ctime varchar(1000)'$.ctime',
		mtime varchar(1000)'$.mtime',
		corridor_cage varchar(1000)'$.corridor_cage',
		agency varchar(1000)'$.agency',
		vehicle_type varchar(1000)'$.vehicle_type',
		ciot_number varchar(1000)'$.ciot_number',
		ciot_status varchar(1000)'$.ciot_status',
		ciot_msg varchar(1000)'$.ciot_msg',
		toll_value varchar(1000)'$.toll_value',
		journey_type varchar(1000)'$.journey_type',
		point_code varchar(1000)'$.point_code',
		order_point_info_dict varchar(1000)'$.order_point_info_dict',
		destination_sp_id varchar(1000)'$.destination_sp_id',
		destination varchar(1000)'$.destination',
		driver_station_id varchar(1000)'$.driver_station_id',
		driver_name varchar(1000)'$.driver_name',
		shift_name varchar(1000)'$.shift_name',
		shipment_id varchar(1000)'$.shipment_id',
		lowest_address_name varchar(1000)'$.lowest_address_name',
		sort_code_name varchar(1000)'$.sort_code_name',
		zone_name varchar(1000)'$.zone_name',
		station_name varchar(1000)'$.station_name',
		driver_station_name varchar(1000)'$.driver_station_name',
		route varchar(1000)'$.route',
		assign_driver_across_station varchar(1000)'$.assign_driver_across_station',
		recommend_at_type varchar(1000)'$.recommend_at_type',
		sp_id varchar(1000)'$.sp_id',
		is_xpt_at_flag varchar(1000)'$.is_xpt_at_flag'
	 )
GO
