# AGENTS.md — sql-deployments

Repositório de versionamento e publicação de scripts SQL do banco Irisys (Otus7). O controle é 100% via chat (Devin como control plane).

## Leitura obrigatória

Antes de qualquer publicação: `docs/PROCESSO.md` (7 fases) e `README.md` (comandos de chat).

## Ambientes

| Ambiente | MCP | Host | Banco |
|----------|-----|------|-------|
| PROD | `mssql` | 37.27.56.93:1491 | db_Irisys |
| QAS | `mssql-37` | 37.27.56.113:1483 | db_IrisysDev |

## Regra dura

**Nunca aplicar DDL/DML direto em PROD.** Ordem obrigatória:

1. Branch `sql/CU-<id>-<slug>` (hotfix: `sql/hotfix-<slug>`)
2. Par forward + rollback em `scripts/{forward,rollback}/YYYY/MM/` com cabeçalho de `templates/`
3. Commit + push + PR (merge gera chave de pesquisa `r<data>-CU<id>-<hash>` para o ClickUp)
4. Aplicar no QAS (`mssql-37`) + validar
5. Deploy em PROD (`mssql`) somente após comando `Publicar CU-<id> em produção` + validação em 4 camadas

Todo forward exige rollback no mesmo commit. Deploy direto em PROD = bypass que exige confirmação explícita e registro.
