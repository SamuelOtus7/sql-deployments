<#
.SYNOPSIS
    Rollback automatico de deploy no PROD quando smoke test falha.
.DESCRIPTION
    Esta ferramenta e executada PELO AGENTE (Devin) quando o smoke test falha.

    Fluxo:
    1. Agente detecta smoke test fail (smoke-test.ps1 -Action record -Result fail)
    2. Agente chama este script com -Action generate para obter o comando de rollback
    3. Script le o backup salvo na Fase 10 (backup-prod.ps1)
    4. Script gera o DDL de rollback apropriado:
       - Objeto existente: ALTER ou DROP+CREATE com a definicao do backup
       - Objeto novo: DROP
    5. Agente executa o DDL no PROD via mssql-prod.execute_ddl
    6. Agente executa smoke test novamente para confirmar reversao
    7. Agente chama -Action record para registrar no audit log

.PARAMETER Action
    generate: le o backup e gera o DDL de rollback para o agente executar
    record:   registra o resultado do rollback no audit log
    status:   mostra historico de rollbacks

.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)

.PARAMETER ObjectName
    Nome do objeto (ex: vw_teste)

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER RollbackResult
    Resultado do rollback: success ou failed (usado com -Action record)

.PARAMETER Schema
    Schema do objeto (default: dbo)

.EXAMPLE
    .\rollback-prod.ps1 -Action generate -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_teste -ObjectType VIEW
    .\rollback-prod.ps1 -Action record -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_teste -ObjectType VIEW -RollbackResult success
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("generate","record","status")]
    [string]$Action,

    [string]$ReleaseKey = "",
    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [ValidateSet("success","failed")]
    [string]$RollbackResult = "",
    [string]$Schema = "dbo"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$backupDir = Join-Path $repoRoot "backups\prod"
$manifestPath = Join-Path $backupDir "manifest.json"
$rollbackLogPath = Join-Path $repoRoot "scripts\rollback-log.json"

# Garante log
if (-not (Test-Path $rollbackLogPath)) {
    '{"version":"1.0","lastUpdated":null,"rollbacks":[]}' | Set-Content -Path $rollbackLogPath -Encoding utf8
}

