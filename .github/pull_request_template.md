## Pull Request — CU-XXXXX

### Task ClickUp
- **ID:** CU-XXXXX
- **Descrição:** [o que foi feito]

### Scripts incluidos
- [ ] Forward: `scripts/forward/YYYY/MM/NNN_forward_CU-XXXXX_<slug>.sql`
- [ ] Rollback: `scripts/rollback/YYYY/MM/NNN_rollback_CU-XXXXX_<slug>.sql`

---

### Checklist do Desenvolvedor (preencher antes de pedir review)

#### Qualidade do script
- [ ] `SET NOCOUNT ON` no inicio
- [ ] `BEGIN TRY` / `BEGIN CATCH` com `THROW`
- [ ] Cabecalho preenchido (Task ClickUp, Autor, Data, Rollback ref, Objetos, Dependencias)
- [ ] Sem `SELECT *` em procedures
- [ ] Sem `UPDATE`/`DELETE` sem `WHERE`
- [ ] `MERGE` com justificativa (se aplicavel)
- [ ] `NOLOCK` com justificativa (se aplicavel)
- [ ] Sem funcao em coluna no WHERE (nao-sargable) ou justificado

#### Rollback
- [ ] Script de rollback criado e testado
- [ ] Rollback reverte exatamente o que o forward fez
- [ ] Backup do objeto original salvo (se alteracao de procedure/view/function)

#### Testes
- [ ] Script testado localmente ou no QAS
- [ ] Pre-commit hooks passaram (lint + pares)
- [ ] Queries de comparacao antes/depois executadas (se aplicavel)

---

### Checklist do Revisor (preencher durante review)

#### Analise tecnica
- [ ] Codigo faz o que a task pede
- [ ] Alteracao minima necessaria (sem reescrever tudo)
- [ ] Nomenclatura consistente
- [ ] Sem codigo morto ou comentados

#### Impacto (matriz de risco)
- [ ] **Funcional:** [baixo / medio / alto] — [justificativa]
- [ ] **Financeiro:** [baixo / medio / alto] — [justificativa]
- [ ] **Performance:** [baixo / medio / alto] — [justificativa]
- [ ] **Lock/concorrencia:** [baixo / medio / alto] — [justificativa]
- [ ] **Outros clientes:** [baixo / medio / alto] — [justificativa]
- [ ] **Periodos fechados:** [baixo / medio / alto] — [justificativa]

#### Seguranca
- [ ] Sem `GRANT` ou `EXECUTE AS` sem justificativa
- [ ] Sem secrets/credenciais no script
- [ ] Sem operacoes destrutivas sem escopo

#### Dependencias
- [ ] Objetos dependentes identificados (views, procedures, functions que usam o objeto alterado)
- [ ] Impacto em outros processos avaliado
- [ ] Breaking changes documentados (se houver)

---

### Matriz de Risco (obrigatoria)

| Risco | Nivel | Justificativa |
|-------|-------|---------------|
| Funcional | | |
| Financeiro | | |
| Performance | | |
| Lock / concorrencia | | |
| Afetar outros clientes | | |
| Afetar periodos fechados | | |
| Sobrescrever ajuste existente | | |
| Divergencia ambiente local x banco | | |

---

### Notas adicionais
[qualquer informacao relevante para o revisor ou para o deploy]
