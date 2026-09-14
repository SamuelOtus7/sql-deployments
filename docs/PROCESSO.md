# Processo de Publicação SQL — Irisys (Otus7)

> Documento vivo — atualizado conforme as fases são implementadas.

## Visão geral

Processo end-to-end para versionar, validar e publicar scripts SQL no banco Irisys com rastreabilidade e rollback. O controle é feito 100% via chat (Devin como control plane).

## Ambientes

| Ambiente | Host | Porta | Banco | MCP Server |
|----------|------|-------|-------|------------|
| **PROD** | 37.27.56.93 | 1491 | db_Irisys | `mssql` |
| **QAS** | 37.27.56.113 | 1483 | db_IrisysDev | `mssql-37` |

## Convenções

### Branches
- Feature: `sql/CU-<clickup_id>-<slug>`
- Hotfix: `sql/hotfix-<slug>`
- Branch principal: `main` (protegida)

### Scripts
- Forward: `scripts/forward/YYYY/MM/NNN_forward_CU-XXXXX_<slug>.sql`
- Rollback: `scripts/rollback/YYYY/MM/NNN_rollback_CU-XXXXX_<slug>.sql`
- Todo forward DEVE ter um rollback correspondente no mesmo commit

### Cabeçalho obrigatório
Todo script deve incluir o cabeçalho padrão (ver `templates/forward-template.sql`):
- Task ClickUp
- Autor
- Data
- Descrição
- Referência ao script correspondente (forward ↔ rollback)
- Objetos afetados
- Dependências

### Boas práticas obrigatórias
- `SET NOCOUNT ON;` no início
- `SET XACT_ABORT ON;` no início
- `BEGIN TRY` / `BEGIN CATCH` com `THROW`
- `BEGIN TRANSACTION` / `COMMIT` / `ROLLBACK`
- Sem `SELECT *` em procedures
- Sem `GRANT` ou `EXECUTE AS` sem justificativa

## Fluxo de publicação (7 fases)

### Fase 1 — Origem e desenvolvimento
1. Task criada no ClickUp
2. Desenvolvedor atua via chat Devin
3. Criar branch `sql/CU-<id>-<slug>`
4. Escrever scripts forward + rollback usando os templates
5. Pre-commit valida: lint + par forward/rollback
6. Commit com referência da task ClickUp
7. Push para GitHub

### Fase 2 — Code Review e Merge
1. Abrir Pull Request
2. Code Review (checklist do PR template)
3. Se aprovado: Git gera chave de pesquisa (ex: `r20260912-CU1234-a1b2c3d`)
4. Analista cola a chave no ClickUp
5. Merge para `main`

### Fase 3 — Publicação em QAS
1. Scripts aplicados no QAS (banco de teste) via MCP `mssql-37`
2. Time de teste valida a funcionalidade no QAS
3. Se aprovado: segue para solicitação de produção
4. Se reprovado: desenvolvedor corrige e refaz

### Fase 4 — Solicitação de Produção
1. Desenvolvedor diz no chat: `Publicar CU-<id> em produção`
2. Agente IA inicia validação automática

### Fase 5 — Validação IA (4 camadas)

#### Camada 1 — Análise de Impacto em Banco
- Schema diff entre QAS e PROD
- Dependências (`sys.dm_sql_referencing_entities`)
- Breaking changes (remover coluna, renomear, alterar comportamento)

#### Camada 2 — Code Review Automático
- Segurança: injection, GRANT, EXECUTE AS
- Performance: NOLOCK, índice, SELECT *
- Boas práticas: TRY/CATCH, SET NOCOUNT ON, idempotência

#### Camada 3 — Dry-Run em QAS
- `BEGIN TRAN` + executar scripts + verificar + `ROLLBACK`
- Se erro: bloquear deploy

#### Camada 4 — Validação de Negócio (Configurável)
- Consulta `validations/registry.json` para identificar validações aplicáveis
- Se objeto tem validação cadastrada: executa a estratégia configurada
- Se objeto NÃO tem validação cadastrada:
  - Verifica permissão do usuário (RBAC)
  - Usuário com `bypass-validation`: permite com aviso + log de auditoria
  - Usuário sem `bypass-validation`: bloqueia + notifica Tech Lead

