-- ============================================================
-- BASELINE: dbo.UspSPEProcessaDadosKmOSM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEProcessaDadosKmOSM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSPEProcessaDadosKmOSM] as

declare @data date  = getdate()-2
declare @data_final date  = cast(getdate() as date)

-- select usr_cd_usuario,UsuarioDA ,NomeMotorista , codusuario.*

-- exec UspSPEAtualzaUsuarioDA @data ;

 drop table if exists #tabela_rotas 
select
	 IdTransportadora
	,CodigoRota
	,Data
	,isnull(KmApp,0) as KmApp

    ,isnull(KmPacotes,0) as KmPacotes
    

    ,case when UsouAPP = 'Sim' and isnull(KmApp,0) > 0
          then 'https://'+ dominio + '/public/mapa?idRota=' + cast(idRotaGuid as varchar(max)) 
          else null  end as LinkApp 

	,case when UsouAPP = 'Sim' and isnull(KmApp,0) > 0
          then 'https://'+ dominio + '/logistics/rotas/' + cast(CodigoRota as varchar(max)) + '?tab=mapa'
           else null  end as LinkAppInterno

	,UsouAPP
	-- ,UsuarioDA
	,case when UsouAPP  = 'Sim' and  ( idRotaGuid is null) then 'Em Apuração' else 'Apurado' end as Apuracao
	,QuantidadeApontamento 

	into #tabela_rotas

from (
select
	r.IdTransportadora,
	r.DataReferencia Data,
   kmrotas.idRotaGuid,
	r.CodigoRota,

    isnull(pontosRotasPacotesKm,0) as KmPacotes,

	case when app.CodigoRota is not null 
		and (app.QuantidadeApontamento > 20 )
		then isnull(pontosAppRotasTotalKm,KmColetado) else 0 end KmApp,

	case when app.CodigoRota is not null 
		and (app.QuantidadeApontamento > 20)
		then linkmapa else null end LinkApp,

	case when app.CodigoRota is not null and 
		(app.QuantidadeApontamento > 20 ) then 'Sim' else 'Não' end UsouAPP,

	-- codusuario.usr_cd_usuario  as UsuarioDA,
	app.QuantidadeApontamento,
   app.dominio

from
	tb_spe_rotas_v5 r with(nolock)

left join ( 
	select 
		cast(idRota	as varchar(50)) as idRota
        ,case when pontosAppRotasTotalKm > 0 then pontosAppRotasTotalKm else null end as pontosAppRotasTotalKm
        ,case when pontosRotasPacotesKm > 0 then pontosRotasPacotesKm else null end as pontosRotasPacotesKm
		,idRotaGuid
	from tb_spe_processamento_km_rotas with(nolock)
	where processamento = 1		
	--and pontosAppRotasTotalKm > 0
)as kmrotas 
on r.CodigoRota = kmrotas.idrota
		
left join (
			select
				r.CodigoRota,
				r.IdTransportadora,
				r.DataReferencia,
				rgp_cd_usuario,
				count(1) QuantidadeApontamento,
               cli_ds_sub_dominio as dominio
			from
			tb_spe_rotas_v5 r with(nolock)
			join tb_clientes as c with(nolock) on r.IdTransportadora = c.cli_id_logistics
			join (

				select 
					users.cli_cd_codigo_cliente as Transportadora,
					rgp_cd_usuario,
					users.usr_nm_usuario as Motorista,
					cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date) as Data
				from 
				tb_registro_gps as gps with(nolock)
				join tb_usuario as users with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario	

			) gps on c.cli_cd_codigo_cliente = gps.Transportadora 
			and r.UsuarioIrisys  = gps.rgp_cd_usuario
			and r.DataReferencia = gps.Data 

			where
				r.DataReferencia between @data and @data_final
				group by
				r.CodigoRota,
				r.IdTransportadora,
				r.DataReferencia,
				rgp_cd_usuario,
               cli_ds_sub_dominio

) app on r.IdTransportadora = app.IdTransportadora and r.DataReferencia = app.DataReferencia and r.CodigoRota = app.CodigoRota


where
	r.DataReferencia  between @data and @data_final
	--and app.QuantidadeApontamento > 20
) as base
;



update a
set
	 a.LinkAppInterno	= b.LinkAppInterno
	,a.KmApp	= b.KMapp
	,a.LinkMapaApp		= b.LinkApp
	,a.UsouAPP			= b.UsouAPP	
    ,a.KmPacotes		= b.KmPacotes		
	,a.Apuracao			= b.Apuracao	
	,a.QuantidadeApontamento = b.QuantidadeApontamento


from tb_spe_rotas_v5 as a with(nolock)

inner join #tabela_rotas as b with(nolock)
on a.datareferencia = b.data
and a.idtransportadora = b.idtransportadora
and a.CodigoRota = b.CodigoRota

where a.excluido = 0;

GO
