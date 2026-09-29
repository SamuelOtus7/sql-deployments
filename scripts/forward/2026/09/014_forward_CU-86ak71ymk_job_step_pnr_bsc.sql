/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin (Samuel Nogueira)
  Data         : 2026-09-30
  Descrição    : Adiciona o step 'USPTrataStagingPNRBSC' ao SQL Agent job
                 'DriveAnalytics - Atualizações Looker' (a cada 4h a partir das
                 09:30), para que a staging dbo.tb_looker_pnr seja normalizada
                 diariamente em dbo.tb_pnr_bsc.
                 O step só é criado se o job existir no ambiente (QAS não possui
                 esse job — aplicação lá é no-op). Não altera steps existentes.
  Rollback     : scripts/rollback/2026/09/014_rollback_CU-86ak71ymk_job_step_pnr_bsc.sql
  Objetos      : msdb.dbo.sp_add_jobstep (job 'DriveAnalytics - Atualizações Looker')
  Dependências : dbo.USPTrataStagingPNRBSC (forward 013)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'DriveAnalytics - Atualizações Looker')
    BEGIN
        PRINT 'AVISO: job DriveAnalytics - Atualizações Looker nao existe neste ambiente. Nada a fazer.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USPTrataStagingPNRBSC') AND type = 'P')
        THROW 50001, 'PRE-CHECK FALHOU: dbo.USPTrataStagingPNRBSC nao existe. Aplique o forward 013 antes.', 1;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL (idempotente)
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1
        FROM msdb.dbo.sysjobs j
        JOIN msdb.dbo.sysjobsteps s ON s.job_id = j.job_id
        WHERE j.name = N'DriveAnalytics - Atualizações Looker'
          AND s.step_name = N'USPTrataStagingPNRBSC'
    )
    BEGIN
        EXEC msdb.dbo.sp_add_jobstep
              @job_name            = N'DriveAnalytics - Atualizações Looker'
            , @step_name           = N'USPTrataStagingPNRBSC'
            , @subsystem           = N'TSQL'
            , @database_name       = N'db_Irisys'
            , @command             = N'exec dbo.USPTrataStagingPNRBSC'
            , @on_success_action   = 1  -- último step: sai com sucesso
            , @on_fail_action      = 2  -- sai com falha (job registra erro)
            , @retry_attempts      = 0
            , @retry_interval      = 0;
    END

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1
        FROM msdb.dbo.sysjobs j
        JOIN msdb.dbo.sysjobsteps s ON s.job_id = j.job_id
        WHERE j.name = N'DriveAnalytics - Atualizações Looker'
          AND s.step_name = N'USPTrataStagingPNRBSC'
          AND s.command LIKE '%USPTrataStagingPNRBSC%'
    )
        THROW 50003, 'POS-CHECK FALHOU: step USPTrataStagingPNRBSC nao criado no job.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