### Fase 6 — Confirmação e Deploy
1. Devin reporta resultado completo no chat
2. Pede confirmação: `Confirma publicação em PROD? (sim/não)`
3. Se "sim":
   - Backup do PROD
   - Drift check QAS vs PROD
   - Aplicar scripts no PROD via MCP `mssql`
   - Smoke test pós-deploy
   - Se falhar: rollback automático + notificar
4. Se "não": publicação abortada

### Fase 7 — Registro e Encerramento
1. Registrar no Git: tag + changelog + manifest
2. Atualizar task ClickUp com status publicada
3. Notificar stakeholders

## Refresh semanal do QAS

O QAS é apagado e recriado a partir do PROD semanalmente (manual).

### Comportamento pós-refresh
1. Desenvolvedor diz no chat: `Pós-refresh QAS`
2. Agente lê `scripts/qas-state.json` (scripts em andamento)
3. Para cada script:
   - Compara hash do objeto no QAS (agora = PROD) com hash anterior
   - Se hash igual (objeto não mudou): re-aplica o script no QAS
   - Se hash diferente (PROD mudou o objeto): bloqueia + avisa dev para rebase
4. Reporta no chat o que foi re-aplicado e o que foi bloqueado

## Comandos de chat

| Comando | O que faz |
|---------|----------|
| `Publicar CU-<id> em QAS` | Aplica scripts no QAS |
| `Publicar CU-<id> em produção` | Executa validação + pede confirmação + deploy PROD |
| `Status CU-<id>` | Mostra status da validação/publicação |
| `Rollback r<chave>` | Executa rollback de uma publicação |
| `Hotfix CU-<id>` | Inicia fluxo de hotfix acelerado |
| `Validar CU-<id>` | Executa validação IA sem publicar |
| `Drift check` | Compara QAS vs PROD |
| `Pós-refresh QAS` | Re-aplica scripts em andamento após refresh semanal |
| `QAS status` | Mostra scripts no QAS mas não no PROD |
| `Cadastrar validação para <objeto>` | Inicia cadastro de validação de negócio |
| `Listar validações` | Mostra validações cadastradas |
| `Listar permissões` | Mostra roles e permissões do usuário |

## RBAC (controle de permissões)

| Permissão | developer | validation-architect | bypass-validation | tech-lead | admin |
|-----------|:-:|:-:|:-:|:-:|:-:|
| Criar branch/commit/PR | ✅ | ✅ | ✅ | ✅ | ✅ |
| Solicitar publicação | ✅ | ✅ | ✅ | ✅ | ✅ |
| Criar/editar validação | ❌ | ✅ | ❌ | ✅ | ✅ |
| Publicar sem validação | ❌ | ❌ | ✅ | ✅ | ✅ |
| Aprovar exceção | ❌ | ❌ | ❌ | ✅ | ✅ |
| Merge PR | ❌ | ❌ | ❌ | ✅ | ✅ |
| Gerenciar RBAC | ❌ | ❌ | ❌ | ❌ | ✅ |

## Status de implementação

| Fase | Status | Descrição |
|------|--------|-----------|
| 1 | ✅ Concluída | Fundação do repo (git init + GitHub) |
| 2 | ✅ Concluída | Templates e convenções |
| 3 | ⏳ Pendente | Pre-commit hooks (lint + par forward/rollback) |
| 4 | ⏳ Pendente | Fluxo de PR |
| 5 | ⏳ Pendente | GitHub Actions CI |
| 6 | ⏳ Pendente | Chave de pesquisa + changelog |
| 7 | ⏳ Pendente | Deploy no QAS via chat |
| 8 | ⏳ Pendente | Rastreamento de estado QAS |
| 9 | ⏳ Pendente | Deploy no PROD (básico) |
| 10 | ⏳ Pendente | Backup pré-deploy |
| 11 | ⏳ Pendente | Smoke test pós-deploy |
| 12 | ⏳ Pendente | Rollback |
| 13 | ⏳ Pendente | Validação IA: Impacto |
| 14 | ⏳ Pendente | Validação IA: Code review |
| 15 | ⏳ Pendente | Validação IA: Dry-run |
| 16 | ⏳ Pendente | Framework de validação de negócio |
| 17 | ⏳ Pendente | Validação IA: Negócio |
| 18 | ⏳ Pendente | RBAC |
| 19 | ⏳ Pendente | Drift check |
| 20 | ⏳ Pendente | Refresh QAS |
| 21 | ⏳ Pendente | Hotfix |
| 22 | ⏳ Pendente | Log de auditoria e manifest |
