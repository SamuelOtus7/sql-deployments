<#
.SYNOPSIS
    Drift check entre QAS e PROD antes do deploy.
.DESCRIPTION
    Compara schemas entre QAS e PROD para detectar divergencias.
    Se PROD foi alterado fora do processo (hotfix manual, outro dev publicou),
    o drift check detecta e bloqueia o deploy.

    O agente executa queries em ambos os ambientes via MCP e compara:
    - Objetos (views, procedures, functions, tables)
    - Definicoes (hash das definicoes SQL)
    - Colunas de tabelas

.PARAMETER Action
    generate:  gera as queries para o agente executar em QAS e PROD
    evaluate:  avalia os resultados comparando QAS vs PROD
    record:    registra o resultado do drift check no log
    status:    mostra historico de drift checks

.PARAMETER ObjectName
    Nome do objeto especifico a comparar (opcional - se vazio, compara todos)

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER ReleaseKey
    Chave de release

.PARAMETER QasHash
    Hash do objeto no QAS (para comparacao direta)

.PARAMETER ProdHash
    Hash do objeto no PROD (para comparacao direta)

.PARAMETER DriftResult
    Resultado: aligned ou drifted (usado com -Action record)

.EXAMPLE
    .\drift-check.ps1 -Action generate -ObjectName vw_feriados -ObjectType VIEW
    .\drift-check.ps1 -Action evaluate -ObjectName vw_feriados -QasHash abc123 -ProdHash abc123
    .\drift-check.ps1 -Action record -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_feriados -DriftResult aligned
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("generate","evaluate","record","status")]
    [string]$Action,

    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ReleaseKey = "",
    [string]$QasHash = "",
    [string]$ProdHash = "",
    [ValidateSet("aligned","drifted")]
    [string]$DriftResult = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$driftLogPath = Join-Path $repoRoot "scripts\drift-log.json"

if (-not (Test-Path $driftLogPath)) {
    '{"version":"1.0","lastUpdated":null,"checks":[]}' | Set-Content -Path $driftLogPath -Encoding utf8
}

