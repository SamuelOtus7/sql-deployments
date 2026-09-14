<#
.SYNOPSIS
    Lint SQL Server - valida scripts contra as regras do framework Otus7.
.DESCRIPTION
    Verifica arquivos .sql staged no Git contra as regras:
    - sql-seguranca-tsql: sem UPDATE/DELETE sem WHERE, sem SELECT *, sem MERGE sem justificativa
    - sql-validacao-rollback: cabecalho com task ClickUp, autor, rollback ref
    - sql-fluxo-principal: SET NOCOUNT ON, TRY/CATCH
    Retorna exit code 0 se passar, 1 se falhar.
.PARAMETER Files
    Lista de arquivos .sql para validar. Se vazio, pega os staged.
.EXAMPLE
    .\sql-lint.ps1 -Files scripts/forward/2026/09/001_forward_CU1234_teste.sql
#>
param(
    [string[]]$Files
)

# Se nao passou arquivos, pega os staged
if (-not $Files -or $Files.Count -eq 0) {
    $staged = git diff --cached --name-only --diff-filter=ACM | Where-Object { $_ -match '\.sql$' }
    $Files = $staged
}

# Filtra apenas arquivos .sql (ignora .ps1, .sh, etc que possam ter sido passados)
$Files = $Files | Where-Object { $_ -match '\.sql$' }

# Ignora arquivos de template (nao sao scripts de producao)
$Files = $Files | Where-Object { $_ -notmatch 'templates[\\/]'}

