/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak06qz3
  Autor        : Devin
  Data         : 2026-10-16
  Descrição    : Cria o job do SQL Agent "Irisys - Baixa Automatica SSW" que
                 executa dbo.UspFinAtualizaPagamentoSSW a cada 5 minutos,
                 baixando automaticamente os espelhos com pagamento liquidado
                 via SSW (status 39 -> 40).
                 O banco do step e resolvido em runtime: db_Irisys em PROD,
                 db_IrisysDev em QAS.
  Rollback     : scripts/rollback/2026/10/045_rollback_CU-86ak06qz3_job_baixa_automatica_ssw.sql
  Objetos      : Job SQL Agent "Irisys - Baixa Automatica SSW" (msdb)
  Dependências : dbo.UspFinAtualizaPagamentoSSW (db_Irisys / db_IrisysDev)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    DECLARE @DbName SYSNAME = N'db_Irisys';

    IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'db_Irisys')
       AND EXISTS (SELECT 1 FROM sys.databases WHERE name = N'db_IrisysDev')
        SET @DbName = N'db_IrisysDev';

    DECLARE @ProcCheck NVARCHAR(400) =
        N'IF OBJECT_ID(N''' + @DbName + N'.dbo.UspFinAtualizaPagamentoSSW'', N''P'') IS NULL
              THROW 50010, ''Procedure dbo.UspFinAtualizaPagamentoSSW nao existe no banco alvo.'', 1;';

    EXEC sys.sp_executesql @ProcCheck;

    IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Irisys - Baixa Automatica SSW')
    BEGIN
        PRINT 'Job Irisys - Baixa Automatica SSW ja existe — recriando.';
        EXEC msdb.dbo.sp_delete_job @job_name = N'Irisys - Baixa Automatica SSW';
    END;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    DECLARE @job_id binary(16);

    EXEC msdb.dbo.sp_add_job
        @job_name            = N'Irisys - Baixa Automatica SSW',
        @enabled             = 1,
        @description         = N'Baixa automatica de espelhos com pagamento liquidado via integracao SSW (dbo.UspFinAtualizaPagamentoSSW), a cada 5 minutos.',
        @category_name       = N'[Uncategorized (Local)]',
        @job_id              = @job_id OUTPUT;

    EXEC msdb.dbo.sp_add_jobstep
        @job_id              = @job_id,
        @step_name           = N'UspFinAtualizaPagamentoSSW',
        @subsystem           = N'TSQL',
        @database_name       = @DbName,
        @command             = N'EXEC dbo.UspFinAtualizaPagamentoSSW;',
        @retry_attempts      = 1,
        @retry_interval      = 2;

    EXEC msdb.dbo.sp_add_schedule
        @schedule_name       = N'SCH_Irisys_Baixa_SSW_5min',
        @enabled             = 1,
        @freq_type           = 4,        -- diario
        @freq_interval       = 1,
        @freq_subday_type    = 4,        -- minutos
        @freq_subday_interval = 5,       -- a cada 5 minutos
        @active_start_time   = 0;

    EXEC msdb.dbo.sp_attach_schedule
        @job_id        = @job_id,
        @schedule_name = N'SCH_Irisys_Baixa_SSW_5min';

    EXEC msdb.dbo.sp_add_jobserver
        @job_id      = @job_id,
        @server_name = N'(local)';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Irisys - Baixa Automatica SSW')
        THROW 50011, 'Job Irisys - Baixa Automatica SSW nao foi criado', 1;

    PRINT 'SUCESSO: Job Irisys - Baixa Automatica SSW criado (a cada 5 min) em ' + @DbName + '.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
