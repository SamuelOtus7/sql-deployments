-- ============================================================
-- BASELINE: dbo.UspMLFMAtualizaKm
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLFMAtualizaKm]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLFMAtualizaKm]
as
begin

	SET NOCOUNT ON;

	drop table if exists #rotas
	select
		top 1000
		dac_cd_coleta
		,cast(dac_cd_transportadora as int) IdTransportadora
		,cast(dac_ds_contexto as int) IdRota
		,try_cast(replace(replace(dac_ds_contexto_json,'{"data":',''),'}','') as decimal(10,4)) km
		into #rotas
	from 
		db_Irisys_Json.dbo.tb_dra_coleta with(nolock) 
	where 
		dac_ds_tipo_coleta = 'ML_FM_ROUTE_KM_PERCORRIDO' 
		and dac_in_processado = 0
	order by 
		1 desc
	 

	update
		r
	set
		r.KmPercorrido = r2.km
	from
		tb_ml_fm_rotas r
		join #rotas r2 on r.IdRota = r2.IdRota 
						and r.IdTransportadora = r2.IdTransportadora 


	
	update
		c
	set
		c.dac_in_processado = 1
	from
		db_Irisys_Json.dbo.tb_dra_coleta c
		join #rotas r on c.dac_cd_coleta = r.dac_cd_coleta

	
end
GO