if (-not $Files -or $Files.Count -eq 0) {
    Write-Host "LINT: Nenhum arquivo .sql para validar." -ForegroundColor DarkGray
    exit 0
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot

$errors = @()
$warnings = @()

foreach ($file in $Files) {
    $fullPath = if (Test-Path $file) { $file } else { Join-Path $repoRoot $file }

    if (-not (Test-Path $fullPath)) {
        continue
    }

    $content = Get-Content $fullPath -Raw
    $fileName = Split-Path $file -Leaf
    $relPath = $file

    #==========================================================================
    # REGRA 1: SET NOCOUNT ON (sql-fluxo-principal)
    #==========================================================================
    if ($content -notmatch '(?i)SET\s+NOCOUNT\s+ON') {
        $errors += "[$relPath] ERRO: SET NOCOUNT ON ausente. Adicione no inicio do script."
    }

    #==========================================================================
    # REGRA 2: TRY/CATCH (sql-fluxo-principal)
    #==========================================================================
    if ($content -notmatch '(?i)BEGIN\s+TRY') {
        $errors += "[$relPath] ERRO: BEGIN TRY ausente. Todo script deve ter tratamento de erro."
    }
    if ($content -notmatch '(?i)BEGIN\s+CATCH') {
        $errors += "[$relPath] ERRO: BEGIN CATCH ausente. Todo script deve ter tratamento de erro."
    }

    #==========================================================================
    # REGRA 3: Cabecalho com Task ClickUp (sql-fluxo-principal)
    #==========================================================================
    if ($content -notmatch '(?i)Task\s+ClickUp\s*:\s*CU-') {
        $errors += "[$relPath] ERRO: Cabecalho sem Task ClickUp. Adicione 'Task ClickUp : CU-XXXXX'."
    }

    #==========================================================================
    # REGRA 4: Autor no cabecalho (sql-fluxo-principal)
    #==========================================================================
    if ($content -notmatch '(?i)Autor\s*:\s*\S') {
        $errors += "[$relPath] ERRO: Cabecalho sem Autor. Adicione 'Autor : [seu nome]'."
    }

    #==========================================================================
    # REGRA 5: Rollback ref no cabecalho (sql-validacao-rollback)
    #==========================================================================
    # Forward deve ter "Rollback :" apontando para o rollback
    # Rollback deve ter "Forward ref :" apontando para o forward
    if ($file -match 'forward') {
        if ($content -notmatch '(?i)Rollback\s*:\s*\S') {
            $errors += "[$relPath] ERRO: Forward sem referencia de Rollback no cabecalho. Adicione 'Rollback : scripts/rollback/...'."
        }
    }
    elseif ($file -match 'rollback') {
        if ($content -notmatch '(?i)Forward\s+ref\s*:\s*\S') {
            $errors += "[$relPath] ERRO: Rollback sem referencia de Forward no cabecalho. Adicione 'Forward ref : scripts/forward/...'."
        }
    }

    #==========================================================================
    # REGRA 6: Sem SELECT * (sql-seguranca-tsql)
    #==========================================================================
    $selectStarMatches = [regex]::Matches($content, '(?i)\bSELECT\s+\*')
    foreach ($match in $selectStarMatches) {
        $lineNum = ($content.Substring(0, $match.Index) -split "`n").Count
        $warnings += "[$relPath] AVISO linha ${lineNum}: SELECT * detectado. Especifique as colunas."
    }

    #==========================================================================
    # REGRA 7: UPDATE sem WHERE (sql-seguranca-tsql)
    #==========================================================================
    # Pega linhas com UPDATE ... SET ... que nao tem WHERE na mesma linha ou proxima
    $lines = $content -split "`n"
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '(?i)^\s*UPDATE\s+\S+' -and $lines[$i] -notmatch '(?i)\bWHERE\b') {
            # Procura WHERE nas proximas 10 linhas
            $hasWhere = $false
            for ($j = $i + 1; $j -lt [math]::Min($i + 10, $lines.Count); $j++) {
                if ($lines[$j] -match '(?i)\bWHERE\b') {
                    $hasWhere = $true
                    break
                }
                # Se chegou em GO ou ; sem WHERE, bloqueia
                if ($lines[$j] -match '(?i)^\s*GO\s*$' -or $lines[$j] -match ';\s*$') {
                    break
                }
            }
            if (-not $hasWhere) {
                $errors += "[$relPath] ERRO linha $($i+1): UPDATE sem WHERE detectado. Toda alteracao de dados deve ter escopo controlado."
            }
        }
    }

    #==========================================================================
    # REGRA 8: DELETE sem WHERE (sql-seguranca-tsql)
    #==========================================================================
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '(?i)^\s*DELETE\s+(FROM\s+)?\S+' -and $lines[$i] -notmatch '(?i)\bWHERE\b') {
            $hasWhere = $false
            for ($j = $i + 1; $j -lt [math]::Min($i + 10, $lines.Count); $j++) {
                if ($lines[$j] -match '(?i)\bWHERE\b') {
                    $hasWhere = $true
                    break
                }
                if ($lines[$j] -match '(?i)^\s*GO\s*$' -or $lines[$j] -match ';\s*$') {
                    break
                }
            }
            if (-not $hasWhere) {
                $errors += "[$relPath] ERRO linha $($i+1): DELETE sem WHERE detectado. Toda remocao de dados deve ter escopo controlado."
            }
        }
    }

    #==========================================================================
    # REGRA 9: MERGE sem justificativa (sql-seguranca-tsql)
    #==========================================================================
    $mergeMatches = [regex]::Matches($content, '(?i)\bMERGE\b')
    foreach ($match in $mergeMatches) {
        $lineNum = ($content.Substring(0, $match.Index) -split "`n").Count
        # Procura justificativa nas 5 linhas anteriores
        $startLine = [math]::Max(0, $lineNum - 6)
        $context = $lines[$startLine..($lineNum - 1)] -join " "
        if ($context -notmatch '(?i)justif|intencional|risco.*chave|comentario.*merge') {
            $warnings += "[$relPath] AVISO linha ${lineNum}: MERGE detectado sem justificativa. Adicione comentario explicando o risco de chave duplicada."
        }
    }

    #==========================================================================
    # REGRA 10: NOLOCK sem justificativa (sql-seguranca-tsql)
    #==========================================================================
    $nolockMatches = [regex]::Matches($content, '(?i)\bNOLOCK\b|WITH\s*\(\s*NOLOCK\s*\)')
    foreach ($match in $nolockMatches) {
        $lineNum = ($content.Substring(0, $match.Index) -split "`n").Count
        # Procura justificativa na mesma linha
        if ($lines[$lineNum - 1] -notmatch '(?i)justif|intencional|dirty\s*read|aceitavel') {
            $warnings += "[$relPath] AVISO linha ${lineNum}: NOLOCK sem justificativa. Adicione comentario explicando por que dirty read e aceitavel."
        }
    }

    #==========================================================================
    # REGRA 11: Funcao em coluna no WHERE - nao-sargable (sql-seguranca-tsql)
    #==========================================================================
    $nonSargablePatterns = @(
        '(?i)WHERE\s+CONVERT\s*\(',
        '(?i)WHERE\s+CAST\s*\(',
        '(?i)WHERE\s+ISNULL\s*\(',
        '(?i)WHERE\s+SUBSTRING\s*\(',
        '(?i)WHERE\s+LEFT\s*\(',
        '(?i)WHERE\s+RIGHT\s*\(',
        '(?i)WHERE\s+UPPER\s*\(',
        '(?i)WHERE\s+LOWER\s*\(',
        '(?i)WHERE\s+DATEDIFF\s*\(',
        '(?i)WHERE\s+DATEADD\s*\('
    )
    foreach ($pattern in $nonSargablePatterns) {
        $matches2 = [regex]::Matches($content, $pattern)
        foreach ($match in $matches2) {
            $lineNum = ($content.Substring(0, $match.Index) -split "`n").Count
            $warnings += "[$relPath] AVISO linha ${lineNum}: Funcao aplicada em coluna no WHERE (nao-sargable). Considere range sobre a coluna para usar indice."
        }
    }
}

#==============================================================================
# RELATORIO
#==============================================================================
if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "=== AVISOS DE LINT ===" -ForegroundColor Yellow
    foreach ($w in $warnings) {
        Write-Host "  $w" -ForegroundColor Yellow
    }
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "=== ERROS DE LINT ($($errors.Count)) ===" -ForegroundColor Red
    foreach ($e in $errors) {
        Write-Host "  $e" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "COMMIT BLOQUEADO: Corrija os erros acima e tente novamente." -ForegroundColor Red
    Write-Host "Avisos nao bloqueiam o commit, mas devem ser revisados." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "LINT: $($Files.Count) arquivo(s) validado(s)." -ForegroundColor Green
if ($warnings.Count -gt 0) {
    Write-Host "LINT: $($warnings.Count) aviso(s) para revisar." -ForegroundColor Yellow
}
Write-Host "LINT: Aprovado." -ForegroundColor Green
exit 0
