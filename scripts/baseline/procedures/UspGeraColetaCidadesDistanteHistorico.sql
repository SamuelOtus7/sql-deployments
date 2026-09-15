-- ============================================================
-- BASELINE: dbo.UspGeraColetaCidadesDistanteHistorico
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraColetaCidadesDistanteHistorico]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraColetaCidadesDistanteHistorico]
as
begin


declare @datainicio date = cast(getdate()-2 as date)
declare @datafim date = cast(getdate()-1 as date)


drop table if exists #base1;
select 
		a.IdRota
		--,CidadeDistante
        ,a.IdPacote
        ,a.StatusEntrega
		--,dcg_ds_cidade as Cidade
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

	--where a.DataReferencia >= '2024-06-01'
	where 1=1
    and a.DataReferencia between @datainicio and @datafim
	and cast(bss_dc_longitude			as decimal(14,10)) between -90 and 90
	and cast(a.LatitudeEnderecoParada   as decimal(14,10)) between -90 and 90
    and b.PacotesNaoEntregue > 0 
    --and a.idtransportadora = 678279205
    -- and a.idrota = 214160052
    and b.Excluido = 0
	-- and b.StatusRota in ('close','return_to_station')
	-- and b.CidadeDistante is null


-- faca um update na tabela tb_ml_pacotes fazendo join com a tabela #base1 utilizando idrota e idpacote
-- e atualize a coluna CidadeDistante com null
update a
set a.CidadeDistante = null
-- select a.*
from tb_ml_pacotes as a
inner join #base1 as b
on a.IdRota = b.IdRota
and a.IdPacote = b.IdPacote


	update a 
	set
		a.CidadeDistante = ordem
	
	-- select 
	-- a.CidadeDistante , b.Cidade
	from tb_ml_pacotes as a
	inner join 
	(
		select 
			IdRota,
            idpacote,
			Latitude,	
			Longitude,
            ordem

		from
			(
				select 
				*
				, row_number() over(partition by idrota order by distancia desc) ordem
				from #base1
                where StatusEntrega = 'delivered'
			) as a
		where ordem <=4
	) as b
	on a.idrota = b.idrota 
    and a.IdPacote = b.idpacote
	where a.excluido = 0;



insert into tb_dra_cidades_geo (
    dcg_nr_latitude
,dcg_nr_longitude
,dcg_cidade_distante
)
select distinct 
	   LatitudeEnderecoParada,
	   LongitudeEnderecoParada,
       1 as dcg_cidade_distante


from tb_ml_pacotes as pacotes with(nolock)
	left join tb_dra_cidades_geo as geo with(nolock)
	on pacotes.LatitudeEnderecoParada = geo.dcg_nr_latitude
	and pacotes.LongitudeEnderecoParada = geo.dcg_nr_longitude
where 1=1
and LatitudeEnderecoParada is not null
	  and LongitudeEnderecoParada is not null
	  and geo.dcg_cd_cidade_gei is null
	  and datareferencia between @datainicio and @datafim
      and pacotes.CidadeDistante = 1


exec UspGeraAtualizaCidadesDistanteDiaPacoteHistorico

end
GO
