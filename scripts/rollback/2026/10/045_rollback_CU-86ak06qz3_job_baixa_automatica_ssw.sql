/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak06qz3
  Autor        : Devin
  Data         : 2026-10-16
  Descrição    : Remove o job do SQL Agent "Irisys - Baixa Automatica SSW" e o
                 schedule "SCH_Irisys_Baixa_SSW_5min" criados pelo forward 045.
  Forward ref  : scripts/forward/2026/10/045_forward_CU-86ak06qz3_job_baixa_automatica_ssw.sql
  Objetos      : Job SQL Agent "Irisys - Baixa Automatica SSW" (msdb),
                 schedule SCH_Irisys_Baixa_SSW_5min (msdb)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Irisys - Baixa Automatica SSW')
    BEGIN
        EXEC msdb.dbo.sp_delete_job @job_name = N'Irisys - Baixa Automatica SSW';
        PRINT 'SUCESSO: Job Irisys - Baixa Automatica SSW removido.';
    END
    ELSE
    BEGIN
        PRINT 'SUCESSO: Job Irisys - Baixa Automatica SSW nao existia (nada a fazer).';
    END;

    IF EXISTS (SELECT 1 FROM msdb.dbo.sysschedules WHERE name = N'SCH_Irisys_Baixa_SSW_5min')
    BEGIN
        EXEC msdb.dbo.sp_delete_schedule @schedule_name = N'SCH_Irisys_Baixa_SSW_5min';
        PRINT 'SUCESSO: Schedule SCH_Irisys_Baixa_SSW_5min removido.';
    END;

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
