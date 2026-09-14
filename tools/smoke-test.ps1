<#
.SYNOPSIS
    Smoke test pos-deploy no PROD - verifica se o objeto existe e e valido.
.DESCRIPTION
    Esta ferramenta e executada PELO AGENTE (Devin) apos aplicar DDL no PROD.

    Fluxo:
    1. Agente aplica DDL no PROD via mssql-prod.execute_ddl
    2. Agente chama este script com -Action generate para obter a query de smoke test
    3. Agente executa a query no PROD via mssql-prod.execute_query
    4. Agente chama este script com -Action record -Result pass ou -Result fail
    5. Se fail, o script gera o comando de rollback para o agente executar
    6. Registra o resultado no audit log de smoke tests

.PARAMETER Action
    generate: gera a query de smoke test para o agente executar
    record:   registra o resultado (pass/fail) e gera rollback se falhar
    status:   mostra historico de smoke tests

.PARAMETER ObjectName
    Nome do objeto (ex: vw_teste, UspFinGeraPagamento)

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)

.PARAMETER Result
    Resultado do smoke test: pass ou fail (usado com -Action record)

.PARAMETER Schema
    Schema do objeto (default: dbo)

.PARAMETER RollbackScript
    Caminho do script de rollback (para gerar comando de rollback se smoke falhar)

.EXAMPLE
    .\smoke-test.ps1 -Action generate -ObjectName vw_teste -ObjectType VIEW -ReleaseKey r20260914-CU8888-a1b2c3d
    .\smoke-test.ps1 -Action record -ObjectName vw_teste -ObjectType VIEW -ReleaseKey r20260914-CU8888-a1b2c3d -Result pass
    .\smoke-test.ps1 -Action record -ObjectName vw_teste -ObjectType VIEW -ReleaseKey r20260914-CU8888-a1b2c3d -Result fail -RollbackScript scripts/rollback/2026/09/001_rollback_CU8888_teste.sql
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("generate","record","status")]
    [string]$Action,

    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ReleaseKey = "",
    [ValidateSet("pass","fail")]
    [string]$Result = "",
    [string]$Schema = "dbo",
    [string]$RollbackScript = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$smokeLogPath = Join-Path $repoRoot "scripts\smoke-log.json"

# Garante log
if (-not (Test-Path $smokeLogPath)) {
    '{"version":"1.0","lastUpdated":null,"tests":[]}' | Set-Content -Path $smokeLogPath -Encoding utf8
}

# Mapa de tipos SQL
$typeMap = @{
    "VIEW"      = "V"
    "PROCEDURE" = "P"
    "TABLE"     = "U"
    "FUNCTION"  = "FN"
    "TRIGGER"   = "TR"
}

