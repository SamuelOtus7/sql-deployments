<#
.SYNOPSIS
    Gera e consulta o manifest de releases publicadas em PROD.
.DESCRIPTION
    scripts/manifest.json e o registro estruturado de todas as releases
    publicadas em PROD. Cada entrada contem:
    - releaseKey, task, objeto, tipo, forward, rollback
    - publicado por, quando, status (published/rolled-back)
    - backup criado, smoke test, validacoes executadas

    Este script consolida informacoes de todos os logs de runtime:
    - prod-audit.json (deploys em PROD)
    - impact-log.json (analises de impacto)
    - review-log.json (code reviews)
    - dry-run-log.json (dry-runs no QAS)
    - validation-log.json (validacoes de negocio)
    - drift-log.json (drift checks)
    - hotfix-log.json (hotfixes)

.PARAMETER Action
    add:      adiciona uma entrada ao manifest (apos deploy em PROD)
    list:     lista todas as releases publicadas
    show:     mostra detalhes de uma release especifica
    summary:  mostra resumo consolidado (total, publicadas, rolled-back, pendentes)

.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)

.PARAMETER TaskId
    ID da task ClickUp

.PARAMETER ObjectName
    Nome do objeto publicado

.PARAMETER ObjectType
    Tipo do objeto

.PARAMETER ForwardScript
    Caminho do script forward

.PARAMETER RollbackScript
    Caminho do script rollback

.PARAMETER Status
    Status da release: published ou rolled-back

.PARAMETER BackupFile
    Arquivo de backup criado

.PARAMETER SmokeResult
    Resultado do smoke test: pass ou fail

.EXAMPLE
    .\manifest.ps1 -Action add -ReleaseKey r20260914-CU8888-a1b2c3d -TaskId CU-8888 -ObjectName vw_teste -ObjectType VIEW -ForwardScript scripts/forward/2026/09/001_forward_CU8888_teste.sql -RollbackScript scripts/rollback/2026/09/001_rollback_CU8888_teste.sql -Status published -BackupFile backups/prod/vw_teste_20260914.sql -SmokeResult pass
    .\manifest.ps1 -Action list
    .\manifest.ps1 -Action show -ReleaseKey r20260914-CU8888-a1b2c3d
    .\manifest.ps1 -Action summary
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("add","list","show","summary")]
    [string]$Action,

    [string]$ReleaseKey = "",
    [string]$TaskId = "",
    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ForwardScript = "",
    [string]$RollbackScript = "",
    [ValidateSet("published","rolled-back")]
    [string]$Status = "",
    [string]$BackupFile = "",
    [ValidateSet("pass","fail")]
    [string]$SmokeResult = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$manifestPath = Join-Path $repoRoot "scripts\manifest.json"

if (-not (Test-Path $manifestPath)) {
    '{"version":"1.0","lastUpdated":null,"releases":[]}' | Set-Content -Path $manifestPath -Encoding utf8
}

