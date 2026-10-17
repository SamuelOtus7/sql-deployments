# Audit Log — Bypasses e Exceções

> Log de auditoria de todas as ações que contornam o processo normal (bypass de validação, exceções aprovadas, etc).

---

## 2026-10-17 — HOTFIX (bypass de QAS — servidor inacessível)

- **Release:** r20261017-hotfix-pagamento-ssw-log-status-4d53f01
- **Branch:** sql/hotfix-pagamento-ssw-log-status (sem task ClickUp — correcao emergencial)
- **Objeto:** dbo.UspFinAtualizaPagamentoSSW (CREATE OR ALTER)
- **Motivo:** lsm_cd_status_anterior hardcoded em 39 quebrava a trilha de historico
  do espelho; backfill com guard "ultimo log <> 40" duplicava o log de baixa 39->40
  quando o consumidor SSW gravava log tardio 'Integracao SSW' fora de ordem
  (400+ espelhos com log 39->40 duplicado em out/2026).
- **Autorizado por:** usuario (chat) — "pode publicar direto em prod"
- **Dry-run QAS pulado:** sim — QAS (37.27.56.113:1483) inacessivel (timeout de conexao)
- **Backup criado:** sim (backups/prod/UspFinAtualizaPagamentoSSW_20261017.sql;
  definicao anterior completa tambem no script de rollback 046)
- **Smoke test:** pass — EXEC manual sem erro; espelho 1603722 manteve 2 logs-40
  (sem nova duplicata); 0 duplicatas de log 40 criadas nos ultimos 10 min
- **Status:** publicado em PROD FORA DO FLUXO PADRAO (bypass de QAS)

---

## 2026-10-17 — HOTFIX (bypass de QAS — servidor inacessível)

- **Release:** r20261017-hotfix-limpeza-logs-dup-ssw-cli61-cfd39e0
- **Branch:** sql/hotfix-pagamento-ssw-log-status (sem task ClickUp — correcao emergencial)
- **Objeto:** dados em dbo.tb_pag_espelhos_logs (saneamento; cria dbo.bkp_espelhos_logs_dup_ssw_047)
- **Motivo:** saneamento dos registros gerados pelo bug corrigido no hotfix 046 —
  escopo = 610 espelhos do cliente 61, periodos out/2026, liquidacao SSW
  (1347/1299/1348):
  (a) remove 444 logs tardios "37->39 / Integracao SSW" gravados pelo consumidor
      externo apos a baixa (registro falso — espelho ja estava em 40);
  (b) remove 468 logs status-40 excedentes (duplicatas do backfill antigo),
      mantendo o primeiro log-40 por espelho;
  (c) corrige lsm_cd_status_anterior do log de baixa sobrevivente para o ultimo
      status real do historico (ex.: 1600987 ficou "37->40" — trilha continua).
- **Autorizado por:** usuario (chat) — "aplique as correcoes em producao"
- **Dry-run QAS pulado:** sim — QAS (37.27.56.113:1483) inacessivel (timeout de conexao)
- **Backup criado:** sim — dbo.bkp_espelhos_logs_dup_ssw_047 (1.688 linhas
  preservadas antes da alteracao; rollback 047 restaura via IDENTITY_INSERT)
- **Pos-checks:** pass — 0 espelhos com log-40 duplicado no escopo; 0 logs-39
  posteriores a baixa; espelho 1600987 com trilha 35->37->40 continua
- **Status:** publicado em PROD FORA DO FLUXO PADRAO (bypass de QAS)

---

## 2026-09-14 18:21 — Bypass de Validação

- **Usuário:** tech-lead (role: tech-lead)
- **Objeto:** vw_feriados (VIEW)
- **Motivo:** View simples de feriados sem impacto financeiro ou logistico
- **Timestamp:** 2026-09-14 18:21:34 -03:00
- **Sistema:** validation-registry.ps1 bypass

---
