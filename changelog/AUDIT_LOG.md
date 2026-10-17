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

## 2026-09-14 18:21 — Bypass de Validação

- **Usuário:** tech-lead (role: tech-lead)
- **Objeto:** vw_feriados (VIEW)
- **Motivo:** View simples de feriados sem impacto financeiro ou logistico
- **Timestamp:** 2026-09-14 18:21:34 -03:00
- **Sistema:** validation-registry.ps1 bypass

---
