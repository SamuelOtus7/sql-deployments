-- ============================================================
-- BASELINE: dbo.vw_monitoramento_shopee_v4
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_shopee_v4]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO



CREATE VIEW [dbo].[vw_monitoramento_shopee_v4]
as

select  

	t.cli_ds_nome Transportadora,  
	isnull(coleta_stations.QtdeColeta, 0) QtdeColetaStations,  
	isnull(coleta_stations.QtdeProcessado, 0) QtdeColetaStationsProcessado,  
	isnull(coleta_stations.QtdeProcessadoComErro, 0) QtdeColetaStationsProcessadoComErro,  
	coleta_stations.UltimaEscrita UltimaEscritaStations,  
	
	isnull(coleta_drivers.QtdeColeta, 0) QtdeColetaDrivers,  
	isnull(coleta_drivers.QtdeProcessado, 0) QtdeColetaDriversProcessado,  
	isnull(coleta_drivers.QtdeProcessadoComErro, 0) QtdeColetaDriversProcessadoComErro,  
	coleta_drivers.UltimaEscrita UltimaEscritaDrivers,

	isnull(coleta_routes.QtdeColeta, 0) QtdeColetaRoutes,  
	isnull(coleta_routes.QtdeProcessado, 0) QtdeColetaRoutesProcessado,  
	isnull(coleta_routes.QtdeProcessadoComErro, 0) QtdeColetaRoutesProcessadoComErro,  
	coleta_routes.UltimaEscrita UltimaEscritaRoutes,

	isnull(coleta_packages.QtdeColeta, 0) QtdeColetaPackages,  
	isnull(coleta_packages.QtdeProcessado, 0) QtdeColetaPackagesProcessado,  
	isnull(coleta_packages.QtdeProcessadoComErro, 0) QtdeColetaPackagesProcessadoComErro,  
	coleta_packages.UltimaEscrita UltimaEscritaPackages,

	isnull(coleta_details.QtdeColeta, 0) QtdeColetaDetails,  
	isnull(coleta_details.QtdeProcessado, 0) QtdeColetaDetailsProcessado,  
	isnull(coleta_details.QtdeProcessadoComErro, 0) QtdeColetaDetailsProcessadoComErro,  
	coleta_details.UltimaEscrita UltimaEscritaDetails,

	isnull(r.QtdeRotas, 0) QtdeRotasGeradas,  
	isnull(p.QtdePacotes, 0) QtdePacotesGerados

from  
	tb_clientes t with(nolock)  
	left join (  
		select  
			dac_cd_transportadora IdTransportadora,  
			count(1) QtdeColeta,  
			sum(cast(dac_in_processado as int)) QtdeProcessado,  
			sum(case when dac_in_processado = 1 and dac_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,  
			max(dac_dh_escrita) UltimaEscrita  
		from  
			db_Irisys_Json.dbo.tb_dra_coleta with(nolock)  
		where  
			dac_dh_escrita >= cast(getdate() as date)  
			and dac_ds_tipo_coleta = 'SPE4_STATIONS'
		group by  
			dac_cd_transportadora  
	) coleta_stations on t.cli_id_shopee = coleta_stations.IdTransportadora  
	left join (  
		select  
			dac_cd_transportadora IdTransportadora,  
			count(1) QtdeColeta,  
			sum(cast(dac_in_processado as int)) QtdeProcessado,  
			sum(case when dac_in_processado = 1 and dac_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,  
			max(dac_dh_escrita) UltimaEscrita  
		from  
			db_Irisys_Json.dbo.tb_dra_coleta with(nolock)  
		where  
			dac_dh_escrita >= cast(getdate() as date)  
			and dac_ds_tipo_coleta = 'SPE4_DRIVERS'
		group by  
			dac_cd_transportadora  
	) coleta_drivers on t.cli_id_shopee = coleta_drivers.IdTransportadora  
	left join (  
		select  
			dac_cd_transportadora IdTransportadora,  
			count(1) QtdeColeta,  
			sum(cast(dac_in_processado as int)) QtdeProcessado,  
			sum(case when dac_in_processado = 1 and dac_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,  
			max(dac_dh_escrita) UltimaEscrita  
		from  
			db_Irisys_Json.dbo.tb_dra_coleta with(nolock)  
		where  
			dac_dh_escrita >= cast(getdate() as date)  
			and dac_ds_tipo_coleta = 'SPE4_ROUTES'
		group by  
			dac_cd_transportadora  
	) coleta_routes on t.cli_id_shopee = coleta_routes.IdTransportadora   
	left join (  
		select  
			IdTransportadora,  
			count(1) QtdeRotas  
		from  
			tb_spe_rotas_v4 with(nolock)  
		where  
			DataReferencia = cast(getdate() as date)  
			and Excluido = 0  
		group by  
			IdTransportadora  
	) r on t.cli_id_shopee = r.IdTransportadora  
	left join (  
		select  
			dac_cd_transportadora IdTransportadora,  
			count(1) QtdeColeta,  
			sum(cast(dac_in_processado as int)) QtdeProcessado,  
			sum(case when dac_in_processado = 1 and dac_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,  
			max(dac_dh_escrita) UltimaEscrita  
		from  
			db_Irisys_Json.dbo.tb_dra_coleta with(nolock)  
		where  
			dac_dh_escrita >= cast(getdate() as date)  
			and dac_ds_tipo_coleta = 'SPE4_PACKAGES'
		group by  
			dac_cd_transportadora  
	) coleta_packages on t.cli_id_shopee = coleta_packages.IdTransportadora   
	left join (  
		select  
			dac_cd_transportadora IdTransportadora,  
			count(1) QtdeColeta,  
			sum(cast(dac_in_processado as int)) QtdeProcessado,  
			sum(case when dac_in_processado = 1 and dac_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,  
			max(dac_dh_escrita) UltimaEscrita  
		from  
			db_Irisys_Json.dbo.tb_dra_coleta with(nolock)  
		where  
			dac_dh_escrita >= cast(getdate() as date)  
			and dac_ds_tipo_coleta = 'SPE4_DETAILS'
		group by  
			dac_cd_transportadora  
	) coleta_details on t.cli_id_shopee = coleta_details.IdTransportadora   
	left join (  
		select  
			IdTransportadora,  
			count(1) QtdePacotes  
		from  
			tb_spe_pacotes_v4 with(nolock)  
		where  
			DataReferencia = cast(getdate() as date)  
			--and Excluido = 0  
		group by  
			IdTransportadora  
	) p on t.cli_id_shopee = p.IdTransportadora  

where  
	t.cli_nm_versao_spe = 4
	and t.cli_in_ativo = 1
    and cli_cd_codigo_cliente not in (34,38)


GO
