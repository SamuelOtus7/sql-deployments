/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ak71ymk
  Autor        : Devin (Samuel Nogueira)
  Data         : 2026-09-30
  Descrição    : Remove os objetos de coleta/tratamento do PNR BSC publicados pelo
                 forward 013: procedure USPTrataStagingPNRBSC, tabela tb_pnr_bsc,
                 índice ix_tb_looker_pnr_cliente_extracao e o parâmetro
                 'Habilitar PNR BSC' (cliente 61, Financeiro - Pagamentos).
                 ATENÇÃO: DROP TABLE em tb_pnr_bsc descarta os dados tratados.
  Forward ref  : scripts/forward/2026/09/013_forward_CU-86ak71ymk_pnr_bsc_objetos.sql
  Objetos      : DROP PROCEDURE dbo.USPTrataStagingPNRBSC,
                 DROP TABLE dbo.tb_pnr_bsc,
                 DROP INDEX ix_tb_looker_pnr_cliente_extracao,
                 DELETE dbo.tb_parametros ('Habilitar PNR BSC', cliente 61)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 2. SCRIPT DE ROLLBACK
    --==========================================================================

    -- 2.1 Remove gate primeiro para a coleta parar de processar
    DELETE FROM dbo.tb_parametros
    WHERE prm_cod_cliente  = 61
      AND prm_nm_parametro = N'Habilitar PNR BSC'
      AND prm_ds_categoria = N'Financeiro - Pagamentos';

    -- 2.2 Procedure de tratamento
    IF OBJECT_ID(N'dbo.USPTrataStagingPNRBSC', N'P') IS NOT NULL
        DROP PROCEDURE dbo.USPTrataStagingPNRBSC;

    -- 2.3 Tabela tratada (descarta dados normalizados)
    IF OBJECT_ID(N'dbo.tb_pnr_bsc', N'U') IS NOT NULL
        DROP TABLE dbo.tb_pnr_bsc;

    -- 2.4 Índice de apoio na staging
    IF EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.tb_looker_pnr')
          AND name = N'ix_tb_looker_pnr_cliente_extracao'
    )
        DROP INDEX ix_tb_looker_pnr_cliente_extracao ON dbo.tb_looker_pnr;

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF OBJECT_ID('dbo.USPTrataStagingPNRBSC', 'P') IS NOT NULL
        THROW 50004, 'POS-CHECK FALHOU: USPTrataStagingPNRBSC ainda existe.', 1;

    IF OBJECT_ID('dbo.tb_pnr_bsc', 'U') IS NOT NULL
        THROW 50005, 'POS-CHECK FALHOU: tb_pnr_bsc ainda existe.', 1;

    IF EXISTS (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID('dbo.tb_looker_pnr')
          AND name = 'ix_tb_looker_pnr_cliente_extracao'
    )
        THROW 50006, 'POS-CHECK FALHOU: indice ix_tb_looker_pnr_cliente_extracao ainda existe.', 1;

    IF EXISTS (
        SELECT 1 FROM dbo.tb_parametros
        WHERE prm_cod_cliente = 61
          AND prm_nm_parametro = N'Habilitar PNR BSC'
          AND prm_ds_categoria = N'Financeiro - Pagamentos'
          AND ISNULL(prm_in_excluido, 0) = 0
    )
        THROW 50007, 'POS-CHECK FALHOU: parametro Habilitar PNR BSC (cliente 61) ainda existe.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
