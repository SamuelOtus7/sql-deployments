/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Reverte pln_ds_motivo_reprovacao para varchar(150).
                 Guarda: se já existir valor gravado com mais de 150 chars,
                 aborta com erro claro em vez de truncar silenciosamente.
  Forward ref  : scripts/forward/2026/10/007_forward_CU-86ahce8t4_amplia_coluna_log_nfse.sql
  Objetos      : dbo.tb_pag_espelhos_logs_nfse (coluna pln_ds_motivo_reprovacao)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

    IF EXISTS (
        SELECT 1
        FROM dbo.tb_pag_espelhos_logs_nfse
        WHERE LEN(pln_ds_motivo_reprovacao) > 150
    )
        THROW 50003, 'Existem motivos de reprovacao com mais de 150 chars; rollback truncaria dados.', 1;

    ALTER TABLE dbo.tb_pag_espelhos_logs_nfse
    ALTER COLUMN pln_ds_motivo_reprovacao varchar(150) NULL;

    PRINT 'SUCESSO: pln_ds_motivo_reprovacao revertida para varchar(150).';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
