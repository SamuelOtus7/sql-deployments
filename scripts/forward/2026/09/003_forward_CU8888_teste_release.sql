/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-8888
  Autor        : Teste Release
  Data         : 2026-09-13
  Descrição    : Teste do gerador de chave de pesquisa
  Rollback     : scripts/rollback/2026/09/003_rollback_CU8888_teste_release.sql
  Objetos      : vw_teste_release
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_release')
    BEGIN
        DROP VIEW dbo.vw_teste_release;
    END

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    CREATE VIEW dbo.vw_teste_release AS
    SELECT idrota, nomemotorista, DataReferencia
    FROM vw_rotas
    WHERE nomemotorista <> '';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_teste_release')
        THROW 50000, 'View vw_teste_release nao foi criada', 1;

    PRINT 'SUCESSO: View vw_teste_release criada com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    THROW;
END CATCH;
GO
