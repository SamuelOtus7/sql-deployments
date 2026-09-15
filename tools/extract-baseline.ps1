<#
.SYNOPSIS
    Extrai objetos de um dump SQL do SSMS e organiza em arquivos individuais.
.DESCRIPTION
    Le um arquivo .sql gerado pelo SSMS (Script Database) e extrai cada objeto
    (procedure, view, function, table, trigger) em seu proprio arquivo .sql,
    organizado por tipo em scripts/baseline/.
.PARAMETER DumpFile
    Caminho do arquivo .sql gerado pelo SSMS.
.PARAMETER OutputRoot
    Pasta raiz onde os arquivos serao criados (default: scripts/baseline/ no repo).
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$DumpFile,

    [string]$OutputRoot = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
if (-not $OutputRoot) {
    $OutputRoot = Join-Path $repoRoot "scripts\baseline"
}

if (-not (Test-Path $DumpFile)) {
    Write-Host "ERRO: Arquivo nao encontrado: $DumpFile" -ForegroundColor Red
    exit 1
}

# Tipos de objeto a extrair (mapeamento SSMS type -> pasta)
$typeMap = @{
    "StoredProcedure"   = "procedures"
    "View"              = "views"
    "UserDefinedFunction" = "functions"
    "Table"             = "tables"
    "DdlTrigger"        = "triggers"
    "Trigger"           = "triggers"
}

# Cria pastas
foreach ($folder in $typeMap.Values | Select-Object -Unique) {
    $dir = Join-Path $OutputRoot $folder
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "Extraindo objetos de: $DumpFile" -ForegroundColor Cyan
Write-Host "Destino: $OutputRoot" -ForegroundColor Cyan
Write-Host ""

# Le o arquivo
$lines = Get-Content $DumpFile
$totalLines = $lines.Count
Write-Host "Total de linhas: $totalLines" -ForegroundColor DarkGray

# Regex para o cabecalho do SSMS
# Ex: /****** Object:  StoredProcedure [dbo].[UspXxx]    Script Date: ... ******/
$headerRegex = '/\*\*\*\*\*\* Object:\s+(\w+)\s+\[([^\]]+)\]\.\[([^\]]+)\]'

$currentType = ""
$currentSchema = ""
$currentName = ""
$currentLines = @()
$extractedCount = 0
$skippedCount = 0
$stats = @{}

function Save-Object($type, $schema, $name, $contentLines) {
    $folder = $typeMap[$type]
    if (-not $folder) { return $false }

    # Limpa o nome do objeto (remove caracteres invalidos para nome de arquivo)
    $safeName = $name -replace '[<>:"/\\|?*]', '_'
    $fileName = "$safeName.sql"
    $filePath = Join-Path (Join-Path $script:OutputRoot $folder) $fileName

    # Cabecalho do arquivo
    $header = @"
-- ============================================================
-- BASELINE: $schema.$name
-- Tipo: $type
-- Schema: $schema
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================

"@

    $content = $header + ($contentLines -join "`r`n")
    Set-Content -Path $filePath -Value $content -Encoding utf8 -NoNewline
    Add-Content -Path $filePath -Value "" -Encoding utf8

    return $true
}

$script:OutputRoot = $OutputRoot

for ($i = 0; $i -lt $totalLines; $i++) {
    $line = $lines[$i]

    # Verifica se e um cabecalho de objeto
    if ($line -match $headerRegex) {
        # Salva o objeto anterior se existir
        if ($currentType -ne "" -and $currentName -ne "") {
            if ($typeMap.ContainsKey($currentType)) {
                $saved = Save-Object $currentType $currentSchema $currentName $currentLines
                if ($saved) {
                    $extractedCount++
                    $folder = $typeMap[$currentType]
                    if (-not $stats.ContainsKey($folder)) { $stats[$folder] = 0 }
                    $stats[$folder]++
                }
            } else {
                $skippedCount++
            }
        }

        # Inicia novo objeto
        $currentType = $Matches[1]
        $currentSchema = $Matches[2]
        $currentName = $Matches[3]
        $currentLines = @($line)
    } else {
        if ($currentType -ne "") {
            $currentLines += $line
        }
    }
}

# Salva o ultimo objeto
if ($currentType -ne "" -and $currentName -ne "") {
    if ($typeMap.ContainsKey($currentType)) {
        $saved = Save-Object $currentType $currentSchema $currentName $currentLines
        if ($saved) {
            $extractedCount++
            $folder = $typeMap[$currentType]
            if (-not $stats.ContainsKey($folder)) { $stats[$folder] = 0 }
            $stats[$folder]++
        }
    } else {
        $skippedCount++
    }
}

Write-Host ""
Write-Host "=== EXTRAACAO CONCLUIDA ===" -ForegroundColor Green
Write-Host "  Objetos extraidos: $extractedCount" -ForegroundColor Green
Write-Host "  Objetos ignorados: $skippedCount (Users, Indexes, Schemas, etc)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Por tipo:" -ForegroundColor Cyan
foreach ($folder in ($stats.Keys | Sort-Object)) {
    Write-Host "    $folder : $($stats[$folder]) arquivos" -ForegroundColor White
}
