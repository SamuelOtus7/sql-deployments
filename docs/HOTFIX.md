<# Hotfix — Fluxo Acelerado para Incidentes em Produção

> Use quando houver um incidente em produção que exige correção imediata.
> O hotfix tem fluxo acelerado: backup obrigatório, validação mínima, deploy rápido.

## Quando usar

- Bug em produção causando impacto financeiro ou operacional
- Erro em procedure/view quebrando relatórios ou integrações
- Correção urgente que não pode esperar o fluxo completo

## Quando NAO usar

- Melhorias ou novas funcionalidades (use o fluxo normal)
- Alterações em dados (use script DML com backup)
- Mudanças estruturais grandes (use o fluxo normal com RBAC + validação completa)

## Fluxo do Hotfix

```
1. Dev: "Hotfix CU-XXXXX" no chat
2. Agente cria branch sql/hotfix-<slug>
3. Dev escreve forward + rollback (pre-commit valida par + lint)
4. Commit + push (sem PR obrigatorio - merge direto na main)
5. Validacao IA acelerada:
   a. impact-analysis.ps1 (Camada 1 - OBRIGATORIO)
   b. code-review.ps1 (Camada 2 - OBRIGATORIO)
   c. Dry-run QAS (Camada 3 - PULAR em emergencia critica)
   d. Validacao de negocio (Camada 4 - PULAR em hotfix)
6. Backup PROD (OBRIGATORIO - sem backup, sem deploy)
7. Confirmar publicação em PROD? (sim/nao)
8. Aplicar no PROD via mssql-prod.execute_ddl
9. Smoke test pós-deploy
10. Se falhar: rollback automatico
11. Registrar tag hotfix + changelog + audit log
12. Notificar stakeholders
```

## Diferencas do fluxo normal

| Etapa | Fluxo normal | Hotfix |
|-------|-------------|--------|
| Branch | sql/CU-task-slug | sql/hotfix-slug |
| PR | Obrigatorio | Opcional (merge direto) |
| Dry-run QAS | Obrigatorio | Pular em emergencia critica |
| Validacao negocio | Obrigatorio | Pular |
| Backup PROD | Obrigatorio | OBRIGATORIO (nunca pular) |
| Confirmacao | Obrigatoria | Obrigatoria |
| Smoke test | Obrigatorio | Obrigatorio |
| Rollback | Automatico | Automatico |
| Audit log | Recomendado | OBRIGATORIO |

## Comandos de chat

| Comando | O que faz |
|---------|----------|
| `Hotfix CU-XXXXX` | Inicia fluxo de hotfix |
| `Hotfix status` | Mostra status do hotfix em andamento |

## Permissoes necessarias

- `request-publish-prod` (developer, bypass-validation, tech-lead, admin)
- Em emergencia critica, tech-lead ou admin podem autorizar pular dry-run

## Registro de hotfix

Todo hotfix e registrado no audit log:

```markdown
## 2026-09-14 18:00 — HOTFIX
- **Release:** r20260914-CU9999-hotfix-a1b2c3d
- **Task:** CU-9999
- **Objeto:** UspFinGeraPagamento
- **Motivo:** Bug em producao causando pagamento duplicado
- **Autorizado por:** tech-lead
- **Dry-run pulado:** sim (emergencia critica)
- **Backup criado:** sim (backups/prod/UspFinGeraPagamento_20260914_180000.sql)
- **Smoke test:** pass
- **Status:** publicado
```
