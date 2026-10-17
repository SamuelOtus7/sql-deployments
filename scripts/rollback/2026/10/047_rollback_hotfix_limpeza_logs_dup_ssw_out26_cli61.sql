/*==============================================================================
  ROLLBACK SCRIPT
  ==============================================================================
  Task ClickUp : HOTFIX (sem task — saneamento de dados, continuidade do 046)
  Autor        : Devin
  Data         : 2026-10-17
  Descricao    : Reverte o forward
                 scripts/forward/2026/10/047_forward_hotfix_limpeza_logs_dup_ssw_out26_cli61.sql

                 1) Reinsere em tb_pag_espelhos_logs as linhas removidas
                    (logs tardios 37->39 "Integracao SSW" e logs status-40
                    duplicados), recuperando-as de
                    dbo.bkp_espelhos_logs_dup_ssw_047 — IDENTITY_INSERT necessario
                    pois lsm_cd_log_status e IDENTITY.

                 2) Restaura lsm_cd_status_anterior original dos logs de baixa
                    que foram corrigidos pelo passo 3 do forward.

                 A tabela de backup NAO e removida neste script (auditoria).
  Pre-requisito: dbo.bkp_espelhos_logs_dup_ssw_047 existir (criada pelo forward).
  ============================================================================*/
SET XACT_ABORT ON;
SET NOCOUNT ON;

IF OBJECT_ID('dbo.bkp_espelhos_logs_dup_ssw_047') IS NULL
BEGIN
    RAISERROR('Tabela de backup dbo.bkp_espelhos_logs_dup_ssw_047 nao existe — rollback impossivel.', 16, 1);
    RETURN;
END

BEGIN TRAN;

/* --- 1) reinsere linhas removidas (presentes no backup, ausentes na tabela) --- */
SET IDENTITY_INSERT dbo.tb_pag_espelhos_logs ON;

INSERT INTO dbo.tb_pag_espelhos_logs
    (lsm_cd_log_status, lsm_cd_motorista_nfs, lsm_cd_status_anterior,
     lsm_cd_status_atual, lsm_dt_data_log, lsm_cd_usuario, lsm_ds_mensagem,
     lsm_nm_remetente, lsm_ds_status_notificacao, lsm_dh_notificacao_api_externa,
     lsm_ds_notificacao_api_externa_status)
SELECT b.lsm_cd_log_status, b.lsm_cd_motorista_nfs, b.lsm_cd_status_anterior,
       b.lsm_cd_status_atual, b.lsm_dt_data_log, b.lsm_cd_usuario, b.lsm_ds_mensagem,
       b.lsm_nm_remetente, b.lsm_ds_status_notificacao, b.lsm_dh_notificacao_api_externa,
       b.lsm_ds_notificacao_api_externa_status
FROM dbo.bkp_espelhos_logs_dup_ssw_047 b
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.tb_pag_espelhos_logs l
    WHERE l.lsm_cd_log_status = b.lsm_cd_log_status);

PRINT 'Linhas reinseridas: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

SET IDENTITY_INSERT dbo.tb_pag_espelhos_logs OFF;

/* --- 2) restaura lsm_cd_status_anterior original das linhas sobreviventes --- */
UPDATE l
SET lsm_cd_status_anterior = b.lsm_cd_status_anterior
FROM dbo.tb_pag_espelhos_logs l
INNER JOIN dbo.bkp_espelhos_logs_dup_ssw_047 b
    ON b.lsm_cd_log_status = l.lsm_cd_log_status
WHERE l.lsm_cd_status_anterior <> b.lsm_cd_status_anterior;

PRINT 'Status anterior restaurado em ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' logs.';

COMMIT TRAN;
PRINT 'Rollback concluido. Backup mantido em dbo.bkp_espelhos_logs_dup_ssw_047.';
