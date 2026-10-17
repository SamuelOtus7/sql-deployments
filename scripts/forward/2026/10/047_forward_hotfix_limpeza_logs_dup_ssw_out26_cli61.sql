/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : HOTFIX (sem task — saneamento de dados, continuidade do 046)
  Autor        : Devin
  Data         : 2026-10-17
  Descricao    : Limpeza do historico (tb_pag_espelhos_logs) dos espelhos de
                 outubro/2026 do cliente 61 liquidados via SSW (610 espelhos).
                 Corrige dados gerados pelo bug corrigido no script 046:

                 PASSO 1 — remove o log TARDIO "37->39 / Integracao SSW" gravado
                    pelo consumidor externo SSW DEPOIS da baixa (espelho ja em
                    40). Registro factualmente falso: naquele instante o espelho
                    nao estava em 37 nem transitou para 39. O evento real da
                    integracao permanece registrado em tb_pag_integracao_bancos.

                 PASSO 2 — remove os logs "status 40" excedentes (duplicata
                    gerada pelo backfill antigo da proc): mantem o PRIMEIRO log
                    com lsm_cd_status_atual = 40 por espelho e apaga os demais.

                 PASSO 3 — corrige lsm_cd_status_anterior do log de baixa
                    sobrevivente para refletir o ULTIMO status real do historico
                    (ex.: 1600987 passa de "39->40" para "37->40", pois a
                    transicao real para 39 nunca foi logada) — trilha continua.

                 Escopo: espelhos do cliente 61, periodos com inicio em
                 outubro/2026, com confirmacao SSW (tipo 1347, irisys 1299,
                 terceiro 1348). Linhas removidas sao preservadas na tabela de
                 backup dbo.bkp_espelhos_logs_dup_ssw_047.
  Rollback     : scripts/rollback/2026/10/047_rollback_hotfix_limpeza_logs_dup_ssw_out26_cli61.sql
  Objetos      : dados em dbo.tb_pag_espelhos_logs; cria dbo.bkp_espelhos_logs_dup_ssw_047
  Dependências : hotfix 046 (proc ja corrigida — nao recria os registros removidos)
  ============================================================================*/
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRAN;

/* --- Escopo: os 610 espelhos cliente 61 / out-2026 com liquidacao SSW --- */
IF OBJECT_ID('tempdb..#escopo') IS NOT NULL DROP TABLE #escopo;
SELECT DISTINCT ib.pib_cd_espelho AS espelho
INTO #escopo
FROM dbo.tb_pag_integracao_bancos ib
INNER JOIN dbo.tb_pag_espelhos pag ON pag.mtn_cd_motorista_nfs = ib.pib_cd_espelho
INNER JOIN dbo.tb_pgto_periodo per ON per.pgp_cd_periodo = pag.mtn_cd_pgto_periodo
WHERE ib.pib_ds_tipo_integracao = 1347
  AND ib.pib_cd_status_irisys   = 1299
  AND ib.pib_cd_status_terceiro = 1348
  AND pag.mtn_cod_cliente = 61
  AND pag.mtn_in_excluido = 0
  AND per.pgp_dt_inicio >= '2026-10-01'
  AND per.pgp_dt_inicio <  '2026-11-01';

