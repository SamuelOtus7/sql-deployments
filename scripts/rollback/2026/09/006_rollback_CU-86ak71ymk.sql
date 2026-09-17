/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin
  Data         : 2026-09-16
  Descrição    : Remove o job do SQL Agent "JOB_Dash_Coleta_Refresh" criado pelo
                 forward 006.
  Forward ref  : scripts/forward/2026/09/006_forward_CU-86ak71ymk.sql
  Objetos      : Job SQL Agent JOB_Dash_Coleta_Refresh (msdb)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'JOB_Dash_Coleta_Refresh')
    BEGIN
        EXEC msdb.dbo.sp_delete_job @job_name = N'JOB_Dash_Coleta_Refresh';
        PRINT 'SUCESSO: Job JOB_Dash_Coleta_Refresh removido.';
    END
    ELSE
    BEGIN
        PRINT 'SUCESSO: Job JOB_Dash_Coleta_Refresh nao existia (nada a fazer).';
    END;

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
