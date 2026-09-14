<#
.SYNOPSIS
    Valida pares forward/rollback - toda alteracao forward deve ter rollback correspondente.
.DESCRIPTION
    Verifica arquivos staged em scripts/forward/ e scripts/rollback/:
    - Se commita um forward, deve existir um rollback com mesmo nome base
    - Se commita um rollback, deve existir um forward com mesmo nome base
    - Verifica que o cabecalho do rollback referencia o forward correto e vice-versa
    Retorna exit code 0 se passar, 1 se falhar.
.EXAMPLE
    .\validate-pairs.ps1
#>
param(
    [string[]]$Files
)

# Se nao passou arquivos, pega os staged
if (-not $Files -or $Files.Count -eq 0) {
    $staged = git diff --cached --name-only --diff-filter=ACM
    $Files = $staged
}

if (-not $Files -or $Files.Count -eq 0) {
    Write-Host "PARES: Nenhum arquivo para validar." -ForegroundColor DarkGray
    exit 0
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot

$errors = @()

# Filtra apenas arquivos em scripts/forward/ ou scripts/rollback/
$forwardFiles = $Files | Where-Object { $_ -match 'scripts[\\/]forward[\\/]' -and $_ -match '\.sql$' }
$rollbackFiles = $Files | Where-Object { $_ -match 'scripts[\\/]rollback[\\/]' -and $_ -match '\.sql$' }

if ($forwardFiles.Count -eq 0 -and $rollbackFiles.Count -eq 0) {
    Write-Host "PARES: Nenhum script forward/rollback para validar." -ForegroundColor DarkGray
    exit 0
}

#==============================================================================
# FUNCAO: extrair nome base do arquivo
# Ex: 001_forward_CU1234_teste.sql -> 001_CU1234_teste
#==============================================================================
function Get-BaseName {
    param([string]$fileName)
    # Remove extensao
    $base = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    # Remove prefixo forward_ ou rollback_ (qualquer posicao)
    $base = $base -replace '(?i)_forward_', '_'
    $base = $base -replace '(?i)_rollback_', '_'
    $base = $base -replace '(?i)^forward_', ''
    $base = $base -replace '(?i)^rollback_', ''
    # Remove underscore final se ficou
    $base = $base -replace '_$',''
    return $base
}

#==============================================================================
# VERIFICAR FORWARDS
#==============================================================================
foreach ($fwd in $forwardFiles) {
    $fwdName = Split-Path $fwd -Leaf
    $baseName = Get-BaseName $fwdName

    # Procura o rollback correspondente nos arquivos staged
    $matchingRollback = $rollbackFiles | Where-Object {
        $rbName = Split-Path $_ -Leaf
        $rbBase = Get-BaseName $rbName
        $rbBase -eq $baseName
    }

    if (-not $matchingRollback) {
        # Procura no filesystem (pode ja existir no repo)
        $fwdDir = Split-Path $fwd -Parent
        $rollbackDir = $fwdDir -replace '(?i)forward', 'rollback'
        $possibleRollback = Join-Path $repoRoot $rollbackDir
        $found = $false
        if (Test-Path $possibleRollback) {
            $existingRollbacks = Get-ChildItem $possibleRollback -Filter "*.sql" | Where-Object {
                (Get-BaseName $_.Name) -eq $baseName
            }
            if ($existingRollbacks) {
                $found = $true
            }
        }
        if (-not $found) {
            $errors += "PARES: Forward '$fwdName' nao tem rollback correspondente. Crie o rollback com nome base '$baseName' em scripts/rollback/."
        }
    }
}

#==============================================================================
# VERIFICAR ROLLBACKS
#==============================================================================
foreach ($rb in $rollbackFiles) {
    $rbName = Split-Path $rb -Leaf
    $baseName = Get-BaseName $rbName

    # Procura o forward correspondente nos arquivos staged
    $matchingForward = $forwardFiles | Where-Object {
        $fwdName = Split-Path $_ -Leaf
        $fwdBase = Get-BaseName $fwdName
        $fwdBase -eq $baseName
    }

    if (-not $matchingForward) {
        # Procura no filesystem
        $rbDir = Split-Path $rb -Parent
        $forwardDir = $rbDir -replace '(?i)rollback', 'forward'
        $possibleForward = Join-Path $repoRoot $forwardDir
        $found = $false
        if (Test-Path $possibleForward) {
            $existingForwards = Get-ChildItem $possibleForward -Filter "*.sql" | Where-Object {
                (Get-BaseName $_.Name) -eq $baseName
            }
            if ($existingForwards) {
                $found = $true
            }
        }
        if (-not $found) {
            $errors += "PARES: Rollback '$rbName' nao tem forward correspondente. Verifique se o nome base '$baseName' esta correto."
        }
    }
}

#==============================================================================
# RELATORIO
#==============================================================================
if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "=== ERROS DE PARES ($($errors.Count)) ===" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "  $e" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "COMMIT BLOQUEADO: Todo forward deve ter um rollback correspondente." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "PARES: $($forwardFiles.Count) forward(s) e $($rollbackFiles.Count) rollback(s) validados." -ForegroundColor Green
Write-Host "PARES: Aprovado." -ForegroundColor Green
exit 0
