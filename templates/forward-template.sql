/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-XXXXX
  Autor        : [seu nome]
  Data         : YYYY-MM-DD
  Descrição    : [o que este script faz]
  Rollback     : scripts/rollback/YYYY/MM/XXXX_rollback_CU-XXXXX.sql
  Objetos      : [objetos criados/alterados: tables, views, procedures, etc.]
  Dependências : [objetos que dependem deste, se houver]
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS (opcional)
    --==========================================================================
    -- Verificar se o objeto já existe, se há dados, etc.
    -- IF EXISTS (SELECT 1 FROM sys.objects WHERE name = '...') ...

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    -- [seu código aqui]

    --==========================================================================
    -- 3. POS-CHECKS (opcional)
    --==========================================================================
    -- Verificar se o objeto foi criado, se os dados estão corretos, etc.
    -- IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = '...') ...

    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    -- Re-raise para que a aplicação capture
    THROW;
END CATCH;
GO
