-- ============================================================
-- BASELINE: dbo.vw_monitoramento_workers
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_workers]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_monitoramento_workers]
as
select dac_cd_coleta as IdColeta,
	   cli.cli_ds_nome as Cliente,
	   dac_ds_contexto as TipoLogin,
	   dac_dh_coleta as DataHora,
	   json.*
from db_Irisys_Json.dbo.tb_dra_coleta as coletas
	inner join tb_clientes as cli 
	on coletas.dac_cd_transportadora = cli.cli_id_logistics or coletas.dac_cd_transportadora = cli.cli_id_shopee
	cross apply (
		SELECT 
			 case when type	 = 'ML_COLLECT_CARRIER_ID' then 'Mercado Livre' when type = 'SPE4_START' then 'Shopee' else 'Outro' end as TipoWorker
	        ,nextExecution as ProximaExecucao
	        ,lastExecutionStatus as StatusUltimaExecucao
	        ,lastExecutionDetails as DetalheUltimaExecucao
	        ,lastExecutionDate as DataHoraUltimaExecucao	
	        ,case when getNewSession ='true' then 'Sim' else 'Não' end as ColetarNovaSessao
	        FROM OPENJSON(dac_ds_contexto_json, '$.job') WITH (
			type NVARCHAR(100) '$.type',
			nextExecution DATETIME '$.worker.nextExecution',
			lastExecutionStatus NVARCHAR(10) '$.worker.lastExecution.status',
			lastExecutionDetails NVARCHAR(100) '$.worker.lastExecution.details',
			lastExecutionDate DATETIME '$.worker.lastExecution.dateExecuted',
			getNewSession BIT '$.worker.getNewSession',
			carrier NVARCHAR(100) '$.worker.carrier'
			--,carrier NVARCHAR(max) '$.data.stationList'
		)
	) as json
where dac_ds_tipo_coleta = 'WORKER_LOGIN'
and cast(dac_dh_coleta as date) = cast(getdate() as date)

GO
