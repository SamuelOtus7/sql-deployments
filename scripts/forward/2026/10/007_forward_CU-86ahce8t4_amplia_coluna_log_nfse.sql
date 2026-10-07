/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Amplia pln_ds_motivo_reprovacao de varchar(150) para
                 varchar(255), acompanhando o tamanho das mensagens
                 personalizadas. Operação de metadados (widening de varchar),
                 sem rewrite de dados.
  Rollback     : scripts/rollback/2026/10/007_rollback_CU-86ahce8t4_amplia_coluna_log_nfse.sql
  Objetos      : dbo.tb_pag_espelhos_logs_nfse (coluna pln_ds_motivo_reprovacao)
  Dependências : nenhuma
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    ALTER TABLE dbo.tb_pag_espelhos_logs_nfse
    ALTER COLUMN pln_ds_motivo_reprovacao varchar(255) NULL;

    IF NOT EXISTS (
        SELECT 1
        FROM sys.columns c
        JOIN sys.tables t ON t.object_id = c.object_id
        WHERE t.name = 'tb_pag_espelhos_logs_nfse'
          AND c.name = 'pln_ds_motivo_reprovacao'
          AND c.max_length = 255
    )
        THROW 50002, 'Coluna pln_ds_motivo_reprovacao nao foi ampliada para 255.', 1;

    PRINT 'SUCESSO: pln_ds_motivo_reprovacao ampliada para varchar(255).';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
