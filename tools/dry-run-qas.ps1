<#
.SYNOPSIS
    Dry-run no QAS antes do deploy em PROD.
.DESCRIPTION
    Executa o script forward no QAS como teste, verifica se funcionou,
    e reverte automaticamente se falhar. Incorpora a regra
    rules/data/safe-database-changes.md: "Validacao em ambiente seguro".

    Fluxo:
    1. Agente aplica o script no QAS via mssql-37.execute_ddl
    2. Agente executa smoke test no QAS via mssql-37.execute_query
    3. Agente chama este script com -Action record -Result pass ou fail
    4. Se fail, agente executa rollback no QAS via mssql-37.execute_ddl
    5. Registra resultado no dry-run-log

    O agente (Devin) executa o DDL via MCP. Este script registra e coordena.

.PARAMETER Action
    generate:  gera as queries de smoke test e rollback para o agente executar no QAS
    record:    registra o resultado do dry-run (pass/fail) no log
    status:    mostra historico de dry-runs
    pending:   mostra dry-runs que ainda nao foram publicados em PROD

.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)

.PARAMETER ObjectName
    Nome do objeto alvo

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER ForwardScript
    Caminho do script forward aplicado no QAS

.PARAMETER RollbackScript
    Caminho do script rollback (para reverter QAS se falhar)

.PARAMETER Result
    Resultado do dry-run: pass ou fail (usado com -Action record)

.PARAMETER Schema
    Schema do objeto (default: dbo)

.EXAMPLE
    .\dry-run-qas.ps1 -Action generate -ObjectName vw_teste -ObjectType VIEW -ReleaseKey r20260914-CU8888-a1b2c3d -RollbackScript scripts/rollback/2026/09/001_rollback_CU8888_teste.sql
    .\dry-run-qas.ps1 -Action record -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_teste -ObjectType VIEW -Result pass -ForwardScript scripts/forward/2026/09/001_forward_CU8888_teste.sql
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("generate","record","status","pending")]
    [string]$Action,

    [string]$ReleaseKey = "",
    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ForwardScript = "",
    [string]$RollbackScript = "",
    [ValidateSet("pass","fail")]
    [string]$Result = "",
    [string]$Schema = "dbo"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$dryRunLogPath = Join-Path $repoRoot "scripts\dry-run-log.json"

