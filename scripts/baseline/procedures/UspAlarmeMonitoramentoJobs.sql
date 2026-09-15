-- ============================================================
-- BASELINE: dbo.UspAlarmeMonitoramentoJobs
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAlarmeMonitoramentoJobs]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspAlarmeMonitoramentoJobs]
as
begin


insert into tb_par_monitoramento_jobs 
select name as NomeJobs, 
	   -1 as TempoMaximoSemSucesso,
	   '' as Mensagem,
	   0 as Ativo
from msdb.dbo.sysjobs as jobs
	left join tb_par_monitoramento_jobs  as parametros
	on jobs.name = parametros.NomeJob
where name like '%DriveAnalytics%'
	  and parametros.NomeJob is null
	  and jobs.enabled = 1
	  and jobs.name <> 'DriveAnalytics - Alarme Monitoramento Jobs'

DECLARE @JobName varchar(200)
DECLARE @TempoMaximo smallint
DECLARE @Mensagem VARCHAR(250)
DECLARE @MinutosUltimaExecucao smallint

DECLARE db_cursor CURSOR FOR 
select NomeJob, TempoMaximoSemSucesso,Mensagem 
from tb_par_monitoramento_jobs
where ativo = 1

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @JobName, @TempoMaximo, @Mensagem

WHILE @@FETCH_STATUS = 0  
BEGIN  
      
	  select @MinutosUltimaExecucao = datediff(minute,msdb.dbo.agent_datetime(run_date, run_time),getdate())
		from (
			select top 1 run_date, run_time
			From msdb.dbo.sysjobs j 
			INNER JOIN msdb.dbo.sysjobhistory h 
			 ON j.job_id = h.job_id 
			where j.name = 'DriveAnalytics - Carrega Rotas' 
				  and run_status = 1
			order by 1 desc, 2 desc
		) as base

	if(@MinutosUltimaExecucao > @TempoMaximo)
	begin
		exec Usp_SendSlackMessage @Mensagem
	end

      FETCH NEXT FROM db_cursor INTO @JobName, @TempoMaximo, @Mensagem
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 

end
GO
