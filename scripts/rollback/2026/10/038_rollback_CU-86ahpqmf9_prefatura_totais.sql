/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-08
  Descricao    : Reverte o forward 038 (CU-86ahpqmf9): remove a view
                 dbo.vw_fin_prefatura_totais e a tabela dbo.tb_fin_prefatura_totais
                 com todo o backfill. Nenhum objeto pre-existente e alterado,
                 portanto DROP e suficiente. Os dados removidos (totais impressos)
                 permanecem recuperaveis a partir de tb_fin_prefatura_upload
                 (dump original, nao tocado).
  Forward ref  : scripts/forward/2026/10/038_forward_CU-86ahpqmf9_prefatura_totais.sql
  Objetos      : dbo.vw_fin_prefatura_totais (DROP VIEW),
                 dbo.tb_fin_prefatura_totais (DROP TABLE)
  ==============================================================================
  ATENCAO: Este script reverte EXATAMENTE o que o forward fez.
  ==============================================================================*/

SET NOCOUNT ON;
GO

BEGIN TRY
    --==========================================================================
    -- 1. DROP VIEW (dependente primeiro)
    --==========================================================================
    IF EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_fin_prefatura_totais'))
    BEGIN
        DROP VIEW dbo.vw_fin_prefatura_totais;
        PRINT 'View dbo.vw_fin_prefatura_totais removida.';
    END

    --==========================================================================
    -- 2. DROP TABLE (remove estrutura + dados do backfill)
    --==========================================================================
    IF EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fin_prefatura_totais'))
    BEGIN
        DROP TABLE dbo.tb_fin_prefatura_totais;
        PRINT 'Tabela dbo.tb_fin_prefatura_totais removida.';
    END

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id IN (
        OBJECT_ID('dbo.vw_fin_prefatura_totais'),
        OBJECT_ID('dbo.tb_fin_prefatura_totais')))
        THROW 50020, 'Pos-check: objetos ainda existem apos rollback.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