if (-not (Test-Path $dryRunLogPath)) {
    '{"version":"1.0","lastUpdated":null,"dryRuns":[]}' | Set-Content -Path $dryRunLogPath -Encoding utf8
}

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
            Write-Host "ERRO: Tipo '$ObjectType' nao suportado." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== DRY-RUN QAS: $ObjectName ($ObjectType) ===" -ForegroundColor Cyan
        Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
        Write-Host ""

        # Query 1: Smoke test no QAS (verificar se o objeto existe e e valido)
        Write-Host "  PASSO 1: Aplicar o script forward no QAS" -ForegroundColor Yellow
        Write-Host "    Agente: executar o script forward via mssql-37.execute_ddl" -ForegroundColor White
        Write-Host ""

        Write-Host "  PASSO 2: Smoke test no QAS" -ForegroundColor Yellow
        Write-Host "    Agente: executar via mssql-37.execute_query:" -ForegroundColor White
        Write-Host ""
        Write-Host @"
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
"@ -ForegroundColor Gray
        Write-Host ""

        Write-Host "  PASSO 3: Registrar resultado" -ForegroundColor Yellow
        Write-Host "    Se smoke test passou:" -ForegroundColor Green
        Write-Host "      dry-run-qas.ps1 -Action record -Result pass -ReleaseKey $ReleaseKey -ObjectName $ObjectName -ObjectType $ObjectType -ForwardScript $ForwardScript" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "    Se smoke test falhou:" -ForegroundColor Red
        Write-Host "      1. Executar rollback no QAS via mssql-37.execute_ddl" -ForegroundColor White
        if ($RollbackScript) {
            $rbPath = Join-Path $repoRoot $RollbackScript
            if (Test-Path $rbPath) {
                Write-Host "      Script: $RollbackScript" -ForegroundColor DarkGray
            }
        }
        Write-Host "      2. dry-run-qas.ps1 -Action record -Result fail -ReleaseKey $ReleaseKey -ObjectName $ObjectName -ObjectType $ObjectType" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  CRITERIOS:" -ForegroundColor Cyan
        Write-Host "    pass: objeto existe, has_definition=1, is_valid=1" -ForegroundColor Green
        Write-Host "    fail: objeto nao existe, has_definition=0, is_valid=0, ou erro no DDL" -ForegroundColor Red
    }

    "record" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $Result) {
            Write-Host "ERRO: ReleaseKey, ObjectName e Result sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        $log = Get-Content $dryRunLogPath -Raw | ConvertFrom-Json

        # Remove entrada anterior para esta release+objeto (se existir)
        $log.dryRuns = @($log.dryRuns | Where-Object {
            -not ($_.releaseKey -eq $ReleaseKey -and $_.objectName -eq "$Schema.$ObjectName")
        })

        $entry = [PSCustomObject]@{
            releaseKey      = $ReleaseKey
            objectName      = "$Schema.$ObjectName"
            objectType      = $ObjectType
            forwardScript   = $ForwardScript
            rollbackScript  = $RollbackScript
            result          = $Result
            testedAt        = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            testedBy        = $env:USERNAME
            deployedToProd  = $false
        }

        $log.dryRuns = @($log.dryRuns + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $dryRunLogPath -Encoding utf8

        if ($Result -eq "pass") {
            Write-Host "DRY-RUN QAS: PASSOU." -ForegroundColor Green
            Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
            Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  O script foi validado no QAS com sucesso." -ForegroundColor Green
            Write-Host "  O deploy em PROD esta liberado (apos impacto + code review + confirmacao)." -ForegroundColor Green
            Write-Host ""
            Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
            Write-Host "    1. impact-analysis.ps1 -Action analyze (validar impacto)" -ForegroundColor White
            Write-Host "    2. code-review.ps1 -Action review (revisar codigo)" -ForegroundColor White
            Write-Host "    3. deploy-prod.ps1 -Action pre-check (validar antes do PROD)" -ForegroundColor White
            Write-Host "    4. backup-prod.ps1 (salvar objeto do PROD)" -ForegroundColor White
            Write-Host "    5. deploy-prod.ps1 -Action confirm (confirmar explicitamente)" -ForegroundColor White
            Write-Host "    6. mssql-prod.execute_ddl (aplicar no PROD)" -ForegroundColor White
        } else {
            Write-Host "DRY-RUN QAS: FALHOU." -ForegroundColor Red
            Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
            Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  O script falhou no QAS. O deploy em PROD esta BLOQUEADO." -ForegroundColor Red
            Write-Host ""
            if ($RollbackScript) {
                Write-Host "  ROLLBACK QAS: Executar o script de rollback no QAS via mssql-37.execute_ddl:" -ForegroundColor Yellow
                $rbPath = Join-Path $repoRoot $RollbackScript
                if (Test-Path $rbPath) {
                    Write-Host "    Script: $RollbackScript" -ForegroundColor DarkGray
                }
            }
            Write-Host ""
            Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
            Write-Host "    1. Investigar causa da falha no QAS" -ForegroundColor White
            Write-Host "    2. Corrigir o script forward" -ForegroundColor White
            Write-Host "    3. Re-executar dry-run" -ForegroundColor White
            Write-Host "    4. NAO publicar em PROD ate o dry-run passar" -ForegroundColor Red
        }
    }

    "status" {
        $log = Get-Content $dryRunLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== DRY-RUN LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.dryRuns.Count -eq 0) {
            Write-Host "  Nenhum dry-run registrado." -ForegroundColor DarkGray
            return
        }

        foreach ($d in $log.dryRuns) {
            $color = if ($d.result -eq "pass") { "Green" } else { "Red" }
            $prodStatus = if ($d.deployedToProd) { "SIM" } else { "NAO" }
            Write-Host "  [$($d.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:    $($d.objectName) ($($d.objectType))" -ForegroundColor White
            Write-Host "    Resultado: $($d.result)" -ForegroundColor $color
            Write-Host "    Testado:   $($d.testedAt)" -ForegroundColor DarkGray
            Write-Host "    Por:       $($d.testedBy)" -ForegroundColor DarkGray
            Write-Host "    Em PROD:   $prodStatus" -ForegroundColor $(if ($d.deployedToProd) { "Green" } else { "Yellow" })
            Write-Host ""
        }
    }

    "pending" {
        $log = Get-Content $dryRunLogPath -Raw | ConvertFrom-Json
        $pending = $log.dryRuns | Where-Object { $_.result -eq "pass" -and -not $_.deployedToProd }

        Write-Host ""
        Write-Host "=== DRY-RUNS PENDENTES (pass no QAS, aguardando PROD) ===" -ForegroundColor Cyan
        Write-Host ""

        if (-not $pending -or $pending.Count -eq 0) {
            Write-Host "  Nenhum dry-run pendente." -ForegroundColor DarkGray
            Write-Host "  Todos os scripts validados no QAS ja foram publicados em PROD." -ForegroundColor Green
            return
        }

        foreach ($p in $pending) {
            Write-Host "  [$($p.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:    $($p.objectName) ($($p.objectType))" -ForegroundColor White
            Write-Host "    Forward:   $($p.forwardScript)" -ForegroundColor DarkGray
            Write-Host "    Rollback:  $($p.rollbackScript)" -ForegroundColor DarkGray
            Write-Host "    Testado:   $($p.testedAt)" -ForegroundColor DarkGray
            Write-Host ""
        }

        Write-Host "  Estes scripts passaram no QAS mas ainda nao foram publicados em PROD." -ForegroundColor Yellow
        Write-Host "  Para publicar, execute o fluxo de deploy em PROD." -ForegroundColor DarkGray
    }
}
