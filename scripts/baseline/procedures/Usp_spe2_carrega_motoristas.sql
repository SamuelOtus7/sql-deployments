-- ============================================================
-- BASELINE: dbo.Usp_spe2_carrega_motoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_spe2_carrega_motoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_spe2_carrega_motoristas]
as

declare @json varchar(max),
	    @transportadora varchar(100)
select @json = (dac_ds_contexto_json),
	   @transportadora = dac_ds_contexto
from db_Irisys_Json.dbo.tb_dra_coleta where dac_cd_coleta = 772679

select @transportadora as transportadora, 
	   *
from openjson(@json)
with (
		 id varchar(1000)'$.id',
		driver_id varchar(1000)'$.driver_id',
		driver_name varchar(1000)'$.driver_name',
		driver_type varchar(1000)'$.driver_type',
		phone varchar(1000)'$.phone',
		license_type varchar(1000)'$.license_type',
		station_id varchar(1000)'$.station_id',
		status varchar(1000)'$.status',
		driver_vehicle_type varchar(1000)'$.driver_vehicle_type',
		contract_type varchar(1000)'$.contract_type',
		email varchar(1000)'$.email',
		agency varchar(1000)'$.agency',
		contract_type_id varchar(1000)'$.contract_type_id',
		gender varchar(1000)'$.staff_data.gender',
		driver_vehicle_type_name varchar(1000) '$.driver_vehicle_type_name',
		passport_id varchar(1000)'$.passport_id',
		cpf varchar(1000)'$.cpf',
		line_haul_station_id varchar(1000)'$.line_haul_station_id',
		last_login_time varchar(1000)'$.last_login_time',
		agency_id varchar(1000)'$.agency_id',
		formatted_birth_day varchar(1000)'$.formatted_birth_day'
	 )
GO