switch ($Action) {
    "generate" {
        if (-not $ReleaseKey -or -not $ObjectName) {
            Write-Host "ERRO: ReleaseKey e ObjectName sao obrigatorios para generate." -ForegroundColor Red
            exit 1
        }

        # Le o manifest de backups
        if (-not (Test-Path $manifestPath)) {
            Write-Host "ERRO: Nenhum manifest de backup encontrado em backups/prod/manifest.json" -ForegroundColor Red
            Write-Host "  Nao ha backup para restaurar. Restauracao deve ser manual." -ForegroundColor Yellow
            exit 1
        }

        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

        # Procura o backup mais recente para esta release e objeto
        $backup = $manifest.backups | Where-Object {
            $_.releaseKey -eq $ReleaseKey -and $_.objectName -eq "$Schema.$ObjectName"
        } | Select-Object -Last 1

        if (-not $backup) {
            Write-Host "ERRO: Nenhum backup encontrado para $Schema.$ObjectName na release $ReleaseKey" -ForegroundColor Red
            Write-Host "  Backups disponiveis no manifest:" -ForegroundColor Yellow
            $manifest.backups | ForEach-Object {
                Write-Host "    - $($_.objectName) | $($_.releaseKey) | $($_.backupType)" -ForegroundColor DarkGray
            }
            exit 1
        }

        $backupFile = Join-Path $repoRoot $backup.backupFile

        Write-Host ""
        Write-Host "=== ROLLBACK PROD: $ReleaseKey ===" -ForegroundColor Red
        Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Backup: $($backup.backupFile)" -ForegroundColor DarkGray
        Write-Host "  Tipo:   $($backup.backupType)" -ForegroundColor DarkGray
        Write-Host ""

        if ($backup.backupType -eq "new-object") {
            # Objeto novo - basta DROP
            $typeMap = @{
                "VIEW"      = "VIEW"
                "PROCEDURE" = "PROCEDURE"
                "TABLE"     = "TABLE"
                "FUNCTION"  = "FUNCTION"
                "TRIGGER"   = "TRIGGER"
            }
            $dropType = $typeMap[$ObjectType]
            if (-not $dropType) { $dropType = "VIEW" }

            $rollbackDDL = @"
-- ROLLBACK: Objeto novo - DROP
-- Release: $ReleaseKey
-- Objeto:  [$Schema].[$ObjectName] ($ObjectType)
IF OBJECT_ID('$Schema.$ObjectName', '$($typeMap[$ObjectType].Substring(0,1))') IS NOT NULL
    DROP $dropType [$Schema].[$ObjectName];
"@

            Write-Host "DDL DE ROLLBACK (executar via mssql-prod.execute_ddl):" -ForegroundColor Yellow
            Write-Host ""
            Write-Host $rollbackDDL -ForegroundColor Gray
            Write-Host ""
            Write-Host "Este objeto era novo (nao existia antes do deploy)." -ForegroundColor DarkGray
            Write-Host "Rollback = DROP. Nao ha versao anterior para restaurar." -ForegroundColor DarkGray
        }
        else {
            # Objeto existente - restaurar definicao do backup
            if (-not (Test-Path $backupFile)) {
                Write-Host "ERRO: Arquivo de backup nao encontrado: $backupFile" -ForegroundColor Red
                exit 1
            }

            $backupContent = Get-Content $backupFile -Raw

            # Extrai a definicao (remove o cabecalho de backup)
            $lines = $backupContent -split "`n"
            $defLines = @()
            $inDefinition = $false
            foreach ($line in $lines) {
                if ($line -match "^--") { continue }
                $inDefinition = $true
                if ($inDefinition) { $defLines += $line }
            }
            $definition = ($defLines -join "`n").Trim()

            # Gera DDL de rollback baseado no tipo
            $rollbackDDL = @"
-- ROLLBACK: Restaurar definicao anterior
-- Release: $ReleaseKey
-- Objeto:  [$Schema].[$ObjectName] ($ObjectType)
-- Backup:  $($backup.backupFile)
-- Hash:    $($backup.hash)

-- Passo 1: DROP o objeto atual (modificado)
IF OBJECT_ID('$Schema.$ObjectName', '$($ObjectType.Substring(0,1))') IS NOT NULL
    DROP $ObjectType [$Schema].[$ObjectName];
GO

-- Passo 2: Recriar com a definicao do backup
$definition
GO
"@

            Write-Host "DDL DE ROLLBACK (executar via mssql-prod.execute_ddl):" -ForegroundColor Yellow
            Write-Host ""
            Write-Host $rollbackDDL -ForegroundColor Gray
            Write-Host ""
            Write-Host "Este objeto ja existia antes do deploy." -ForegroundColor DarkGray
            Write-Host "Rollback = restaurar definicao do backup (DROP + CREATE)." -ForegroundColor DarkGray
            Write-Host "Hash do backup: $($backup.hash)" -ForegroundColor DarkGray
        }

        Write-Host ""
        Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "  1. Executar o DDL acima no PROD via mssql-prod.execute_ddl" -ForegroundColor White
        Write-Host "  2. Executar smoke test novamente (smoke-test.ps1 -Action generate)" -ForegroundColor White
        Write-Host "  3. Registrar resultado (rollback-prod.ps1 -Action record)" -ForegroundColor White
        Write-Host "  4. Notificar o desenvolvedor" -ForegroundColor White
    }

    "record" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $RollbackResult) {
            Write-Host "ERRO: ReleaseKey, ObjectName e RollbackResult sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        # Registra no log
        $log = Get-Content $rollbackLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey     = $ReleaseKey
            objectName     = "$Schema.$ObjectName"
            objectType     = $ObjectType
            result         = $RollbackResult
            rolledBackAt   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            rolledBackBy   = $env:USERNAME
        }
        $log.rollbacks = @($log.rollbacks + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $rollbackLogPath -Encoding utf8

        if ($RollbackResult -eq "success") {
            Write-Host "ROLLBACK: SUCESSO." -ForegroundColor Green
            Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
            Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
            Write-Host "  Objeto restaurado para a versao anterior." -ForegroundColor Green
            Write-Host ""
            Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
            Write-Host "    1. Registrar falha no audit log (deploy-prod.ps1 -Action apply)" -ForegroundColor White
            Write-Host "    2. Notificar o desenvolvedor" -ForegroundColor White
            Write-Host "    3. Investigar causa do smoke test fail" -ForegroundColor White
        } else {
            Write-Host "ROLLBACK: FALHOU." -ForegroundColor Red
            Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
            Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  *** INTERVENCAO MANUAL NECESSARIA ***" -ForegroundColor Red
            Write-Host "  O rollback automatico nao conseguiu restaurar o objeto." -ForegroundColor Red
            Write-Host "  Acoes:" -ForegroundColor Yellow
            Write-Host "    1. Verificar o estado do objeto no PROD" -ForegroundColor White
            Write-Host "    2. Restaurar manualmente via backup em backups/prod/" -ForegroundColor White
            Write-Host "    3. Notificar o time imediatamente" -ForegroundColor White
            Write-Host "    4. Investigar causa do falha do rollback" -ForegroundColor White
        }
    }

    "status" {
        $log = Get-Content $rollbackLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== ROLLBACK LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.rollbacks.Count -eq 0) {
            Write-Host "  Nenhum rollback registrado." -ForegroundColor DarkGray
            return
        }

        foreach ($r in $log.rollbacks) {
            $color = if ($r.result -eq "success") { "Green" } else { "Red" }
            Write-Host "  [$($r.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:    $($r.objectName) ($($r.objectType))" -ForegroundColor White
            Write-Host "    Resultado: $($r.result)" -ForegroundColor $color
            Write-Host "    Revertido: $($r.rolledBackAt)" -ForegroundColor DarkGray
            Write-Host "    Por:       $($r.rolledBackBy)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
