-- ============================================================
-- BASELINE: dbo.UspSPEGeraColetaCidadesDistanteDia_bkp_041125
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGeraColetaCidadesDistanteDia_bkp_041125]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure  [dbo].[UspSPEGeraColetaCidadesDistanteDia_bkp_041125] as 

declare @datainicio date = getdate() - 60
declare @datafim date = getdate() 


drop table if exists #base1;
select 
		a.CodigoRota
		--,CidadeDistante
        ,a.CodigoPacote
		--,dcg_ds_cidade as Cidade
		,a.Latitude  as Latitude
		,a.Longitude as Longitude
		,geography::Point(a.Latitude,a.Longitude,4326).STDistance(geography::Point(c.latitude,c.longitude,4326)) as distancia
		
		into #base1

	from tb_spe_pacotes_v5 as a with(nolock)

	inner join (
				select    CodigoRota ,datareferencia,idtransportadora,NomeHub,CidadeDistante,idstation
				from tb_spe_rotas_v5  with(nolock)
				where datareferencia  between @datainicio and @datafim and excluido = 0  
				and CidadeDistante is null
	) as b
	on a.CodigoRota = b.CodigoRota
	and a.DataReferencia = b.DataReferencia

	inner join tb_spe_station as c  with(nolock)
      on c.idstation = b.idstation

	--where a.DataReferencia >= '2024-06-01'
	where a.DataReferencia between @datainicio and @datafim
    --and a.CodigoRota in (select  distinct top 30 CodigoRota 
				--		from tb_ml_rotas 
				--		where datareferencia  between @datainicio and @datafim and excluido = 0 and  StatusRota <> 'planned' 
				--		and CidadeDistante is null
				--		)
	and  TRY_CAST(c.longitude			as decimal(14,10)) between -90 and 90
	and  TRY_CAST(a.Latitude   as decimal(14,10)) between -90 and 90
	--and b.StatusRota in ('close','return_to_station')
	and b.CidadeDistante is null
   -- and a.codigorota = 'TO20250330QQO7Q'
	AND TRY_CAST(a.Latitude AS decimal(14,10)) <> 0
--==========================================================================


    UPDATE a
    SET
        a.CidadeDistante = b.ordem
    FROM tb_spe_pacotes_v5 AS a WITH (ROWLOCK, READPAST, UPDLOCK)
    INNER JOIN
    (
        SELECT 
            CodigoRota,
            CodigoPacote,
            Latitude,
            Longitude,
            ordem
        FROM
        (
            SELECT 
                *,
                ROW_NUMBER() OVER (PARTITION BY CodigoRota ORDER BY distancia DESC) AS ordem
            FROM #base1
        ) AS a
        WHERE ordem <= 4
    ) AS b
    ON a.CodigoRota = b.CodigoRota 
    AND a.CodigoPacote = b.CodigoPacote
	and a.Longitude = b.longitude
	and a.Latitude = b.latitude
    WHERE a.excluido = 0




insert into tb_dra_cidades_geo (
    dcg_nr_latitude
,dcg_nr_longitude
,dcg_cidade_distante
)
select distinct 
	   Latitude,
	   Longitude,
       min(cidadedistante) as dcg_cidade_distante


from tb_spe_pacotes_v5 as pacotes with(nolock)
	left join tb_dra_cidades_geo as geo with(nolock)
	on pacotes.Latitude = geo.dcg_nr_latitude
	and pacotes.Longitude = geo.dcg_nr_longitude
where 1=1
and Latitude is not null
	  and Longitude is not null
	  and geo.dcg_cd_cidade_gei is null
	  and datareferencia between @datainicio and @datafim
      and pacotes.CidadeDistante >= 1
    --   and IdTransportadora = 643493085
group by Latitude,Longitude


	  exec UspSPEGeraAtualizaCidadesDistanteDiaPacote;
GO
