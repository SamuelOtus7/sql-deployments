/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-9999
  Autor        : Teste
  Data         : 2026-09-13
  Descrição    : Reverte a criacao da view vw_teste_lint
  Forward ref  : scripts/forward/2026/09/001_forward_CU9999_teste.sql
  Objetos      : vw_teste_lint
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_lint')
    BEGIN
        PRINT 'AVISO: View vw_teste_lint nao existe. Nada a reverter.';
    END
    ELSE
    BEGIN
        --==========================================================================
        -- 2. SCRIPT DE ROLLBACK
        --==========================================================================
        DROP VIEW dbo.vw_teste_lint;

        --==========================================================================
        -- 3. POS-CHECKS
        --==========================================================================
        IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_lint')
            THROW 50000, 'View vw_teste_lint nao foi removida', 1;

        PRINT 'SUCESSO: View vw_teste_lint removida. Rollback concluido.';
    END

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    THROW;
END CATCH;
GO
