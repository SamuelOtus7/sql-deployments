-- ============================================================
-- BASELINE: dbo.UspGeraColetaCidades_drop
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraColetaCidades_drop]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraColetaCidades_drop]
as

-------------IMPORTANTE ----------------------
/*este processo foi migrado para o UspGeraColetaCidadesDistanteDia */





-- declare @datainicio date = cast(getdate()-3 as date)
-- declare @datafim date = cast(getdate() as date)


-- drop table if exists #base1;
-- select 
-- 		a.CodigoRota
--         ,a.CodigoPacote
-- 		,a.latitude  as Latitude
-- 		,a.longitude as Longitude
-- 		,geography::Point(a.latitude,a.longitude,4326).STDistance(geography::Point(c.bss_dc_latitude,c.bss_dc_longitude,4326)) as distancia
		
-- 		into #base1

-- 	from tb_spe_pacotes_v5 as a with(nolock)

-- 	inner join tb_spe_rotas_v5 as b with(nolock)
-- 	on a.CodigoRota = b.CodigoRota
-- 	and a.DataReferencia = b.DataReferencia

-- 	inner join tb_bases as c  with(nolock)
-- 	on b.idtransportadora = c.bss_cd_idtransportadora
-- 	and b.NomeHub = c.bss_ds_nome

-- 	where a.DataReferencia between @datainicio and @datafim
-- 	and cast(bss_dc_longitude			as decimal(14,10)) between -90 and 90
-- 	and cast(a.latitude   as decimal(14,10)) between -90 and 90
-- 	and b.CidadeDistante is null
--     ;

-- 	update a 
-- 	set
-- 		a.CidadeDistante = 1
	
-- 	 --select 
-- 	 --a.Cidade ,a.cidadedistante
-- 	from tb_spe_pacotes_v5 as a
-- 	inner join 
-- 	(
-- 		select 
-- 			CodigoRota,
--             CodigoPacote,
-- 			Latitude,	
-- 			Longitude

-- 		from
-- 			(
-- 				select 
-- 				*
-- 				, row_number() over(partition by CodigoRota order by distancia desc) ordem
-- 				from #base1
-- 			) as a
-- 		where ordem <=4
-- 	) as b
-- 	on a.CodigoRota = b.CodigoRota 
--     and a.CodigoPacote = b.CodigoPacote
-- 	where a.excluido = 0;
	
-- insert into tb_dra_cidades_geo (
--     dcg_nr_latitude
-- 	,dcg_nr_longitude
-- 	,dcg_cidade_distante
-- )
-- select distinct 
-- 	   latitude,
-- 	   Longitude,
--        1 as dcg_cidade_distante


-- from tb_spe_pacotes_v5 as pacotes with(nolock)
-- 	left join tb_dra_cidades_geo as geo with(nolock)
-- 	 on cast(pacotes.Latitude	as decimal(14,10))  = geo.dcg_nr_latitude
-- 	and cast(pacotes.Longitude	as decimal(14,10))	= geo.dcg_nr_longitude
-- where 1=1
-- 	  and Latitude is not null
-- 	  and Longitude is not null
-- 	  and geo.dcg_cd_cidade_gei is null
-- 	  and datareferencia between @datainicio and @datafim
--       and pacotes.CidadeDistante = 1


-- GO
GO
