/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : HOTFIX (sem task — correcao emergencial de trilha de logs)
  Autor        : Devin
  Data         : 2026-10-17
  Descricao    : Corrige dbo.UspFinAtualizaPagamentoSSW — baixa automatica de
                 espelhos com pagamento liquidado via SSW (job "Irisys - Baixa
                 Automatica SSW", a cada 5 min):

                 1) LOG DE TELA COM STATUS ANTERIOR HARDCODED: o INSERT em
                    tb_pag_espelhos_logs gravava lsm_cd_status_anterior = 39
                    fixo (@StatusAguardando). Quando a transicao real para 39
                    nao foi logada (espelho chega a 39 silenciosamente via
                    consumidor SSW), a trilha fica quebrada — ex.: espelho
                    1603722 com log "39->40" sem nenhum log anterior "x->39".
                    Correcao: o UPDATE passa a capturar deleted.mtn_cd_status
                    via OUTPUT e o log usa o ULTIMO lsm_cd_status_atual real do
                    espelho (fallback = status real anterior do UPDATE),
                    mantendo a cadeia de historico continua.

                 2) BACKFILL REPROCESSA ESPELHO JA BAIXADO: o bloco de backfill
                    embutido na proc inseria "39->40" sempre que o ULTIMO log
                    <> 40. Como o consumidor SSW grava um log tardio "37->39 /
                    Integracao SSW" ~3h apos a baixa (espelho ja em 40), a
                    proxima execucao do job duplicava o log de baixa — 400+
                    espelhos com dois logs 39->40 identicos em out/2026.
                    Correcao: o guard passa de "ultimo log <> 40" para
                    NOT EXISTS (qualquer log com lsm_cd_status_atual = 40) —
                    espelho ja baixado NUNCA volta a gerar log de baixa.

                 OBS: a string 'Integração SSW' e o log tardio 37->39 sao
                 gravados pela aplicacao consumidora da fila SSW (fora do
                 banco — nenhum proc/trigger/job contem esse texto); este
                 script corrige o lado do banco (proc). A correcao do writer
                 externo fica a cargo do servico de integracao.
  Rollback     : scripts/rollback/2026/10/046_rollback_hotfix_pagamento_ssw_log_status.sql
  Objetos      : dbo.UspFinAtualizaPagamentoSSW (CREATE OR ALTER)
  Dependências : Job SQL Agent "Irisys - Baixa Automatica SSW" (executa a cada
                 5 min); consumidor externo SSW grava pib_cd_status_irisys/
                 pib_cd_status_terceiro/pib_dh_processamento.
  ==============================================================================

  ----------------------------------------------------------------------------
  DEFINICAO ANTERIOR (PROD, capturada em 2026-10-17 via OBJECT_DEFINITION)
  mantida para referencia/rollback:

  CREATE PROCEDURE dbo.UspFinAtualizaPagamentoSSW
      @CodCliente INT = NULL
  AS
  BEGIN
      SET NOCOUNT ON;
      SET XACT_ABORT ON;
      DECLARE @StatusAguardando  INT = 39;
      DECLARE @StatusPago        INT = 40;
      DECLARE @TipoSSW           INT = 1347;
      DECLARE @StatusFin         INT = 1299;
      DECLARE @StatusTerSucesso  INT = 1348;
      DECLARE @UsuarioIntegracao INT = 7;
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
      INSERT INTO dbo.tb_pag_integracao_log (log_dt, log_cd_espelho, log_mensagem)
      SELECT a.mtn_dh_modificacao, a.mtn_cd_motorista_nfs,
             'Status atualizado para Pagamento Efetuado via retorno SSW (1299/1348)'
      FROM @Atualizados a;
      INSERT INTO dbo.tb_pag_espelhos_logs (lsm_cd_motorista_nfs, lsm_cd_status_anterior,
          lsm_cd_status_atual, lsm_dt_data_log, lsm_cd_usuario, lsm_ds_mensagem, lsm_nm_remetente)
      SELECT a.mtn_cd_motorista_nfs, @StatusAguardando, @StatusPago,
             a.mtn_dh_modificacao, @UsuarioIntegracao,
             'Pagamento efetuado via integracao SSW', 'Irisys'
      FROM @Atualizados a;
      COMMIT TRAN;
  END;
  (seguido do bloco de backfill com guard "ultimo log <> 40" — versao completa
   no script de rollback correspondente)
  ============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspFinAtualizaPagamentoSSW'))
        THROW 50001, 'Procedure dbo.UspFinAtualizaPagamentoSSW nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_pag_espelhos'))
        THROW 50002, 'Tabela dbo.tb_pag_espelhos nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_pag_espelhos_logs'))
        THROW 50003, 'Tabela dbo.tb_pag_espelhos_logs nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_pag_integracao_bancos'))
        THROW 50004, 'Tabela dbo.tb_pag_integracao_bancos nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_pag_integracao_log'))
        THROW 50005, 'Tabela dbo.tb_pag_integracao_log nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT PRINCIPAL
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
        mtn_dh_modificacao   DATETIME NOT NULL,
        mtn_cd_status_ant    INT      NOT NULL   -- status real antes do UPDATE (deleted)
    );

    BEGIN TRAN;

    UPDATE pag
        SET pag.mtn_cd_status          = @StatusPago,
            pag.mtn_dh_modificacao     = GETDATE(),
            pag.mtn_cd_usr_modificacao = @UsuarioIntegracao
    OUTPUT inserted.mtn_cd_motorista_nfs, inserted.mtn_dh_modificacao,
           deleted.mtn_cd_status
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

    -- Log de alteracao de status exibido na tela de historico do espelho.
    -- lsm_cd_status_anterior = ultimo status REAL registrado no log do espelho
    -- (mantem a cadeia do historico continua). Se o espelho nunca teve log,
    -- usa o status real anterior capturado no UPDATE (deleted.mtn_cd_status).
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
           ISNULL(ultimo.lsm_cd_status_atual, a.mtn_cd_status_ant),
           @StatusPago,
           a.mtn_dh_modificacao,             -- mesma data/hora do UPDATE
           @UsuarioIntegracao,
           'Pagamento efetuado via integracao SSW',
           'Irisys'
    FROM @Atualizados a
    OUTER APPLY (
        SELECT TOP 1 el.lsm_cd_status_atual
        FROM dbo.tb_pag_espelhos_logs el
        WHERE el.lsm_cd_motorista_nfs = a.mtn_cd_motorista_nfs
        ORDER BY el.lsm_dt_data_log DESC, el.lsm_cd_log_status DESC
    ) ultimo;

    COMMIT TRAN;
