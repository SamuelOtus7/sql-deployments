/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-9999
  Autor        : Teste CI
  Data         : 2026-09-13
  Descrição    : Teste do GitHub Actions CI
  Rollback     : scripts/rollback/2026/09/002_rollback_CU9999_teste_ci.sql
  Objetos      : vw_teste_ci
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_ci')
    BEGIN
        DROP VIEW dbo.vw_teste_ci;
    END

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    CREATE VIEW dbo.vw_teste_ci AS
    SELECT idrota, nomemotorista, DataReferencia
    FROM vw_rotas
    WHERE nomemotorista <> '';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_ci')
        THROW 50000, 'View vw_teste_ci nao foi criada', 1;

    PRINT 'SUCESSO: View vw_teste_ci criada com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    THROW;
END CATCH;
GO
