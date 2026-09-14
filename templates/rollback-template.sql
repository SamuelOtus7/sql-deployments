/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-XXXXX
  Autor        : [seu nome]
  Data         : YYYY-MM-DD
  Descrição    : [reverte o que foi feito no forward correspondente]
  Forward ref  : scripts/forward/YYYY/MM/XXXX_forward_CU-XXXXX.sql
  Objetos      : [objetos revertidos: tables, views, procedures, etc.]
  ==============================================================================
  ATENÇÃO: Este script deve reverter EXATAMENTE o que o forward fez.
  - Se o forward criou uma tabela, este script deve DROPá-la (se seguro).
  - Se o forward alterou uma procedure, este script deve restaurar a versão
    anterior (manter a definição original como comentário no forward).
  - Se o forward inseriu dados, este script deve deletá-los.
  - Se o forward removeu dados, NÃO é possível restaurar via script —
    usar backup do banco.
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS (opcional)
    --==========================================================================
    -- Verificar se o objeto existe antes de reverter, etc.
    -- IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = '...') ...

    --==========================================================================
    -- 2. SCRIPT DE ROLLBACK
    --==========================================================================
    -- [seu código de reversão aqui]

    --==========================================================================
    -- 3. POS-CHECKS (opcional)
    --==========================================================================
    -- Verificar se o objeto foi revertido corretamente, etc.

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
