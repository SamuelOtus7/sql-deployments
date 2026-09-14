<#
.SYNOPSIS
    Backup automatizado de objeto no PROD antes do deploy.
.DESCRIPTION
    Esta ferramenta e executada PELO AGENTE (Devin) antes de aplicar DDL no PROD.
    O agente chama o MCP mssql-prod.execute_query para obter a definicao atual
    do objeto, e entao chama este script para salvar o resultado.

    Fluxo:
    1. Agente obtem a definicao do objeto via mssql-prod.execute_query
    2. Agente chama este script passando a definicao como parametro
    3. Script salva a definicao em backups/prod/<objeto>_<timestamp>.sql
    4. Script registra no manifest de backups (backups/prod/manifest.json)
    5. Se o objeto nao existir (novo objeto), registra como "new-object" (sem backup)

.PARAMETER ObjectName
    Nome do objeto (ex: vw_teste, UspFinGeraPagamento)

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)

.PARAMETER Definition
    Definicao atual do objeto (resultado do mssql-prod.execute_query).
    Se vazio, significa que o objeto e novo (nao existe no PROD ainda).

.PARAMETER Schema
    Schema do objeto (default: dbo)

.EXAMPLE
    .\backup-prod.ps1 -ObjectName vw_teste -ObjectType VIEW -ReleaseKey r20260914-CU8888-a1b2c3d -Definition "CREATE VIEW vw_teste AS SELECT 1"
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ObjectName,

    [Parameter(Mandatory=$true)]
    [string]$ObjectType,

    [Parameter(Mandatory=$true)]
    [string]$ReleaseKey,

    [string]$Definition = "",

    [string]$Schema = "dbo"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$backupDir = Join-Path $repoRoot "backups\prod"
$manifestPath = Join-Path $backupDir "manifest.json"

# Garante diretorio
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# Garante manifest
if (-not (Test-Path $manifestPath)) {
    '{"version":"1.0","lastUpdated":null,"backups":[]}' | Set-Content -Path $manifestPath -Encoding utf8
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$safeName = $ObjectName -replace '[^\w]', '_'
$backupFile = Join-Path $backupDir "${safeName}_${timestamp}.sql"

# Caso 1: objeto novo (nao existe no PROD)
if ([string]::IsNullOrWhiteSpace($Definition)) {
    $header = @"
-- BACKUP PROD - Objeto Novo
-- Objeto: [$Schema].[$ObjectName] ($ObjectType)
-- Release: $ReleaseKey
-- Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')
-- Status: NEW OBJECT (nao existia no PROD antes deste deploy)
-- Nao ha definicao anterior para salvar.
"@

    $header | Set-Content -Path $backupFile -Encoding utf8

    # Registra no manifest
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    $entry = [PSCustomObject]@{
        releaseKey    = $ReleaseKey
        objectName    = "$Schema.$ObjectName"
        objectType    = $ObjectType
        backupFile    = $backupFile.Replace($repoRoot + "\", "")
        backupType    = "new-object"
        timestamp     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        canRollback   = $false
    }
    $manifest.backups = @($manifest.backups + $entry)
    $manifest.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding utf8

    Write-Host "BACKUP PROD: Objeto novo detectado." -ForegroundColor Yellow
    Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
    Write-Host "  Status: NEW OBJECT - sem definicao anterior" -ForegroundColor DarkGray
    Write-Host "  Backup: $backupFile" -ForegroundColor DarkGray
    Write-Host "  Rollback: DROP o objeto (sem versao anterior para restaurar)" -ForegroundColor Yellow
    return
}

# Caso 2: objeto existe - salvar definicao atual
$header = @"
-- BACKUP PROD - Definicao anterior do objeto
-- Objeto: [$Schema].[$ObjectName] ($ObjectType)
-- Release: $ReleaseKey
-- Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')
-- Status: EXISTING OBJECT (definicao salva antes do deploy)
-- Para restaurar: executar a definicao abaixo via mssql-prod.execute_ddl
--   (se for ALTER, use ALTER; se for CREATE, drop e recrie)

"@

$content = $header + "`n" + $Definition
$content | Set-Content -Path $backupFile -Encoding utf8

# Calcula hash da definicao para verificacao de integridade
$hash = (Get-FileHash -Path $backupFile -Algorithm SHA256).Hash

# Registra no manifest
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$entry = [PSCustomObject]@{
    releaseKey    = $ReleaseKey
    objectName    = "$Schema.$ObjectName"
    objectType    = $ObjectType
    backupFile    = $backupFile.Replace($repoRoot + "\", "")
    backupType    = "existing-object"
    timestamp     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
    hash          = $hash
    canRollback   = $true
}
$manifest.backups = @($manifest.backups + $entry)
$manifest.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding utf8

Write-Host "BACKUP PROD: Definicao anterior salva com sucesso." -ForegroundColor Green
Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
Write-Host "  Backup: $backupFile" -ForegroundColor DarkGray
Write-Host "  Hash:  $hash" -ForegroundColor DarkGray
Write-Host "  Rollback: Restaurar definicao do backup via mssql-prod.execute_ddl" -ForegroundColor Green
