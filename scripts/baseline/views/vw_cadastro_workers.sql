-- ============================================================
-- BASELINE: dbo.vw_cadastro_workers
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_cadastro_workers]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_cadastro_workers]
as

--select * from vw_cadastro_workers where StationId = 5055
select dac_cd_coleta as IdColeta,
	   cli.cli_ds_nome as Cliente,
	   json.IdCliente,
	   dac_ds_contexto as TipoLogin,
	   dac_dh_coleta as DataHora,
	   json.IdWorker,
	   json.StatusWorker,
	   json.TipoWorker,
	   json.Usuario,
	   json.ProximaExecucao,
	   json.StatusUltimaExecucao,
	   json.DetalheUltimaExecucao,
	   json.DataHoraUltimaExecucao,
	   json.ColetarNovaSessao,
	   stations.Stationid,
	   stations.StationName,
	   stations.StatusStation
from db_Irisys_Json.dbo.tb_dra_coleta as coletas with(nolock)
	inner join tb_clientes as cli  with(nolock)
	on coletas.dac_cd_transportadora = cli.cli_id_logistics or coletas.dac_cd_transportadora = cli.cli_id_shopee
	cross apply (
		SELECT 
			 workerId as IdWorker
			,case when type	 = 'ML_COLLECT_CARRIER_ID' then 'Mercado Livre' when type = 'SPE4_START' then 'Shopee' else 'Outro' end as TipoWorker
	        ,nextExecution as ProximaExecucao
	        ,lastExecutionStatus as StatusUltimaExecucao
	        ,lastExecutionDetails as DetalheUltimaExecucao
	        ,lastExecutionDate as DataHoraUltimaExecucao	
	        ,case when getNewSession ='true' then 'Sim' else 'Não' end as ColetarNovaSessao
			,stationList
			,referenceId as IdCliente,
			username as Usuario,
			case when isEnabled = 'true' then 'Sim' else 'Não' end as StatusWorker
	        FROM OPENJSON(dac_ds_contexto_json, '$.job') WITH (
			type NVARCHAR(100) '$.type',
			workerId NVARCHAR(100) '$.worker._id',
			nextExecution DATETIME '$.worker.nextExecution',
			lastExecutionStatus NVARCHAR(10) '$.worker.lastExecution.status',
			lastExecutionDetails NVARCHAR(100) '$.worker.lastExecution.details',
			lastExecutionDate DATETIME '$.worker.lastExecution.dateExecuted',
			getNewSession BIT '$.worker.getNewSession',
			carrier NVARCHAR(100) '$.worker.carrier',
			referenceId NVARCHAR(100) '$.worker.referenceId',
			isEnabled NVARCHAR(10) '$.worker.isEnabled',
			userName NVARCHAR(100) '$.data.userName',
			stationList NVARCHAR(max) '$.worker.data.stationList' as json
		)
	) as json
	cross apply (
    SELECT 
        id AS Stationid,
        name as StationName,
		case when active = 'true' then 'Sim' else 'Não' end as StatusStation
    FROM OPENJSON(json.stationList) WITH (
        id INT '$.id',
        name NVARCHAR(255) '$.name',
		active NVARCHAR(10) '$.active'
    ) AS station
) as stations
	inner join (
		select IdWorker,
			   max(coletas.dac_cd_coleta) as UltimaColeta
		from db_Irisys_Json.dbo.tb_dra_coleta as coletas with(nolock)
		cross apply (
				SELECT 
					 workerId as IdWorker
					FROM OPENJSON(dac_ds_contexto_json, '$.job') WITH (
					workerId NVARCHAR(100) '$.worker._id'
				)
			) as json
		where dac_ds_tipo_coleta = 'WORKER_LOGIN'
		and cast(dac_dh_coleta as date) >= dateadd(day,-1,cast(getdate() as date))
		group by IdWorker
	) as UltimaColeta
	on coletas.dac_cd_coleta = UltimaColeta.UltimaColeta
where dac_ds_tipo_coleta = 'WORKER_LOGIN'
--and cast(dac_dh_coleta as date) = cast(getdate() as date)
and cast(dac_dh_coleta as date) >= dateadd(day,-1,cast(getdate() as date))
and json.StatusWorker = 'Sim'
and stations.StatusStation = 'Sim'



GO
