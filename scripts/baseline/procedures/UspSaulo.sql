-- ============================================================
-- BASELINE: dbo.UspSaulo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSaulo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[UspSaulo]
(
	@json varchar(max)
)

as

declare @json2 varchar(max) ,
		@json3 varchar(max) 


select @json2 = value
from openjson(@json)
where [key] = 'data'

select @json3 = value
from openjson(@json2)
where [key] = 'list'

select *
from openjson(@json3)
WITH (
			status varchar(1000) '$.status',
			user_id varchar(1000) '$.user_id',
			ctime varchar(1000) '$.ctime',
			route_value_station_id1 varchar(1000) '$.route_value[0].station_id',
			route_value_station_id2 varchar(1000) '$.route_value[1].station_id',
			route_value_station_id3 varchar(1000) '$.route_value[2].station_id',
			order_path varchar(1000) '$.order_path[0]',
			operator_time varchar(1000) '$.operator_time',
			extern_visiable varchar(1000) '$.extern_visiable',
			station_id varchar(1000) '$.station_id',
			shipment_id varchar(1000) '$.shipment_id',
			content varchar(1000) '$.content',
			parent_id varchar(1000) '$.parent_id',
			tracking_type varchar(1000) '$.tracking_type',
			service_point_visible varchar(1000) '$.service_point_visible',
			order_status varchar(1000) '$.order_status',
			operator varchar(1000) '$.operator',
			intern_visible varchar(1000) '$.intern_visible',
			message varchar(1000) '$.message',
			id varchar(1000) '$.id',
			on_hold_reason varchar(1000) '$.on_hold_reason',
			website_visible varchar(1000) '$.website_visible'
		)
	cross apply openjson(content)
	with 
	(
    	content_assignment_task_id varchar(1000) '$.assignment_task_id',
    	content_driver_id varchar(1000) '$.driver_id',
    	content_driver_tob_id varchar(1000) '$.driver_tob_id',
    	content_is_home_delivery varchar(1000) '$.is_home_delivery',
    	content_order_service_id varchar(1000) '$.order_service_id',
    	content_recipient_name varchar(1000) '$.recipient_name',
    	content_recipient_relationship varchar(1000) '$.recipient_relationship',
    	content_recipient_type varchar(1000) '$.recipient_type',
    	content_remark varchar(1000) '$.remark',
    	content_reschedule_time_end varchar(1000) '$.reschedule_time_end',
    	content_reschedule_time_start varchar(1000) '$.reschedule_time_start',
    	content_signature varchar(1000) '$.signature',
    	content_station_id varchar(1000) '$.station_id'
	)
GO
