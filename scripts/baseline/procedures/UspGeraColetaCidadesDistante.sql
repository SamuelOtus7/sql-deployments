-- ============================================================
-- BASELINE: dbo.UspGeraColetaCidadesDistante
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraColetaCidadesDistante]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraColetaCidadesDistante]
as

begin

	drop table if exists #base1
	select 
		a.IdRota
		--,CidadeDistante
		,dcg_ds_cidade as Cidade
		,a.LatitudeEnderecoParada  as Latitude
		,a.LongitudeEnderecoParada as Longitude
		,geography::Point(a.LatitudeEnderecoParada,a.LongitudeEnderecoParada,4326).STDistance(geography::Point(c.bss_dc_latitude,c.bss_dc_longitude,4326)) as distancia
		
		into #base1

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

	--inner join vw_ml_rota_pacote_osm as pacotevalido
	--on a.idrota = pacotevalido.idrota
	--and a.IdPacote = pacotevalido.IdPacote

	--where a.DataReferencia >= '2024-06-01'
	where a.DataReferencia >= dateadd(day,-7,cast(getdate() as date))
	and cast(geo.dcg_nr_latitude		as decimal(14,10)) between -90 and 90
	and cast(bss_dc_longitude			as decimal(14,10)) between -90 and 90
	and cast(a.LatitudeEnderecoParada   as decimal(14,10)) between -90 and 90
	and b.StatusRota in ('close','return_to_station')
	and PacotesNaoEntregue > 0;

	update a 
	set
		a.CidadeDistante = b.Cidade
	
	--select 
	--a.CidadeDistante , b.Cidade
	from tb_ml_rotas as a
	inner join 
	(
		select 
			IdRota,
			Latitude,	
			Longitude,
			Cidade

		from
			(
				select 
				*
				, row_number() over(partition by idrota order by distancia desc) ordem
				from #base1
			) as a
		where ordem = 1
	) as b
	on a.idrota = b.idrota 
	where a.excluido = 0
	and a.CidadeDistante <> b.Cidade;


--shopee

	drop table if exists #base2
	select 
		a.CodigoRota
		--,CidadeDistante
		,dcg_ds_cidade as Cidade
		,a.Latitude  as Latitude
		,a.Longitude as Longitude
		,geography::Point(ISNULL(a.Latitude,0),ISNULL(a.Longitude,0),4326).STDistance(geography::Point(c.bss_dc_latitude,c.bss_dc_longitude,4326)) as distancia
		
		into #base2

	from vw_pacotes_spe_v4 as a with(nolock)

	inner join vw_rotas_spe_v4 as b with(nolock)
	on a.codigorota = b.codigorota
	and a.DataReferencia = b.DataReferencia

	inner join tb_bases as c  with(nolock)
	on b.idtransportadora = c.bss_cd_idtransportadora
	and b.NomeHub = c.bss_ds_nome

	left join [tb_dra_cidades_geo] as geo  with(nolock)
	on a.Latitude	= geo.dcg_nr_latitude
	and a.Longitude = geo.dcg_nr_longitude

	where a.DataReferencia >= '2024-09-01'
	and cast(geo.dcg_nr_latitude		as decimal(14,10)) between -90 and 90
	and cast(bss_dc_longitude			as decimal(14,10)) between -90 and 90
    AND TRY_CAST(a.Latitude AS decimal(14,10)) BETWEEN -90 AND 90
    and dcg_ds_cidade is not null 
	and b.CidadeDistante is null
	and a.Latitude is not null
	and a.Longitude is not null;


	update a 
	set
		a.CidadeDistante = b.Cidade

	from tb_spe_rotas_v5 as a
	inner join 
	(
		select 
			codigorota,
			Latitude,	
			Longitude,
			Cidade

		from
			(
				select 
				*
				, row_number() over(partition by codigorota order by distancia desc) ordem
				from #base2
			) as a
		where ordem = 1
	) as b
	on a.codigorota = b.codigorota 
	where a.excluido = 0
	and a.CidadeDistante is null;


end

------select * from [tb_dra_cidades_geo]


--select dcg_ds_cidade,b.*

--from tb_spe_pacotes_v4 as a

--inner join tb_spe_rotas_v4 as b
--on a.codigorota = b.codigorota
--and a.DataReferencia = b.DataReferencia

--inner join tb_spe_station as c
--on b.idstation = c.idstation

--left join [tb_dra_cidades_geo] as geo
--on a.Latitude	= geo.dcg_nr_latitude
--and a.Longitude = geo.dcg_nr_longitude

--where 1=1 
----and a.DataReferencia = '2024-06-14'
--and a.IdTransportadora  = '20230008'
--and a.Latitude is not null
--and a.codigorota = 'AT2024061426U17'
--and dcg_ds_cidade is not NULL
GO
