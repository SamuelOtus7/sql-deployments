/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-8888
  Autor        : Teste Release
  Data         : 2026-09-13
  Descrição    : Reverte a criacao da view vw_teste_release
  Forward ref  : scripts/forward/2026/09/003_forward_CU8888_teste_release.sql
  Objetos      : vw_teste_release
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_release')
    BEGIN
        PRINT 'AVISO: View vw_teste_release nao existe. Nada a reverter.';
    END
    ELSE
    BEGIN
        --==========================================================================
        -- 2. SCRIPT DE ROLLBACK
        --==========================================================================
        DROP VIEW dbo.vw_teste_release;

        --==========================================================================
        -- 3. POS-CHECKS
        --==========================================================================
        IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_release')
            THROW 50000, 'View vw_teste_release nao foi removida', 1;

        PRINT 'SUCESSO: View vw_teste_release removida. Rollback concluido.';
    END

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    THROW;
END CATCH;
GO
