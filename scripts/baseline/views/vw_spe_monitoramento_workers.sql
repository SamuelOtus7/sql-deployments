-- ============================================================
-- BASELINE: dbo.vw_spe_monitoramento_workers
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_monitoramento_workers]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  view [dbo].[vw_spe_monitoramento_workers]
as
select top 999999 clientes.cli_ds_nome as Transportadora,
	   hubs.suh_ds_usuario as Usuario,
	   hubs.suh_ds_station as Hub,
	   isnull(count(distinct rotas.Id),0) as RotasCarregadas,
	   isnull(exportacoes.exportacoes ,0)as Exportacoes,
	   isnull(exportacoes.rotas,0) as RotasExportadas,
	   isnull(exportacoes.UltimaExportacao,'1900-01-01') as UltimaExportacao
from tb_spe_usuarios_station as hubs with(nolock)
	join tb_clientes as clientes with(nolock)
	on hubs.suh_cd_transportadora = clientes.cli_id_shopee
	left join (
				select ser_carrier_id,
					   ser_station_id, 
					   count(distinct ser_data_exportacao) as exportacoes, 
					   count(*) as rotas,
					   max(ser_data_exportacao) as UltimaExportacao
				from tb_spe_export_rotas  with(nolock)
				where (
						ser_delivering_time >= cast(getdate() as date)
						or ser_delivered_time >= cast(getdate() as date)
					  	or ser_onhold_time >= cast(getdate() as date)
					  )
				group by ser_station_id, 
						 ser_carrier_id
			 ) as exportacoes
	on hubs.suh_cd_station = exportacoes.ser_station_id
	and hubs.suh_cd_transportadora = exportacoes.ser_carrier_id
	left join tb_spe_rotas as rotas with(nolock)
	on rotas.IdTransportadora = hubs.suh_cd_transportadora
	and rotas.IdStation = hubs.suh_cd_station
	and rotas.DataReferencia = cast(getdate() as date)
where suh_status = 1
group by clientes.cli_ds_nome,
	     hubs.suh_ds_usuario,
	     hubs.suh_ds_station,
		 exportacoes.exportacoes,
	     exportacoes.rotas,
		 exportacoes.UltimaExportacao
order by RotasCarregadas
GO