switch ($Action) {
    "generate" {
        if (-not $ObjectName -or -not $ObjectType) {
            Write-Host "ERRO: ObjectName e ObjectType sao obrigatorios para generate." -ForegroundColor Red
            exit 1
        }

        $typeCode = $typeMap[$ObjectType]
        if (-not $typeCode) {
            Write-Host "ERRO: Tipo '$ObjectType' nao suportado. Use: VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER" -ForegroundColor Red
            exit 1
        }

        # Query de smoke test - verifica existencia e validade
        $smokeQuery = @"
-- Smoke test pos-deploy: [$Schema].[$ObjectName] ($ObjectType)
-- Release: $ReleaseKey
-- Executar via mssql-prod.execute_query
SELECT
    o.name                                              AS object_name,
    o.type_desc                                         AS object_type,
    o.create_date                                        AS created_at,
    o.modify_date                                        AS modified_at,
    CASE WHEN m.object_id IS NOT NULL THEN 1 ELSE 0 END AS has_definition,
    CASE
        WHEN o.type = 'V'  THEN OBJECTPROPERTY(o.object_id, 'IsSchemaBound')
        WHEN o.type = 'P'  THEN OBJECTPROPERTY(o.object_id, 'IsExecuted')
        WHEN o.type = 'FN' THEN OBJECTPROPERTY(o.object_id, 'IsDeterministic')
        ELSE 1
    END                                                 AS is_valid
FROM sys.objects o
LEFT JOIN sys.sql_modules m ON m.object_id = o.object_id
WHERE o.name = '$ObjectName'
  AND o.schema_id = SCHEMA_ID('$Schema')
  AND o.type = '$typeCode';
"@

        Write-Host "SMOKE TEST PROD: Query gerada para [$Schema].[$ObjectName] ($ObjectType)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Execute via mssql-prod.execute_query:" -ForegroundColor White
        Write-Host ""
        Write-Host $smokeQuery -ForegroundColor Gray
        Write-Host ""
        Write-Host "CRITERIOS DE APROVACAO:" -ForegroundColor Yellow
        Write-Host "  - Retornou 1 linha: objeto existe" -ForegroundColor White
        Write-Host "  - has_definition = 1: tem definicao SQL" -ForegroundColor White
        Write-Host "  - is_valid = 1: objeto e valido" -ForegroundColor White
        Write-Host ""
        Write-Host "CRITERIOS DE FALHA (dispara rollback):" -ForegroundColor Red
        Write-Host "  - Retornou 0 linhas: objeto nao existe" -ForegroundColor White
        Write-Host "  - has_definition = 0: objeto sem definicao" -ForegroundColor White
        Write-Host "  - is_valid = 0: objeto invalido" -ForegroundColor White
    }

    "record" {
        if (-not $ObjectName -or -not $ReleaseKey -or -not $Result) {
            Write-Host "ERRO: ObjectName, ReleaseKey e Result sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        # Registra no log
        $log = Get-Content $smokeLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey    = $ReleaseKey
            objectName    = "$Schema.$ObjectName"
            objectType    = $ObjectType
            result        = $Result
            testedAt      = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            rollbackScript = $RollbackScript
            rollbackTriggered = ($Result -eq "fail")
        }
        $log.tests = @($log.tests + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $smokeLogPath -Encoding utf8

        if ($Result -eq "pass") {
            Write-Host "SMOKE TEST: PASSOU." -ForegroundColor Green
            Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
            Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
            Write-Host "  Deploy concluido com sucesso." -ForegroundColor Green
            Write-Host ""
            Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
            Write-Host "    1. Registrar no audit log (deploy-prod.ps1 -Action apply)" -ForegroundColor White
            Write-Host "    2. Remover do estado QAS (qas-state.ps1 -Action remove)" -ForegroundColor White
        } else {
            Write-Host "SMOKE TEST: FALHOU." -ForegroundColor Red
            Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
            Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  *** ROLLBACK AUTOMATICO DISPARADO ***" -ForegroundColor Red
            Write-Host ""

            if ($RollbackScript) {
                $rbPath = Join-Path $repoRoot $RollbackScript
                if (Test-Path $rbPath) {
                    $rbContent = Get-Content $rbPath -Raw
                    Write-Host "  ROLLBACK SCRIPT ENCONTRADO: $RollbackScript" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "  AGENTE: Executar o script de rollback no PROD via mssql-prod.execute_ddl:" -ForegroundColor Red
                    Write-Host ""
                    Write-Host $rbContent -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "  Apos executar o rollback:" -ForegroundColor Yellow
                    Write-Host "    1. Confirmar que o objeto foi revertido (smoke test novamente)" -ForegroundColor White
                    Write-Host "    2. Registrar falha no audit log (deploy-prod.ps1 -Action apply com status=failed)" -ForegroundColor White
                    Write-Host "    3. Notificar o desenvolvedor" -ForegroundColor White
                } else {
                    Write-Host "  ERRO CRITICO: Rollback script nao encontrado: $RollbackScript" -ForegroundColor Red
                    Write-Host "  Restaurar manualmente via backup em backups/prod/" -ForegroundColor Yellow
                }
            } else {
                Write-Host "  ERRO CRITICO: Nenhum rollback script informado." -ForegroundColor Red
                Write-Host "  Restaurar manualmente via backup em backups/prod/" -ForegroundColor Yellow
            }
        }
    }

    "status" {
        $log = Get-Content $smokeLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== SMOKE TEST LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.tests.Count -eq 0) {
            Write-Host "  Nenhum smoke test registrado." -ForegroundColor DarkGray
            return
        }

        foreach ($t in $log.tests) {
            $color = if ($t.result -eq "pass") { "Green" } else { "Red" }
            Write-Host "  [$($t.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:    $($t.objectName) ($($t.objectType))" -ForegroundColor White
            Write-Host "    Resultado: $($t.result)" -ForegroundColor $color
            Write-Host "    Testado:   $($t.testedAt)" -ForegroundColor DarkGray
            if ($t.rollbackTriggered) {
                Write-Host "    Rollback:  DISPARADO ($($t.rollbackScript))" -ForegroundColor Red
            }
            Write-Host ""
        }
    }
}
