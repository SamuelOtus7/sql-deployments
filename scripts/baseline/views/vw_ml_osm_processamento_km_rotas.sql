-- ============================================================
-- BASELINE: dbo.vw_ml_osm_processamento_km_rotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_osm_processamento_km_rotas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_ml_osm_processamento_km_rotas] as 
select 
	rota.IdRota
	,rota.ServiceCenter
	,CASE WHEN (rota.ServiceCenter <> rota.OrigemSaida and left(rota.OrigemSaida,1) in ('E','M')  and isnull(prm.prm_ds_valor,0) <> 1) or isnull(b.bss_espelho_xpt,0) = 1 THEN rota.OrigemSaida ELSE rota.ServiceCenter END OrigemSaida
	,kmRota.idRota as KmRotaId
from
    tb_ml_rotas as rota with(nolock)
	join tb_clientes as cli with(nolock) on rota.IdTransportadora = cli.cli_id_logistics and cli.cli_cd_codigo_cliente <> 7
	-- Inclusão do cruzamento
	left join tb_parametros as prm with(nolock) on cli.cli_cd_codigo_cliente = prm.prm_cod_cliente and prm.prm_nm_parametro = 'Service Center Padrão'
	join dbo.tb_bases b with (nolock) ON b.bss_ds_sigla = CASE WHEN (rota.ServiceCenter <> rota.OrigemSaida and left(rota.OrigemSaida,1) in ('E','M')  and isnull(prm.prm_ds_valor,0) <> 1) or isnull(b.bss_espelho_xpt,0) = 1 THEN rota.OrigemSaida ELSE rota.ServiceCenter END
											--CASE WHEN rota.ServiceCenter <> rota.OrigemSaida and left(rota.OrigemSaida,1) in ('E','M') THEN rota.OrigemSaida ELSE rota.ServiceCenter END
											AND b.bss_cd_idtransportadora = rota.IdTransportadora
											AND b.bss_in_excluido = 0
											and b.bss_dc_latitude <> 0
											and b.bss_dc_longitude <> 0
    left join tb_ml_processamento_km_rotas as kmRota with(nolock) on kmRota.idRota = rota.IdRota
 where
	rota.excluido = 0
	and StatusRota <> 'planned'
	and
		(
			(
				rota.DataReferencia between cast(dateadd(month,-6,getdate()) as date) and cast(dateadd(day,-1,getdate()) as date)
				and kmRota.idRota is null
			)
			or
			kmRota.processamento = 0
		)
	--and rota.IdRota = 375827012

union all

select 
	rota.IdRota
	,rota.OrigemSaida ServiceCenter
	,rota.OrigemSaida
	,kmRota.idRota as KmRotaId
from
    tb_ml_fm_rotas as rota with(nolock)
	join dbo.tb_bases b with (nolock) ON b.bss_ds_sigla = CASE WHEN rota.OrigemSaida <> rota.OrigemSaida and left(rota.OrigemSaida,1) in ('E','M') THEN rota.OrigemSaida ELSE rota.OrigemSaida END
											AND b.bss_cd_idtransportadora = rota.IdTransportadora
											AND b.bss_in_excluido = 0
											and b.bss_dc_latitude <> 0
											and b.bss_dc_longitude <> 0
    left join tb_ml_processamento_km_rotas as kmRota with(nolock) on kmRota.idRota = rota.IdRota
 where
	rota.excluido = 0
	--and StatusRota <> 'planned'
	and
		(
			(
				rota.DataReferencia between cast(dateadd(month,-6,getdate()) as date) and cast(dateadd(day,-1,getdate()) as date)
				and kmRota.idRota is null
			)
			or
			kmRota.processamento = 0
		)

GO
