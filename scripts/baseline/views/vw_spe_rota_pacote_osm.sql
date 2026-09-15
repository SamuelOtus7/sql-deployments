-- ============================================================
-- BASELINE: dbo.vw_spe_rota_pacote_osm
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_rota_pacote_osm]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_spe_rota_pacote_osm] as

Select
        IdRota,
        DataHora,
        Latitude,
        Longitude,
		row_number() over(partition by idrota order by DataHora) as SequenciaParada,
		IdPacote
        -- lat,
        -- lon,
        -- distancia

from 
(
select 

	a.IdRota
	,a.IdTransportadora
	--,CidadeDistante
	,a.IdPacote
	,a.DataHora 
	,a.LatitudeEnderecoParada  Latitude
	,a.LongitudeEnderecoParada Longitude
    ,lag(a.LatitudeEnderecoParada) OVER (partition by idrota ORDER BY DataHora) lat
    ,lag(a.LongitudeEnderecoParada) OVER (partition by idrota  ORDER BY DataHora ) lon
	,geography::Point(a.LatitudeEnderecoParada
			,a.LongitudeEnderecoParada,4326).STDistance(geography::Point(isnull(lag(a.LatitudeEnderecoParada) OVER (partition by idrota ORDER BY DataHora),LatitudeEnderecoParada)
																,isnull(lag(a.LongitudeEnderecoParada) OVER (partition by idrota  ORDER BY DataHora ),LongitudeEnderecoParada),4326)) /1000  as distancia	
	
from
	(
		select  

			a.CodigoRota IdRota
			,a.IdTransportadora
			--,CidadeDistante
			,a.CodigoPacote IdPacote
			,a.DataHoraEntrega as DataHora
			,dcg_ds_cidade as Cidade
			,a.Latitude  LatitudeEnderecoParada 
			,a.Longitude   LongitudeEnderecoParada 
			
			-- into #base1

		from vw_pacotes_spe_v4 as a with(nolock)

		inner join vw_rotas_spe_v4 as b with(nolock)
		on a.CodigoRota = b.CodigoRota
		--and a.DataReferencia = b.DataReferencia

		left  join tb_bases as c  with(nolock)
		on b.idtransportadora = c.bss_cd_idtransportadora
		and b.NomeHub = c.bss_ds_nome

		left join [tb_dra_cidades_geo] as geo  with(nolock)
		on a.Latitude	= geo.dcg_nr_latitude
		and a.Longitude = geo.dcg_nr_longitude

		where a.DataReferencia >= '2024-06-01'
		and cast(geo.dcg_nr_latitude		as decimal(14,10)) between -90 and 90
		and cast(bss_dc_longitude			as decimal(14,10)) between -90 and 90
		--and cast(a.Latitude   as decimal(14,10)) between -90 and 90
		and StatusEntrega = 'Entregue'
		--and a.excluido = 0 
        and Latitude like '-%'
        and Longitude like '-%'
         --and ForaAreaEntrega = 0
		--and a.codigorota = 'AT202411285B1VM'

	) as a
) as final
where 1=1
and distancia <= 100 -- Corta pacotes fora da area de entregas
--and IdRota in(168088138)
--order by DataHora

/*
 select 
        rotas.IdRota,
        pacotes.DataHoraEntrega as DataHora,
        pacotes.LatitudeEnderecoParada as Latitude,
        pacotes.LongitudeEnderecoParada as Longitude,
        pacotes.SequenciaParada
    from tb_ml_rotas as rotas with(nolock)
      join tb_ml_pacotes as pacotes with(nolock)
      on rotas.IdRota = pacotes.IdRota
      and rotas.IdTransportadora = pacotes.IdTransportadora
      and rotas.DataReferencia = pacotes.DataReferencia
      and pacotes.SequenciaParada is not null 
    where  1=1
    --   and rotas.IdRota = 159725938
      and rotas.Excluido = 0
      and pacotes.Excluido = 0
      and pacotes.StatusEntrega = 'delivered'
    and cast(pacotes.LatitudeEnderecoParada		as decimal(14,10)) between -90 and 90
    and cast(pacotes.LongitudeEnderecoParada			as decimal(14,10)) between -90 and 90
    group by
        rotas.IdRota,
        pacotes.DataHoraEntrega,
        pacotes.LatitudeEnderecoParada,
        pacotes.LongitudeEnderecoParada,
        pacotes.SequenciaParada
    -- order by 5
    */


	--select * from [vw_ml_rota_pacote_osm] where idrota = 168088138
	
	/*

select
	IdRota		
	,DataHora 
	,Latitude	
	,Longitude	
	,row_number() over(partition by idrota order by distancia desc) as SequenciaParada

from (

	select
		IdRota	
		,DataHoraEntrega	
		,DataHoraEntrega as DataHora
		,Latitude	
		,Longitude	
		
		,distancia
		--,case when LAG(distancia) over (partition by idrota order by distancia desc) > 350 then 1 else 0 end  as corte
		,case when distancia > 150 then 1 else 0 end  as corte
	from 
	(
		select 
				a.IdRota
				--,CidadeDistante
				,a.IdPacote
				,a.DataHoraEntrega
				,dcg_ds_cidade as Cidade
				,a.LatitudeEnderecoParada  as Latitude
				,a.LongitudeEnderecoParada as Longitude
				,geography::Point(a.LatitudeEnderecoParada,a.LongitudeEnderecoParada,4326).STDistance(geography::Point(c.bss_dc_latitude,c.bss_dc_longitude,4326)) / 1000 as distancia
		
				-- into #base1

			from tb_ml_pacotes as a with(nolock)

			inner join tb_ml_rotas as b with(nolock)
			on a.IdRota = b.IdRota
			and a.DataReferencia = b.DataReferencia

			inner join tb_bases as c  with(nolock)
			on b.idtransportadora = c.bss_cd_idtransportadora
			and b.servicecenter = c.bss_ds_sigla

			left join [tb_dra_cidades_geo] as geo  with(nolock)
			on a.LatitudeEnderecoParada	= geo.dcg_nr_latitude
			and a.LongitudeEnderecoParada = geo.dcg_nr_longitude

			where a.DataReferencia >= '2024-06-01'
			--and a.IdRota = 159719925
			and cast(geo.dcg_nr_latitude		as decimal(14,10)) between -90 and 90
			and cast(bss_dc_longitude			as decimal(14,10)) between -90 and 90
			and cast(a.LatitudeEnderecoParada   as decimal(14,10)) between -90 and 90
		) as a
) as TabelaFinal

where corte = 0 
*/
GO
