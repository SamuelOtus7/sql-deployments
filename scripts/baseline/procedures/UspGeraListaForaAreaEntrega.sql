-- ============================================================
-- BASELINE: dbo.UspGeraListaForaAreaEntrega
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraListaForaAreaEntrega]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGeraListaForaAreaEntrega]
AS
BEGIN

drop table if exists #pacote
select distinct 
	IdTransportadora
	,idrota
	,Cidade

	into #pacote

from vw_pacotes 
where 1=1 
and idtransportadora = 2087146923
--and idrota = 181116629
and DataReferencia between cast(getdate()-5 as date) and cast(getdate() as date)

drop table if exists #app
select distinct 
	 p.DataReferencia 
	,p.IdTransportadora
	,p.Rota
	,geo.dcg_ds_cidade
	
	into #app

from
	tb_ml_gps_maps_app_resumo p with(nolock)
	join tb_dra_cidades_geo geo with(nolock) on cast( p.Latitude as varchar(15)) + replicate('0', 13-len(p.Latitude))  = cast(geo.dcg_nr_latitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_latitude as varchar(15))))
											and cast(  p.Longitude as varchar(15)) + replicate('0', 13-len(p.Longitude)) = cast(geo.dcg_nr_longitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_longitude as varchar(15))))
where 1=1
	and DataReferencia between cast(getdate()-5 as date) and cast(getdate() as date)
	and geo.dcg_ds_cidade is not null
	and p.idtransportadora = 2087146923
	--and rota = 181116629
	--and p.Cidade is null

drop table if exists #rotas_fora_area_entrega
select 
    a.idtransportadora
    ,a.datareferencia
    ,a.Rota
    ,a.dcg_ds_cidade as CidadeApp
    ,b.Cidade as AreaDeEntrega
    ,c.pontosAppRotasTotalKm
    ,c.pontosRotasPacotesKm
    ,c.pontosAppRotasTotalKm - c.pontosRotasPacotesKm as delta

into #rotas_fora_area_entrega

from #app as a

left join #pacote as b
on a.rota = b.idRota
and a.IdTransportadora = b.IdTransportadora
and a.dcg_ds_cidade = b.Cidade

inner join tb_ml_processamento_km_rotas as c
on a.rota = c.idrota

where 1=1 
and (c.pontosAppRotasTotalKm - c.pontosRotasPacotesKm ) > 50
and a.idtransportadora = 2087146923

--crie um meerge com a tabela abaixo
-- tb_ml_rotas_fora_area_entrega
-- #rotas_fora_area_entrega

merge tb_ml_rotas_fora_area_entrega as target
using #rotas_fora_area_entrega as source
on target.idtransportadora = source.idtransportadora
and target.datareferencia = source.datareferencia
and target.rota = source.rota
and target.CidadeApp = source.CidadeApp


when matched then
update set
	target.CidadeApp = source.CidadeApp
	,target.AreaDeEntrega = source.AreaDeEntrega
	,target.pontosAppRotasTotalKm = source.pontosAppRotasTotalKm
	,target.pontosRotasPacotesKm = source.pontosRotasPacotesKm
	,target.delta = source.delta

when not matched then
insert (idtransportadora, datareferencia, rota, CidadeApp, AreaDeEntrega, pontosAppRotasTotalKm, pontosRotasPacotesKm, delta)
values (source.idtransportadora, source.datareferencia, source.rota, source.CidadeApp, source.AreaDeEntrega, source.pontosAppRotasTotalKm, source.pontosRotasPacotesKm, source.delta);

end
GO
