-- ============================================================
-- BASELINE: dbo.UspProcessaDadosKmOSM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspProcessaDadosKmOSM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspProcessaDadosKmOSM] as




update b 
set IdKmProcessado = a.id
 
from [dbo].[tb_ml_processamento_km_rotas] as a
inner join tb_ml_rotas as b
on a.idrota  = b.idrota
 
where b.excluido = 0 
and b.statusrota <> 'planned'
and datareferencia >= cast(getdate()-15 as date)
and IdKmProcessado is null


declare @data date  = getdate()-30
declare @data_final date  = cast(getdate() as date)





drop table if exists #tabela_rotas 
select distinct 
	 IdTransportadora
	,IdRota
	,Data
	,isnull(KmApp,0) as KmApp
    ,isnull(KmPacotes,0) as KmPacotes
    ,'https://'+ cli_ds_sub_dominio + '/public/mapa?idRota=' + cast(idRotaGuid as varchar(max)) + '&typeProcessamento=getRotasPacotes' as LinkPacote

    ,'https://'+ cli_ds_sub_dominio + '/public/mapa?idRota=' + cast(idRotaGuid as varchar(max))  LinkApp 
    ,'https://'+ cli_ds_sub_dominio + '/logistics/rotas/' + cast(IdRota as varchar(max)) + '?tab=mapa' as LinkAppInterno

	,UsouAPP
	-- ,UsuarioDA
	,case when UsouAPP  = 'Sim' and  ( idRotaGuid is null) then 'Em Apuração' else 'Apurado' end as Apuracao
	,TeveAcaoGps 
	,TotalApontamentos as QuantidadeApontamento

	into #tabela_rotas

from (
select
	r.IdTransportadora,
	r.DataReferencia Data,
    kmrotas.idRotaGuid,
	r.idrota,

    COALESCE(pontosAppRotasTotalKm , 0) as KmApp,
    isnull(pontosRotasPacotesKm,0) as KmPacotes,
    linkmapa as LinkApp,

	case when (app.IdRota is not null and 
		app.TeveAcaoGps >= 1) or TotalApontamentos > 1  then 'Sim' else 'Não' end UsouAPP,

	-- codusuario.usr_cd_usuario  as UsuarioDA,
	app.TeveAcaoGps,
	geoapp.TotalApontamentos,
    app.dominio
	--,
	--Codigo_usuario_motorista

from
	tb_ml_rotas r with(nolock)

left join ( 
	select 
		idRota	
        ,case when pontosAppRotasTotalKm > 0 then pontosAppRotasTotalKm else null end as pontosAppRotasTotalKm
        ,case when pontosRotasPacotesKm > 0 then pontosRotasPacotesKm else null end as pontosRotasPacotesKm
		,idRotaGuid
	from tb_ml_processamento_km_rotas with(nolock)
	where processamento = 1		
	--and pontosAppRotasTotalKm > 0
)as kmrotas 
on r.idrota = kmrotas.idrota
		
left join (
			select
				r.IdRota,
				r.IdTransportadora,
				r.DataReferencia,
				usuarioirisys,
				count(1) TeveAcaoGps,
                cli_ds_sub_dominio as dominio
			from
			tb_ml_rotas r with(nolock)
			join tb_clientes as c with(nolock) on r.IdTransportadora = c.cli_id_logistics
			join (

SELECT * 
FROM (

    SELECT  
        users.cli_cd_codigo_cliente AS Transportadora,
        gps.Usuarioirisys,
        users.usr_nm_usuario AS Motorista,
		users.usr_cd_usuario as Codigo_usuario_motorista,

        CAST(DATEADD(hour, -3, gps.datahora) AS date) AS Data,

        ROW_NUMBER() OVER (PARTITION BY 
                            users.cli_cd_codigo_cliente, 
                            gps.Usuarioirisys, 
                            users.usr_nm_usuario, 
                            CAST(DATEADD(hour, -3, gps.datahora) AS date)
                          ORDER BY gps.datahora) AS RowNum
    FROM 
        vw_acao_gps AS gps WITH (NOLOCK)
    JOIN 
        tb_usuario AS users WITH (NOLOCK) ON gps.Usuarioirisys = users.usr_cd_usuario	
    WHERE 
        (gps.acao = 'Inicio' OR GPS.acao = 'Fim')
		and cli_cd_codigo_cliente <> 7
		--and users.usr_cd_usuario = 4447
		and CAST(DATEADD(hour, -3, gps.datahora) AS date)  between @data and @data_final

) AS Subquery
WHERE RowNum = 1

			) gps on c.cli_cd_codigo_cliente = gps.Transportadora 
			and r.NomeMotorista  = gps.Motorista
			and r.DataReferencia = gps.Data 

			where
				r.DataReferencia  between @data and @data_final
				group by
				r.IdRota,
				r.IdTransportadora,
				r.DataReferencia,
				usuarioirisys,
                cli_ds_sub_dominio

) app on r.IdTransportadora = app.IdTransportadora and r.DataReferencia = app.DataReferencia and r.IdRota = app.IdRota
left join
(
    select 
        CAST(rgp_dh_data_hora as date)  as data	
        ,rgp_cd_usuario 
        ,count(*) as TotalApontamentos
    from tb_registro_gps WITH (NOLOCK)
    where CAST(rgp_dh_data_hora as date) between @data and @data_final
    group by CAST(rgp_dh_data_hora as date) ,rgp_cd_usuario

) as geoapp
on r.datareferencia = geoapp.data
and r.usuarioda = geoapp.rgp_cd_usuario


where
	r.DataReferencia between @data and @data_final
    --and r.IdTransportadora in (2087146923)--
	and r.excluido = 0	
	--and app.QuantidadeApontamento > 20
) as base
join tb_clientes as domin with(nolock) on base.IdTransportadora = domin.cli_id_logistics

where cli_cd_codigo_cliente <> 7 
--and idrota  = 231594322

update a
set
	 a.LinkAppInterno	= b.LinkAppInterno
	,a.KmColetadoApp	= b.KMapp
	,a.LinkMapaApp		= b.LinkApp
	,a.UsouAPP			= b.UsouAPP	
	,a.TeveAcaoGps		= b.TeveAcaoGps
    ,a.KmMapaPacote     = b.KmPacotes
	-- ,a.UsuarioDA		= b.UsuarioDA		
	,a.Apuracao			= b.Apuracao	
	,a.QuantidadeApontamento = b.QuantidadeApontamento
    ,a.LinkPacote = b.LinkPacote

from tb_ml_rotas as a with(nolock)
inner join #tabela_rotas as b with(nolock)
on a.datareferencia = b.data
and a.idtransportadora = b.idtransportadora
and a.idrota = b.idrota

where a.excluido = 0;

GO
