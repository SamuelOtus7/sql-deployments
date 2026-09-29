/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin (Samuel Nogueira)
  Data         : 2026-09-30
  Descrição    : Remove o step 'USPTrataStagingPNRBSC' do SQL Agent job
                 'DriveAnalytics - Atualizações Looker'. A procedure e a tabela
                 permanecem (rollback delas é o script 013).
  Forward ref  : scripts/forward/2026/09/014_forward_CU-86ak71ymk_job_step_pnr_bsc.sql
  Objetos      : msdb.dbo.sp_delete_jobstep (job 'DriveAnalytics - Atualizações Looker')
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 2. SCRIPT DE ROLLBACK
    --==========================================================================
    IF EXISTS (
        SELECT 1
        FROM msdb.dbo.sysjobs j
        JOIN msdb.dbo.sysjobsteps s ON s.job_id = j.job_id
        WHERE j.name = N'DriveAnalytics - Atualizações Looker'
          AND s.step_name = N'USPTrataStagingPNRBSC'
    )
    BEGIN
        DECLARE @step_id INT;

        SELECT @step_id = s.step_id
        FROM msdb.dbo.sysjobs j
        JOIN msdb.dbo.sysjobsteps s ON s.job_id = j.job_id
        WHERE j.name = N'DriveAnalytics - Atualizações Looker'
          AND s.step_name = N'USPTrataStagingPNRBSC';

        EXEC msdb.dbo.sp_delete_jobstep
              @job_name = N'DriveAnalytics - Atualizações Looker'
            , @step_id  = @step_id;
    END

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (
        SELECT 1
        FROM msdb.dbo.sysjobs j
        JOIN msdb.dbo.sysjobsteps s ON s.job_id = j.job_id
        WHERE j.name = N'DriveAnalytics - Atualizações Looker'
          AND s.step_name = N'USPTrataStagingPNRBSC'
    )
        THROW 50004, 'POS-CHECK FALHOU: step USPTrataStagingPNRBSC ainda existe no job.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