DECLARE @qtd_escopo INT = (SELECT COUNT(*) FROM #escopo);
PRINT 'Espelhos no escopo: ' + CAST(@qtd_escopo AS VARCHAR(10));

/* --- PASSO 0 — backup de todas as linhas que serao removidas ou alteradas --- */
IF OBJECT_ID('dbo.bkp_espelhos_logs_dup_ssw_047') IS NOT NULL
    DROP TABLE dbo.bkp_espelhos_logs_dup_ssw_047;

SELECT l.*
INTO dbo.bkp_espelhos_logs_dup_ssw_047
FROM dbo.tb_pag_espelhos_logs l
WHERE l.lsm_cd_motorista_nfs IN (SELECT espelho FROM #escopo)
  AND (l.lsm_cd_status_atual = 40
       OR (l.lsm_cd_status_anterior = 37 AND l.lsm_cd_status_atual = 39
           AND l.lsm_ds_mensagem = 'Integração SSW'));

PRINT 'Linhas preservadas no backup: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

/* --- PASSO 1 — remove logs tardios "37->39 / Integracao SSW" posteriores a baixa --- */
DELETE l
FROM dbo.tb_pag_espelhos_logs l
WHERE l.lsm_cd_motorista_nfs IN (SELECT espelho FROM #escopo)
  AND l.lsm_cd_status_anterior = 37
  AND l.lsm_cd_status_atual = 39
  AND l.lsm_ds_mensagem = 'Integração SSW'
  AND l.lsm_dt_data_log > (
        SELECT MIN(l2.lsm_dt_data_log)
        FROM dbo.tb_pag_espelhos_logs l2
        WHERE l2.lsm_cd_motorista_nfs = l.lsm_cd_motorista_nfs
          AND l2.lsm_cd_status_atual = 40);

PRINT 'Logs tardios 37->39 removidos: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

/* --- PASSO 2 — remove logs "status 40" excedentes (mantem o primeiro por espelho) --- */
;WITH ranked AS (
    SELECT l.lsm_cd_log_status,
           ROW_NUMBER() OVER (
               PARTITION BY l.lsm_cd_motorista_nfs
               ORDER BY l.lsm_dt_data_log, l.lsm_cd_log_status) AS rn
    FROM dbo.tb_pag_espelhos_logs l
    WHERE l.lsm_cd_motorista_nfs IN (SELECT espelho FROM #escopo)
      AND l.lsm_cd_status_atual = 40)
DELETE l
FROM dbo.tb_pag_espelhos_logs l
INNER JOIN ranked r ON r.lsm_cd_log_status = l.lsm_cd_log_status
WHERE r.rn > 1;

PRINT 'Logs status-40 duplicados removidos: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

/* --- PASSO 3 — lsm_cd_status_anterior do log de baixa = ultimo status real --- */
UPDATE l
SET lsm_cd_status_anterior = prev.lsm_cd_status_atual
FROM dbo.tb_pag_espelhos_logs l
OUTER APPLY (
    SELECT TOP 1 p.lsm_cd_status_atual
    FROM dbo.tb_pag_espelhos_logs p
    WHERE p.lsm_cd_motorista_nfs = l.lsm_cd_motorista_nfs
      AND (p.lsm_dt_data_log < l.lsm_dt_data_log
           OR (p.lsm_dt_data_log = l.lsm_dt_data_log AND p.lsm_cd_log_status < l.lsm_cd_log_status))
    ORDER BY p.lsm_dt_data_log DESC, p.lsm_cd_log_status DESC) prev
WHERE l.lsm_cd_motorista_nfs IN (SELECT espelho FROM #escopo)
  AND l.lsm_cd_status_atual = 40
  AND l.lsm_ds_mensagem = 'Pagamento efetuado via integracao SSW'
  AND prev.lsm_cd_status_atual IS NOT NULL
  AND prev.lsm_cd_status_atual <> l.lsm_cd_status_anterior;

PRINT 'Logs de baixa com status_anterior corrigido: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

/* --- Pos-checks: zero duplicatas e zero log-39 posterior a baixa no escopo --- */
IF EXISTS (
    SELECT 1 FROM dbo.tb_pag_espelhos_logs l
    WHERE l.lsm_cd_motorista_nfs IN (SELECT espelho FROM #escopo)
      AND l.lsm_cd_status_atual = 40
    GROUP BY l.lsm_cd_motorista_nfs
    HAVING COUNT(*) > 1)
BEGIN
    RAISERROR('FALHA: ainda existem logs status-40 duplicados no escopo.', 16, 1);
    ROLLBACK TRAN; RETURN;
END

IF EXISTS (
    SELECT 1 FROM dbo.tb_pag_espelhos_logs l
    WHERE l.lsm_cd_motorista_nfs IN (SELECT espelho FROM #escopo)
      AND l.lsm_cd_status_atual = 39
      AND l.lsm_dt_data_log > (
            SELECT MIN(l2.lsm_dt_data_log) FROM dbo.tb_pag_espelhos_logs l2
            WHERE l2.lsm_cd_motorista_nfs = l.lsm_cd_motorista_nfs
              AND l2.lsm_cd_status_atual = 40))
BEGIN
    RAISERROR('FALHA: ainda existem logs 39 posteriores a baixa no escopo.', 16, 1);
    ROLLBACK TRAN; RETURN;
END

COMMIT TRAN;
PRINT 'OK — saneamento concluido. Backup em dbo.bkp_espelhos_logs_dup_ssw_047.';
