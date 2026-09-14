<#
.SYNOPSIS
    Gera chave de pesquisa para uma release e atualiza o changelog.
.DESCRIPTION
    Extrai o ID da task ClickUp do commit (formato CU-XXXXX), gera uma chave
    unica no formato rYYYYMMDD-CUXXXXX-<hash7> e atualiza changelog/CHANGELOG.md.
    Cria uma tag Git com a chave.
.PARAMETER CommitHash
    Hash do commit de merge (se vazio, pega o HEAD).
.EXAMPLE
    .\generate-key.ps1
    .\generate-key.ps1 -CommitHash abc1234
#>
param(
    [string]$CommitHash = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
Set-Location $repoRoot

# Se nao passou commit, pega o HEAD
if (-not $CommitHash) {
    $CommitHash = git rev-parse HEAD
}

# Pega o commit completo (hash + mensagem)
$commitInfo = git log -1 --format="%H%n%s%n%b" $CommitHash
$lines = $commitInfo -split "`n"
$fullHash = $lines[0]
$shortHash = $fullHash.Substring(0, 7)
$subject = $lines[1]
$body = $lines[2..($lines.Count - 1)] -join "`n"

# Extrai o ID da task ClickUp (CU-XXXXX)
$cuMatch = [regex]::Match("$subject $body", 'CU-(\d+)')
if ($cuMatch.Success) {
    $cuId = "CU" + $cuMatch.Groups[1].Value
} else {
    $cuId = "SEM-CU"
    Write-Host "AVISO: Nenhum ID de task ClickUp (CU-XXXXX) encontrado no commit." -ForegroundColor Yellow
}

# Gera a data no formato YYYYMMDD
$date = Get-Date -Format "yyyyMMdd"

# Monta a chave: rYYYYMMDD-CUXXXXX-<hash7>
$releaseKey = "r${date}-${cuId}-${shortHash}"

Write-Host ""
Write-Host "=== Gerando Release ===" -ForegroundColor Cyan
Write-Host "  Chave: $releaseKey" -ForegroundColor Green
Write-Host "  Commit: $shortHash" -ForegroundColor DarkGray
Write-Host "  Task: $cuId" -ForegroundColor DarkGray
Write-Host "  Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray
Write-Host "  Subject: $subject" -ForegroundColor DarkGray

#==============================================================================
# Atualiza CHANGELOG.md
#==============================================================================
$changelogPath = Join-Path $repoRoot "changelog\CHANGELOG.md"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"

$newEntry = @"

## $releaseKey

- **Data:** $timestamp
- **Task ClickUp:** $cuId
- **Commit:** $shortHash
- **Descrição:** $subject
- **Rollback:** Para reverter, usar a tag ``$releaseKey`` e executar o script de rollback correspondente.

"@

# Le o changelog atual e insere a nova entrada no topo (apos o cabecalho)
if (Test-Path $changelogPath) {
    $currentContent = Get-Content $changelogPath -Raw
    # Insere apos a primeira secao (linha em branco apos o cabecalho)
    $insertPosition = $currentContent.IndexOf("`n`n")
    if ($insertPosition -ge 0) {
        $updatedContent = $currentContent.Substring(0, $insertPosition + 2) + $newEntry + $currentContent.Substring($insertPosition + 2)
    } else {
        $updatedContent = $currentContent + $newEntry
    }
    $updatedContent | Out-File -FilePath $changelogPath -Encoding utf8 -NoNewline
} else {
    Write-Host "ERRO: changelog/CHANGELOG.md nao encontrado." -ForegroundColor Red
    exit 1
}

Write-Host "  Changelog atualizado: changelog/CHANGELOG.md" -ForegroundColor Green

#==============================================================================
# Cria a tag Git
#==============================================================================
try {
    git tag -a $releaseKey -m "Release $releaseKey - $cuId - $subject" 2>&1 | Out-Null
    Write-Host "  Tag criada: $releaseKey" -ForegroundColor Green
} catch {
    Write-Host "  AVISO: Nao foi possivel criar a tag (pode ja existir)." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Release gerada com sucesso ===" -ForegroundColor Green
Write-Host ""
Write-Host "Chave de pesquisa para ClickUp: $releaseKey" -ForegroundColor White
Write-Host ""
Write-Host "Para fazer rollback no futuro:" -ForegroundColor DarkGray
Write-Host "  1. Identifique a chave no ClickUp" -ForegroundColor DarkGray
Write-Host "  2. Use o comando: Rollback $releaseKey" -ForegroundColor DarkGray
Write-Host "  3. O agente encontra a tag, o commit e o script de rollback" -ForegroundColor DarkGray