switch ($Action) {
    "generate" {
        Write-Host ""
        Write-Host "=== DRIFT CHECK: QAS vs PROD ===" -ForegroundColor Cyan
        if ($ObjectName) { Write-Host "  Objeto: $ObjectName ($ObjectType)" -ForegroundColor White }
        Write-Host ""

        if ($ObjectName) {
            # Comparacao de objeto especifico
            Write-Host "  PASSO 1: Obter hash do objeto no QAS" -ForegroundColor Yellow
            Write-Host "    Agente: executar via mssql-37.execute_query:" -ForegroundColor White
            Write-Host @"
SELECT
    o.name,
    o.type_desc,
    HASHBYTES('SHA2_256', m.definition) AS object_hash
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.name = '$ObjectName';
"@ -ForegroundColor Gray
            Write-Host ""

            Write-Host "  PASSO 2: Obter hash do objeto no PROD" -ForegroundColor Yellow
            Write-Host "    Agente: executar via mssql-prod.execute_query:" -ForegroundColor White
            Write-Host @"
SELECT
    o.name,
    o.type_desc,
    HASHBYTES('SHA2_256', m.definition) AS object_hash
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.name = '$ObjectName';
"@ -ForegroundColor Gray
            Write-Host ""

            Write-Host "  PASSO 3: Comparar hashes" -ForegroundColor Yellow
            Write-Host "    Se QAS hash == PROD hash -> aligned (sem drift)" -ForegroundColor Green
            Write-Host "    Se QAS hash != PROD hash -> drifted (PROD mudou fora do processo)" -ForegroundColor Red
            Write-Host ""
            Write-Host "    Registrar resultado:" -ForegroundColor Cyan
            Write-Host "      drift-check.ps1 -Action evaluate -ObjectName $ObjectName -QasHash <hash_qas> -ProdHash <hash_prod>" -ForegroundColor DarkGray
        } else {
            # Comparacao completa de schemas
            Write-Host "  PASSO 1: Listar objetos no QAS" -ForegroundColor Yellow
            Write-Host "    Agente: executar via mssql-37.execute_query:" -ForegroundColor White
            Write-Host @"
SELECT
    o.name,
    o.type_desc,
    HASHBYTES('SHA2_256', ISNULL(m.definition, '')) AS object_hash
FROM sys.objects o
LEFT JOIN sys.sql_modules m ON m.object_id = o.object_id
WHERE o.type IN ('V','P','FN','TF','U','TR')
  AND o.is_ms_shipped = 0
ORDER BY o.type_desc, o.name;
"@ -ForegroundColor Gray
            Write-Host ""

            Write-Host "  PASSO 2: Listar objetos no PROD" -ForegroundColor Yellow
            Write-Host "    Agente: executar via mssql-prod.execute_query:" -ForegroundColor White
            Write-Host @"
SELECT
    o.name,
    o.type_desc,
    HASHBYTES('SHA2_256', ISNULL(m.definition, '')) AS object_hash
FROM sys.objects o
LEFT JOIN sys.sql_modules m ON m.object_id = o.object_id
WHERE o.type IN ('V','P','FN','TF','U','TR')
  AND o.is_ms_shipped = 0
ORDER BY o.type_desc, o.name;
"@ -ForegroundColor Gray
            Write-Host ""

            Write-Host "  PASSO 3: Comparar listas" -ForegroundColor Yellow
            Write-Host "    - Objetos no PROD mas nao no QAS: novos no PROD (ok)" -ForegroundColor White
            Write-Host "    - Objetos no QAS mas nao no PROD: scripts em andamento (ok)" -ForegroundColor White
            Write-Host "    - Objetos em ambos com hash diferente: DRIFT (bloquear)" -ForegroundColor Red
        }
    }

    "evaluate" {
        if (-not $QasHash -or -not $ProdHash) {
            Write-Host "ERRO: QasHash e ProdHash sao obrigatorios para evaluate." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== DRIFT CHECK RESULTADO: $ObjectName ===" -ForegroundColor Cyan
        Write-Host "  QAS hash:   $QasHash" -ForegroundColor DarkGray
        Write-Host "  PROD hash:  $ProdHash" -ForegroundColor DarkGray
        Write-Host ""

        if ($QasHash -eq $ProdHash) {
            Write-Host "  RESULTADO: ALIGNED (sem drift)" -ForegroundColor Green
            Write-Host "  QAS e PROD estao alinhados para o objeto '$ObjectName'." -ForegroundColor Green
            Write-Host "  O deploy pode prosseguir." -ForegroundColor Green
            Write-Host ""
            Write-Host "  Registrar:" -ForegroundColor Cyan
            Write-Host "    drift-check.ps1 -Action record -ReleaseKey $ReleaseKey -ObjectName $ObjectName -DriftResult aligned" -ForegroundColor DarkGray
            exit 0
        } else {
            Write-Host "  RESULTADO: DRIFTED (divergencia detectada)" -ForegroundColor Red
            Write-Host "  PROD divergiu do QAS para o objeto '$ObjectName'." -ForegroundColor Red
            Write-Host "  Isso significa que PROD foi alterado fora do processo." -ForegroundColor Red
            Write-Host ""
            Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
            Write-Host "    1. Investigar o que mudou no PROD" -ForegroundColor White
            Write-Host "    2. Atualizar o QAS com a versao atual do PROD" -ForegroundColor White
            Write-Host "    3. Re-aplicar o script forward no QAS" -ForegroundColor White
            Write-Host "    4. Re-executar o drift check" -ForegroundColor White
            Write-Host "    5. NAO publicar em PROD ate o drift ser resolvido" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Registrar:" -ForegroundColor Cyan
            Write-Host "    drift-check.ps1 -Action record -ReleaseKey $ReleaseKey -ObjectName $ObjectName -DriftResult drifted" -ForegroundColor DarkGray
            exit 4  # exit code 4 = drifted
        }
    }

    "record" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $DriftResult) {
            Write-Host "ERRO: ReleaseKey, ObjectName e DriftResult sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        $log = Get-Content $driftLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey    = $ReleaseKey
            objectName    = $ObjectName
            objectType    = $ObjectType
            result        = $DriftResult
            qasHash       = $QasHash
            prodHash      = $ProdHash
            checkedAt     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            checkedBy      = $env:USERNAME
        }
        $log.checks = @($log.checks + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $driftLogPath -Encoding utf8

        $color = if ($DriftResult -eq "aligned") { "Green" } else { "Red" }
        Write-Host "DRIFT CHECK REGISTRADO: $DriftResult" -ForegroundColor $color
        Write-Host "  Objeto: $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
    }

    "status" {
        $log = Get-Content $driftLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== DRIFT CHECK LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.checks.Count -eq 0) {
            Write-Host "  Nenhum drift check registrado." -ForegroundColor DarkGray
            return
        }

        foreach ($c in $log.checks) {
            $color = if ($c.result -eq "aligned") { "Green" } else { "Red" }
            Write-Host "  [$($c.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:   $($c.objectName) ($($c.objectType))" -ForegroundColor White
            Write-Host "    Resultado: $($c.result)" -ForegroundColor $color
            Write-Host "    QAS:      $($c.qasHash)" -ForegroundColor DarkGray
            Write-Host "    PROD:     $($c.prodHash)" -ForegroundColor DarkGray
            Write-Host "    Verificado: $($c.checkedAt)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
