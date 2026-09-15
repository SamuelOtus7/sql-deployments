-- ============================================================
-- BASELINE: dbo.Usp_spe2_carrega_pacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_spe2_carrega_pacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_spe2_carrega_pacotes]
as

declare @json varchar(max),
	    @at varchar(100)
select @json = (dac_ds_contexto_json),
	   @at = dac_ds_contexto
from db_Irisys_Json.dbo.tb_dra_coleta where dac_cd_coleta = 772692

select @at as at, 
	   *
from openjson(@json)
with (
		 shipment_id varchar(1000)'$.shipment_id',
		 order_type varchar(1000)'$.order_type',
		 sub_order_type varchar(1000)'$.sub_order_type',
		 on_hold_reason varchar(1000)'$.on_hold_reason',
		 status varchar(1000)'$.status',
		 pick_up_time varchar(1000)'$.pick_up_time',
		 buyer_addr_tag varchar(1000)'$.buyer_addr_tag',
		 zone_id varchar(1000)'$.zone_id',
		 zone_name varchar(1000)'$.zone_name',
		 reschedule_mark varchar(1000)'$.reschedule_mark',
		 on_hold_attempts varchar(1000)'$.on_hold_attempts',
		 on_hold_attempts_limit varchar(1000)'$.on_hold_attempts_limit',
		 assigned_time varchar(1000)'$.assigned_time',
		 sequence varchar(1000)'$.sequence',
		 self_collection varchar(1000)'$.self_collection',
		 delivery_window varchar(1000)'$.delivery_window',
		 journey_type varchar(1000)'$.journey_type',
		 on_hold_times varchar(1000)'$.on_hold_times'
	 )
GO
