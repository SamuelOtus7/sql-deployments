# Configuração MCP — QAS (db_IrisysDev)

> Arquivo de referência para a configuração do MCP `mssql-37` no Devin.
> O arquivo real fica em: `C:\Users\Samuel Nogueira\AppData\Roaming\devin\mcp_config.json`
> O YAML de configuração fica em: `C:\Users\Samuel Nogueira\AppData\Roaming\devin\mssql-mcp-qas.yaml`

## mcp_config.json (Devin)

```json
{
  "mcpServers": {
    "mssql-37": {
      "command": "npx",
      "args": ["-y", "@tugberkgunver/mcp-sqlserver"],
      "env": {
        "MSSQL_MCP_CONFIG": "C:\\Users\\Samuel Nogueira\\AppData\\Roaming\\devin\\mssql-mcp-qas.yaml"
      }
    }
  }
}
```

## mssql-mcp-qas.yaml

```yaml
connection:
  host: 37.27.56.113
  port: 1483
  database: db_IrisysDev
  authentication:
    type: sql
    user: samuel
    password: *** (nao versionada)
  trustServerCertificate: true

security:
  mode: admin
  maxRowCount: 5000
  blockedDatabases:
    - master
    - msdb
    - tempdb
    - model
```

## Ferramentas disponiveis no MCP mssql-37

| Categoria | Ferramenta | O que faz |
|-----------|-----------|-----------|
| Schema | list_databases, list_schemas, list_tables, list_views | Lista objetos |
| Schema | describe_table, get_foreign_keys, get_indexes, get_constraints, get_triggers | Detalha objetos |
| Query | execute_query | SELECT (read-only) |
| Query | execute_mutation | INSERT/UPDATE/DELETE/MERGE |
| Query | export_query | Exporta para CSV/JSON |
| DDL | execute_ddl | CREATE/ALTER/DROP (requer admin) |
| Procedures | list_procedures, describe_procedure, execute_procedure | Lista, descreve e executa |
| Performance | get_query_plan, get_active_queries, get_table_stats, get_index_usage | Diagnostico |
| DBA | get_server_info, get_database_info, get_wait_stats, get_deadlocks | Administracao |
| DBA | get_blocking_chains, get_long_transactions, get_space_usage, get_backup_history | Administracao |
| DBA | get_query_store_stats, rebuild_index, health_check | Administracao |
| Utils | compare_schemas, generate_code, generate_insert_scripts | Utilitarios |
| Utils | generate_er_diagram, sample_table, generate_test_data | Utilitarios |

## Modos de seguranca

| Modo | SELECT | INSERT/UPDATE/DELETE | DDL | Stored Procedures |
|------|--------|---------------------|-----|-------------------|
| readonly | Sim | Nao | Nao | Apenas leitura |
| readwrite | Sim | Sim | Nao | Sim |
| admin | Sim | Sim | Sim | Sim |

QAS esta configurado como **admin** para permitir deploy de scripts SQL (CREATE/ALTER/DROP).
