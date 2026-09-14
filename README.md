# SQL Deployments

Repositório de versionamento e publicação de scripts SQL do banco Irisys (Otus7).

## Ambientes

| Ambiente | Host | Porta | Banco | MCP Server |
|----------|------|-------|-------|------------|
| **PROD** | 37.27.56.93 | 1491 | db_Irisys | `mssql` |
| **QAS** | 37.27.56.113 | 1483 | db_IrisysDev | `mssql-37` |

## Estrutura

```
sql-deployments/
├── scripts/          # Scripts de deploy (forward + rollback) organizados por ano/mês
├── changelog/        # Histórico de publicações e log de auditoria
├── tools/            # Ferramentas (lint, validação, backup, drift, rollback)
├── validations/      # Framework de validação de negócio configurável
├── config/           # Governança e permissões (RBAC)
├── templates/        # Templates de script forward/rollback
├── docs/             # Documentação do processo
└── .githooks/        # Pre-commit hooks
```

## Fluxo de publicação

1. Task criada no ClickUp
2. Desenvolvedor cria branch `sql/CU-<id>-<slug>` e escreve scripts forward + rollback
3. Pre-commit valida lint + par forward/rollback
4. Pull Request com code review
5. Merge gera chave de pesquisa (ex: `r20260912-CU1234-a1b2c3d`)
6. Analista cola a chave no ClickUp
7. Scripts aplicados no QAS via chat (MCP `mssql-37`)
8. Time de teste valida no QAS
9. Desenvolvedor solicita publicação em produção via chat
10. Agente IA executa 4 camadas de validação:
    - Camada 1: Impacto em banco
    - Camada 2: Code review automático
    - Camada 3: Dry-run em QAS
    - Camada 4: Validação de negócio (conforme registry)
11. Backup do PROD + drift check
12. Deploy no PROD via chat (MCP `mssql`)
13. Smoke test pós-deploy
14. Registro no Git (tag + changelog + manifest)

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

## Status

**Fase 1: Fundação do repositório** — em andamento
