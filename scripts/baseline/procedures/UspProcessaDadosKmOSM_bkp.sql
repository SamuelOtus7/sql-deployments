-- ============================================================
-- BASELINE: dbo.UspProcessaDadosKmOSM_bkp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspProcessaDadosKmOSM_bkp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspProcessaDadosKmOSM_bkp] as

declare @data date  = getdate()-2 

-- select usr_cd_usuario,UsuarioDA ,NomeMotorista , codusuario.*

exec [UspAtualzaUsuarioDA] @data ;

 drop table if exists #tabela_rotas 
select
	 IdTransportadora
	,IdRota
	,Data
	,isnull(KmApp,0) as KmApp

    ,case when UsouAPP = 'Sim' and isnull(KmApp,0) > 0
           then 'https://'+ dominio + '/public/mapa?idRota=' + cast(idRotaGuid as varchar(max)) 
           else null  end as LinkApp 

  ,case when UsouAPP = 'Sim' and isnull(KmApp,0) > 0
           then 'https://'+ dominio + '/logistics/rotas/' + cast(IdRota as varchar(max)) + '?tab=mapa'
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
	r.idrota,

	case when app.IdRota is not null 
		and (app.QuantidadeApontamento > 20 )
		then isnull(pontosAppRotasTotalKm,KmColetado) else 0 end KmApp,

	case when app.IdRota is not null 
		and (app.QuantidadeApontamento > 20)
		then linkmapa else null end LinkApp,

	case when app.IdRota is not null and 
		(app.QuantidadeApontamento > 20 ) then 'Sim' else 'Não' end UsouAPP,

	-- codusuario.usr_cd_usuario  as UsuarioDA,
	app.QuantidadeApontamento,
    app.dominio

from
	vw_rotas r with(nolock)

left join ( 
	select 
		idRota	
		,pontosAppRotasTotalKm
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
				rgp_cd_usuario,
				count(1) QuantidadeApontamento,
                cli_ds_sub_dominio as dominio
			from
			tb_ml_rotas r with(nolock)
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
			and r.NomeMotorista  = gps.Motorista
			and r.DataReferencia = gps.Data 

			where
				r.DataReferencia between @data and cast(getdate() as date)
				group by
				r.IdRota,
				r.IdTransportadora,
				r.DataReferencia,
				rgp_cd_usuario,
                cli_ds_sub_dominio

) app on r.IdTransportadora = app.IdTransportadora and r.DataReferencia = app.DataReferencia and r.IdRota = app.IdRota


where
	r.DataReferencia between @data and cast(getdate() as date)
	--and app.QuantidadeApontamento > 20
) as base;


update a
set
	 a.LinkAppInterno	= b.LinkAppInterno
	,a.KmColetadoApp	= b.KMapp
	,a.LinkMapaApp		= b.LinkApp
	,a.UsouAPP			= b.UsouAPP		
	-- ,a.UsuarioDA		= b.UsuarioDA		
	,a.Apuracao			= b.Apuracao	
	,a.QuantidadeApontamento = b.QuantidadeApontamento


from tb_ml_rotas as a with(nolock)
inner join #tabela_rotas as b with(nolock)
on a.datareferencia = b.data
and a.idtransportadora = b.idtransportadora
and a.idrota = b.idrota

where a.excluido = 0;

GO