END;

/* ------------------------------------------------------------------------------
   Backfill: registra em tb_pag_espelhos_logs a transicao -> 40 de espelhos que
   chegaram a Pagamento efetuado com liquidacao SSW confirmada (1347/1299/1348)
   SEM nenhum log de tela 40 (baixados por outro mecanismo).

   CORRECOES desta versao:
   - lsm_cd_status_anterior usa o ultimo status REAL do log do espelho
     (nao mais 39 fixo como anterior "presumido" quando ja houve baixa logada);
   - guard alterado de "ultimo log <> 40" para NOT EXISTS (qualquer log 40):
     espelho que JA tem log de baixa nunca e processado de novo — impede a
     duplicata gerada quando o consumidor SSW grava um log tardio fora de
     ordem (ex.: '37->39 / Integracao SSW' horas depois do espelho estar em 40).

   Idempotente: quem ja possui log 40 e ignorado; quem nao possui recebe um
   unico registro 40 na posicao mais recente da trilha.
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
       ISNULL(ultimo.lsm_cd_status_atual, 39),      -- ultimo status real do log (ou 39 se nunca houve log)
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
  AND NOT EXISTS (                                  -- espelho ja baixado (tem log 40) nao volta a ser processado
      SELECT 1
      FROM dbo.tb_pag_espelhos_logs el40
      WHERE el40.lsm_cd_motorista_nfs = pag.mtn_cd_motorista_nfs
        AND el40.lsm_cd_status_atual = 40)
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
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspFinAtualizaPagamentoSSW')) NOT LIKE '%deleted.mtn_cd_status%'
        THROW 50006, 'Capture do status anterior real (deleted.mtn_cd_status) nao encontrada na procedure.', 1;
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspFinAtualizaPagamentoSSW')) NOT LIKE '%NOT EXISTS%el40%lsm_cd_status_atual = 40%'
        THROW 50007, 'Guard NOT EXISTS (log 40) nao encontrado no backfill da procedure.', 1;

    PRINT 'SUCESSO: UspFinAtualizaPagamentoSSW corrigida — status anterior real no log + guard anti-duplicata no backfill.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
