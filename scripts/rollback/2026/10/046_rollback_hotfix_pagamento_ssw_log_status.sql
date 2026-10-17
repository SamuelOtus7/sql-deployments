/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : HOTFIX (sem task — correcao emergencial de trilha de logs)
  Autor        : Devin
  Data         : 2026-10-17
  Descricao    : Restaura dbo.UspFinAtualizaPagamentoSSW para a definicao
                 vigente em PROD capturada em 2026-10-17 via OBJECT_DEFINITION
                 (anterior ao hotfix): lsm_cd_status_anterior = 39 fixo no log
                 de baixa e backfill com guard "ultimo log <> 40".
  Forward ref  : scripts/forward/2026/10/046_forward_hotfix_pagamento_ssw_log_status.sql
  Objetos      : dbo.UspFinAtualizaPagamentoSSW (CREATE OR ALTER — versao anterior)
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspFinAtualizaPagamentoSSW'))
        THROW 50001, 'Procedure dbo.UspFinAtualizaPagamentoSSW nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT DE ROLLBACK — definicao original (PROD, 2026-10-17)
--============================================================================
CREATE OR ALTER PROCEDURE dbo.UspFinAtualizaPagamentoSSW
    @CodCliente INT = NULL   -- NULL = todas as transportadoras que usam SSW
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StatusAguardando  INT = 39;
    DECLARE @StatusPago        INT = 40;
    DECLARE @TipoSSW           INT = 1347;
    DECLARE @StatusFin         INT = 1299;
    DECLARE @StatusTerSucesso  INT = 1348;
    DECLARE @UsuarioIntegracao INT = 7;    -- Integracoes Irisys (existente em tb_usuario)

    DECLARE @Atualizados TABLE (
        mtn_cd_motorista_nfs INT      NOT NULL,
        mtn_dh_modificacao   DATETIME NOT NULL
    );

    BEGIN TRAN;

    UPDATE pag
        SET pag.mtn_cd_status          = @StatusPago,
            pag.mtn_dh_modificacao     = GETDATE(),
            pag.mtn_cd_usr_modificacao = @UsuarioIntegracao
    OUTPUT inserted.mtn_cd_motorista_nfs, inserted.mtn_dh_modificacao
        INTO @Atualizados
    FROM dbo.tb_pag_espelhos AS pag
    INNER JOIN dbo.tb_pag_integracao_bancos AS ib
        ON ib.pib_cd_espelho = pag.mtn_cd_motorista_nfs
       AND ib.pib_ds_tipo_integracao = @TipoSSW
    WHERE pag.mtn_in_excluido = 0
      AND pag.mtn_cd_status = @StatusAguardando
      AND ib.pib_cd_status_irisys = @StatusFin
      AND ib.pib_cd_status_terceiro = @StatusTerSucesso
      AND (@CodCliente IS NULL OR pag.mtn_cod_cliente = @CodCliente);

    -- Log tecnico da integracao (comportamento ja existente, mantido)
    INSERT INTO dbo.tb_pag_integracao_log (log_dt, log_cd_espelho, log_mensagem)
    SELECT a.mtn_dh_modificacao,
           a.mtn_cd_motorista_nfs,
           'Status atualizado para Pagamento Efetuado via retorno SSW (1299/1348)'
    FROM @Atualizados a;

    -- Log de alteracao de status exibido na tela de historico do espelho
    INSERT INTO dbo.tb_pag_espelhos_logs (
        lsm_cd_motorista_nfs,
        lsm_cd_status_anterior,
        lsm_cd_status_atual,
        lsm_dt_data_log,
        lsm_cd_usuario,
        lsm_ds_mensagem,
        lsm_nm_remetente
    )
    SELECT a.mtn_cd_motorista_nfs,
           @StatusAguardando,
           @StatusPago,
           a.mtn_dh_modificacao,             -- mesma data/hora do UPDATE
           @UsuarioIntegracao,
           'Pagamento efetuado via integracao SSW',
           'Irisys'
    FROM @Atualizados a;

    COMMIT TRAN;
END;

