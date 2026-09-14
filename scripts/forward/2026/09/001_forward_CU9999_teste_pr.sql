/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-9999
  Autor        : Teste PR
  Data         : 2026-09-13
  Descrição    : Teste do fluxo de PR - criar view de teste
  Rollback     : scripts/rollback/2026/09/001_rollback_CU9999_teste_pr.sql
  Objetos      : vw_teste_pr
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_pr')
    BEGIN
        DROP VIEW dbo.vw_teste_pr;
    END

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    CREATE VIEW dbo.vw_teste_pr AS
    SELECT idrota, nomemotorista, DataReferencia
    FROM vw_rotas
    WHERE nomemotorista <> '';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_pr')
        THROW 50000, 'View vw_teste_pr nao foi criada', 1;

    PRINT 'SUCESSO: View vw_teste_pr criada com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    THROW;
END CATCH;
GO
