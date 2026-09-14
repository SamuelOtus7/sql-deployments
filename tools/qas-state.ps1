<#
.SYNOPSIS
    Gerencia o estado QAS - registra e consulta scripts aplicados no QAS mas nao no PROD.
.DESCRIPTION
    Comandos:
    - add:    Registra um script aplicado no QAS
    - list:   Lista scripts em andamento (no QAS mas nao no PROD)
    - remove: Remove um script do estado (apos publicar no PROD)
    - clear:  Limpa todo o estado (apos refresh do QAS)
    - show:   Mostra o estado completo
.PARAMETER Action
    add | list | remove | clear | show
.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)
.PARAMETER ForwardScript
    Caminho do script forward aplicado
.PARAMETER RollbackScript
    Caminho do script rollback correspondente
.PARAMETER ObjectHash
    Hash do objeto apos aplicacao (para deteccao de conflito no refresh)
.PARAMETER ObjectName
    Nome do objeto criado/alterado (ex: vw_teste, UspFinGeraPagamento)
.EXAMPLE
    .\qas-state.ps1 -Action add -ReleaseKey r20260914-CU8888-a1b2c3d -ForwardScript scripts/forward/2026/09/001_forward_CU8888_teste.sql -RollbackScript scripts/rollback/2026/09/001_rollback_CU8888_teste.sql -ObjectName vw_teste -ObjectHash abc123
    .\qas-state.ps1 -Action list
    .\qas-state.ps1 -Action remove -ReleaseKey r20260914-CU8888-a1b2c3d
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("add","list","remove","clear","show")]
    [string]$Action,

    [string]$ReleaseKey = "",
    [string]$ForwardScript = "",
    [string]$RollbackScript = "",
    [string]$ObjectName = "",
    [string]$ObjectHash = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$statePath = Join-Path $repoRoot "scripts\qas-state.json"

# Garante que o arquivo existe
if (-not (Test-Path $statePath)) {
    '{"version":"1.0","lastUpdated":null,"scripts":[]}' | Set-Content -Path $statePath -Encoding utf8
}

# Le o estado atual
$state = Get-Content $statePath -Raw | ConvertFrom-Json

switch ($Action) {
    "add" {
        if (-not $ReleaseKey) {
            Write-Host "ERRO: ReleaseKey e obrigatorio para add." -ForegroundColor Red
            exit 1
        }

        # Verifica se ja existe
        $existing = $state.scripts | Where-Object { $_.releaseKey -eq $ReleaseKey }
        if ($existing) {
            Write-Host "AVISO: Release $ReleaseKey ja esta no estado QAS. Atualizando..." -ForegroundColor Yellow
            $state.scripts = $state.scripts | Where-Object { $_.releaseKey -ne $ReleaseKey }
        }

        # Monta a entrada
        $entry = [PSCustomObject]@{
            releaseKey      = $ReleaseKey
            forwardScript   = $ForwardScript
            rollbackScript  = $RollbackScript
            objectName      = $ObjectName
            objectHash      = $ObjectHash
            appliedAt       = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            status          = "applied-qas"
        }

        # Adiciona ao array
        $state.scripts = @($state.scripts + $entry)
        $state.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")

        # Salva
        $state | ConvertTo-Json -Depth 5 | Set-Content -Path $statePath -Encoding utf8

        Write-Host "QAS STATE: Script $ReleaseKey registrado como aplicado no QAS." -ForegroundColor Green
        Write-Host "  Objeto: $ObjectName" -ForegroundColor DarkGray
        Write-Host "  Forward: $ForwardScript" -ForegroundColor DarkGray
        Write-Host "  Rollback: $RollbackScript" -ForegroundColor DarkGray
    }

    "list" {
        if ($state.scripts.Count -eq 0) {
            Write-Host "QAS STATUS: Nenhum script em andamento." -ForegroundColor Green
            Write-Host "QAS e PROD estao alinhados." -ForegroundColor DarkGray
            exit 0
        }

        Write-Host ""
        Write-Host "=== QAS STATUS: $($state.scripts.Count) script(s) em andamento ===" -ForegroundColor Cyan
        Write-Host ""

        foreach ($s in $state.scripts) {
            Write-Host "  [$($s.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:     $($s.objectName)" -ForegroundColor White
            Write-Host "    Forward:    $($s.forwardScript)" -ForegroundColor DarkGray
            Write-Host "    Rollback:   $($s.rollbackScript)" -ForegroundColor DarkGray
            Write-Host "    Hash:       $($s.objectHash)" -ForegroundColor DarkGray
            Write-Host "    Aplicado em: $($s.appliedAt)" -ForegroundColor DarkGray
            Write-Host "    Status:     $($s.status)" -ForegroundColor Green
            Write-Host ""
        }

        Write-Host "Estes scripts estao no QAS mas ainda nao foram publicados no PROD." -ForegroundColor Yellow
        Write-Host "Apos publicar no PROD, use: qas-state.ps1 -Action remove -ReleaseKey <chave>" -ForegroundColor DarkGray
    }

    "remove" {
        if (-not $ReleaseKey) {
            Write-Host "ERRO: ReleaseKey e obrigatorio para remove." -ForegroundColor Red
            exit 1
        }

        $before = $state.scripts.Count
        $state.scripts = @($state.scripts | Where-Object { $_.releaseKey -ne $ReleaseKey })
        $after = $state.scripts.Count
        $state.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")

        $state | ConvertTo-Json -Depth 5 | Set-Content -Path $statePath -Encoding utf8

        if ($before -eq $after) {
            Write-Host "AVISO: Release $ReleaseKey nao encontrada no estado QAS." -ForegroundColor Yellow
        } else {
            Write-Host "QAS STATE: Release $ReleaseKey removida do estado (publicada no PROD)." -ForegroundColor Green
        }
    }

    "clear" {
        $state.scripts = @()
        $state.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $state | ConvertTo-Json -Depth 5 | Set-Content -Path $statePath -Encoding utf8
        Write-Host "QAS STATE: Estado limpo. Todos os scripts foram removidos do rastreamento." -ForegroundColor Green
        Write-Host "Use apos refresh do QAS para comecar rastreamento do zero." -ForegroundColor DarkGray
    }

    "show" {
        Write-Host ""
        Write-Host "=== QAS STATE (completo) ===" -ForegroundColor Cyan
        $state | ConvertTo-Json -Depth 5 | Write-Host
    }
}
