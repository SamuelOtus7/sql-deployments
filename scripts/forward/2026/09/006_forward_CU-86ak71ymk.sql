/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin
  Data         : 2026-09-16
  Descrição    : Cria o job do SQL Agent "JOB_Dash_Coleta_Refresh" que executa
                 dbo.sp_dash_coleta_refresh a cada 5 minutos, mantendo as
                 tabelas de apoio do dashboard de volume de coleta atualizadas.
                 Banco alvo dos objetos: db_Irisys_Json (o job roda em msdb e o
                 step aponta para db_Irisys_Json).
                 OBS: requer permissao de criacao de job no msdb. Se o usuario
                 executor nao tiver permissao, este script deve ser rodado por
                 um login com acesso (ex.: DBA) — os objetos do script 005 ja
                 funcionam sem o job (basta executar a proc manualmente).
  Rollback     : scripts/rollback/2026/09/006_rollback_CU-86ak71ymk.sql
  Objetos      : Job SQL Agent JOB_Dash_Coleta_Refresh (msdb)
  Dependências : dbo.sp_dash_coleta_refresh (criada no script 005)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'JOB_Dash_Coleta_Refresh')
    BEGIN
        PRINT 'Job JOB_Dash_Coleta_Refresh ja existe — recriando.';
        EXEC msdb.dbo.sp_delete_job @job_name = N'JOB_Dash_Coleta_Refresh';
    END;

    DECLARE @job_id binary(16);

    EXEC msdb.dbo.sp_add_job
        @job_name            = N'JOB_Dash_Coleta_Refresh',
        @enabled             = 1,
        @description         = N'Refresh incremental das tabelas de apoio do dashboard de volume de coleta (tb_dash_coleta_*) a cada 5 minutos.',
        @category_name       = N'Data Collector',
        @job_id              = @job_id OUTPUT;

    EXEC msdb.dbo.sp_add_jobstep
        @job_id              = @job_id,
        @step_name           = N'Refresh marts coleta',
        @subsystem           = N'TSQL',
        @database_name       = N'db_Irisys_Json',
        @command             = N'EXEC dbo.sp_dash_coleta_refresh;',
        @retry_attempts      = 1,
        @retry_interval      = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name       = N'SCH_Dash_Coleta_5min',
        @enabled             = 1,
        @freq_type           = 4,        -- diario
        @freq_interval       = 1,
        @freq_subday_type    = 4,        -- minutos
        @freq_subday_interval = 5,       -- a cada 5 minutos
        @active_start_time   = 0;

    EXEC msdb.dbo.sp_attach_schedule
        @job_id       = @job_id,
        @schedule_name = N'SCH_Dash_Coleta_5min';

    EXEC msdb.dbo.sp_add_jobserver
        @job_id    = @job_id,
        @server_name = N'(local)';

    /* POS-CHECK */
    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'JOB_Dash_Coleta_Refresh')
        THROW 50005, 'Job JOB_Dash_Coleta_Refresh nao foi criado', 1;

    PRINT 'SUCESSO: Job JOB_Dash_Coleta_Refresh criado (a cada 5 min).';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