/* ------------------------------------------------------------------------------
   2) Backfill universal: registra em tb_pag_espelhos_logs a transicao 39 -> 40
      de todo espelho em status 40, nao excluido, com liquidacao SSW confirmada
      (1347/1299/1348), cujo ULTIMO log de tela nao seja 40.

      Cobre os dois cenarios:
      - QAS: espelhos baixados pela procedure (rastro exato em
        tb_pag_integracao_log — a data do log tecnico e usada como data da
        transicao);
      - PRD: espelhos baixados por outro mecanismo sem nenhum rastro de log —
        usa mtn_dh_modificacao (momento em que o espelho chegou ao estado
        atual) como data e mtn_cd_usr_modificacao como autor, preservando a
        atribuicao real (ex.: baixas manuais em lote). Se o modificador nao
        existir em tb_usuario (FK lsm_cd_usuario), cai para usr 7.

      Idempotente: so insere quando o ultimo log do espelho e <> 40 (ou
      inexistente); apos a insercao o ultimo log passa a ser 40 e novas
      execucoes nao geram duplicatas.
   ------------------------------------------------------------------------------ */
INSERT INTO dbo.tb_pag_espelhos_logs (
    lsm_cd_motorista_nfs,
    lsm_cd_status_anterior,
    lsm_cd_status_atual,
    lsm_dt_data_log,
    lsm_cd_usuario,
    lsm_ds_mensagem,
    lsm_nm_remetente
)
SELECT pag.mtn_cd_motorista_nfs,
       ISNULL(ultimo.lsm_cd_status_atual, 39),      -- status anterior real (ou 39 se nunca houve log)
       40,                                          -- Pagamento efetuado
       CASE WHEN ISNULL(lt.log_dt, pag.mtn_dh_modificacao) > ISNULL(ultimo.lsm_dt_data_log, '19000101')
            THEN ISNULL(lt.log_dt, pag.mtn_dh_modificacao)
            ELSE DATEADD(ms, 1, ultimo.lsm_dt_data_log) END,  -- desempate: sempre o registro mais recente na tela
       ISNULL(usr.usr_cd_usuario, 7),               -- autor real ou Integracoes Irisys
       'Pagamento efetuado via integracao SSW',
       CASE WHEN ISNULL(usr.usr_cd_usuario, 7) = 7 THEN 'Irisys'
            ELSE usr.usr_nm_usuario END
FROM dbo.tb_pag_espelhos pag
LEFT JOIN dbo.tb_usuario usr
    ON usr.usr_cd_usuario = pag.mtn_cd_usr_modificacao
OUTER APPLY (
    SELECT TOP 1 l.log_dt
    FROM dbo.tb_pag_integracao_log l
    WHERE l.log_cd_espelho = pag.mtn_cd_motorista_nfs
      AND l.log_mensagem LIKE '%Pagamento Efetuado via retorno SSW%'
    ORDER BY l.log_dt DESC                          -- liquidacao mais recente
) lt
OUTER APPLY (
    SELECT TOP 1 el.lsm_cd_status_atual, el.lsm_dt_data_log
    FROM dbo.tb_pag_espelhos_logs el
    WHERE el.lsm_cd_motorista_nfs = pag.mtn_cd_motorista_nfs
    ORDER BY el.lsm_dt_data_log DESC, el.lsm_cd_log_status DESC
) ultimo
WHERE pag.mtn_cd_status = 40
  AND pag.mtn_in_excluido = 0
  AND ISNULL(ultimo.lsm_cd_status_atual, -1) <> 40   -- ultimo log de tela nao e 40
  AND EXISTS (
      SELECT 1
      FROM dbo.tb_pag_integracao_bancos ib
      WHERE ib.pib_cd_espelho = pag.mtn_cd_motorista_nfs
        AND ib.pib_ds_tipo_integracao = 1347         -- SSW
        AND ib.pib_cd_status_irisys = 1299           -- Finalizado
        AND ib.pib_cd_status_terceiro = 1348);       -- Sucesso
GO

--============================================================================
-- 3. POS-CHECKS
--============================================================================
BEGIN TRY
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspFinAtualizaPagamentoSSW')) LIKE '%deleted.mtn_cd_status%'
        THROW 50006, 'Rollback incompleto: ainda contem capture de deleted.mtn_cd_status.', 1;
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspFinAtualizaPagamentoSSW')) NOT LIKE '%ISNULL(ultimo.lsm_cd_status_atual, -1) <> 40%'
        THROW 50007, 'Rollback incompleto: guard original do backfill nao restaurado.', 1;

    PRINT 'SUCESSO: Rollback executado — UspFinAtualizaPagamentoSSW restaurada para a versao anterior.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
