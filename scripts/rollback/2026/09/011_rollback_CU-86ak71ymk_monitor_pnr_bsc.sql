/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin (Samuel Nogueira)
  Data         : 2026-09-29
  Descrição    : Remove o registro do processo LOOKER_PNR de
                 dbo.tb_pbi_mon_processo, desfazendo o monitoramento da coleta
                 diária PNR BSC em vw_pbi_mon_alertas_processos.
  Forward ref  : scripts/forward/2026/09/011_forward_CU-86ak71ymk.sql
  Objetos      : DELETE em dbo.tb_pbi_mon_processo (processo_codigo LOOKER_PNR)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 2. SCRIPT DE ROLLBACK
    --==========================================================================
    DELETE FROM dbo.tb_pbi_mon_processo
    WHERE processo_codigo = 'LOOKER_PNR';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (
        SELECT 1 FROM dbo.tb_pbi_mon_processo
        WHERE processo_codigo = 'LOOKER_PNR'
    )
        THROW 50004, 'POS-CHECK FALHOU: processo LOOKER_PNR ainda existe.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