switch ($Action) {
    "add" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $Status) {
            Write-Host "ERRO: ReleaseKey, ObjectName e Status sao obrigatorios para add." -ForegroundColor Red
            exit 1
        }

        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

        # Remove entrada anterior para esta release (se existir)
        $manifest.releases = @($manifest.releases | Where-Object { $_.releaseKey -ne $ReleaseKey })

        $entry = [PSCustomObject]@{
            releaseKey      = $ReleaseKey
            taskId          = $TaskId
            objectName      = $ObjectName
            objectType      = $ObjectType
            forwardScript   = $ForwardScript
            rollbackScript  = $RollbackScript
            status          = $Status
            backupFile      = $BackupFile
            smokeResult      = $SmokeResult
            publishedAt     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            publishedBy      = $env:USERNAME
        }

        $manifest.releases = @($manifest.releases + $entry)
        $manifest.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding utf8

        $color = if ($Status -eq "published") { "Green" } else { "Red" }
        Write-Host "RELEASE REGISTRADA NO MANIFEST: $Status" -ForegroundColor $color
        Write-Host "  Release:   $ReleaseKey" -ForegroundColor White
        Write-Host "  Task:      $TaskId" -ForegroundColor White
        Write-Host "  Objeto:    $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Forward:   $ForwardScript" -ForegroundColor DarkGray
        Write-Host "  Rollback:  $RollbackScript" -ForegroundColor DarkGray
        Write-Host "  Backup:    $BackupFile" -ForegroundColor DarkGray
        Write-Host "  Smoke:     $SmokeResult" -ForegroundColor $(if ($SmokeResult -eq "pass") { "Green" } else { "Red" })
        Write-Host "  Status:    $Status" -ForegroundColor $color
        Write-Host "  Por:       $env:USERNAME" -ForegroundColor DarkGray
        Write-Host "  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')" -ForegroundColor DarkGray
    }

    "list" {
        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== MANIFEST DE RELEASES ===" -ForegroundColor Cyan
        Write-Host ""

        if ($manifest.releases.Count -eq 0) {
            Write-Host "  Nenhuma release registrada." -ForegroundColor DarkGray
            return
        }

        foreach ($r in $manifest.releases) {
            $color = if ($r.status -eq "published") { "Green" } else { "Red" }
            Write-Host "  [$($r.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Task:      $($r.taskId)" -ForegroundColor White
            Write-Host "    Objeto:    $($r.objectName) ($($r.objectType))" -ForegroundColor White
            Write-Host "    Forward:   $($r.forwardScript)" -ForegroundColor DarkGray
            Write-Host "    Rollback:  $($r.rollbackScript)" -ForegroundColor DarkGray
            Write-Host "    Backup:    $($r.backupFile)" -ForegroundColor DarkGray
            Write-Host "    Smoke:     $($r.smokeResult)" -ForegroundColor $(if ($r.smokeResult -eq "pass") { "Green" } else { "Red" })
            Write-Host "    Status:    $($r.status)" -ForegroundColor $color
            Write-Host "    Publicado: $($r.publishedAt)" -ForegroundColor DarkGray
            Write-Host "    Por:       $($r.publishedBy)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }

    "show" {
        if (-not $ReleaseKey) {
            Write-Host "ERRO: ReleaseKey e obrigatorio para show." -ForegroundColor Red
            exit 1
        }

        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
        $release = $manifest.releases | Where-Object { $_.releaseKey -eq $ReleaseKey } | Select-Object -First 1

        if (-not $release) {
            Write-Host "Release '$ReleaseKey' nao encontrada no manifest." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== DETALHES DA RELEASE: $ReleaseKey ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Task ClickUp:  $($release.taskId)" -ForegroundColor White
        Write-Host "  Objeto:        $($release.objectName) ($($release.objectType))" -ForegroundColor White
        Write-Host "  Forward:       $($release.forwardScript)" -ForegroundColor DarkGray
        Write-Host "  Rollback:      $($release.rollbackScript)" -ForegroundColor DarkGray
        Write-Host "  Backup:        $($release.backupFile)" -ForegroundColor DarkGray
        Write-Host "  Smoke test:    $($release.smokeResult)" -ForegroundColor $(if ($release.smokeResult -eq "pass") { "Green" } else { "Red" })
        Write-Host "  Status:        $($release.status)" -ForegroundColor $(if ($release.status -eq "published") { "Green" } else { "Red" })
        Write-Host "  Publicado em:   $($release.publishedAt)" -ForegroundColor DarkGray
        Write-Host "  Publicado por:  $($release.publishedBy)" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  COMO FAZER ROLLBACK:" -ForegroundColor Cyan
        if ($release.rollbackScript) {
            Write-Host "    1. Executar rollback script: $($release.rollbackScript)" -ForegroundColor White
        }
        if ($release.backupFile) {
            Write-Host "    2. Restaurar backup: $($release.backupFile)" -ForegroundColor White
        }
        Write-Host "    3. Ou via rollback-prod.ps1 -Action generate -ReleaseKey $ReleaseKey" -ForegroundColor White
    }

    "summary" {
        $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
        $total = $manifest.releases.Count
        $published = ($manifest.releases | Where-Object { $_.status -eq "published" }).Count
        $rolledBack = ($manifest.releases | Where-Object { $_.status -eq "rolled-back" }).Count

        Write-Host ""
        Write-Host "=== RESUMO DO MANIFEST ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Total de releases:    $total" -ForegroundColor White
        Write-Host "  Publicadas (ativas):  $published" -ForegroundColor Green
        Write-Host "  Revertidas (rolled-back): $rolledBack" -ForegroundColor Red
        Write-Host ""

        if ($total -gt 0) {
            # Ultimas 5 releases
            $recent = $manifest.releases | Select-Object -Last 5
            Write-Host "  ULTIMAS 5 RELEASES:" -ForegroundColor Cyan
            foreach ($r in $recent) {
                $color = if ($r.status -eq "published") { "Green" } else { "Red" }
                Write-Host "    [$($r.releaseKey)] $($r.objectName) - $($r.status)" -ForegroundColor $color
            }
        }
    }
}
