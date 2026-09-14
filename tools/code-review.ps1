<#
.SYNOPSIS
    Code review automatizado de scripts SQL antes do deploy em PROD.
.DESCRIPTION
    Diferente do lint do pre-commit (Fase 3), este roda no contexto do deploy
    e gera um veredito que bloqueia ou libera o deploy.

    Incorpora do framework Otus7:
    - checklists/data/sql-quality.md: SELECT explicito, aliases, JOINs, filtros, NULLs
    - rules/data/sql-standards.md: SARGable, NOCOUNT, CTEs, comentarios
    - checklists/data/query-performance.md: plano de execucao, indices, funcoes em colunas
    - checklists/data/join-cardinality.md: relacao 1:N, N:N, fan-out, bridge table
    - checklists/data/null-handling.md: ISNULL/COALESCE, LEFT vs INNER JOIN

.PARAMETER Action
    review:  revisa o script forward e gera veredito
    record:  registra o resultado da revisao no review-log
    status:  mostra historico de code reviews

.PARAMETER ForwardScript
    Caminho do script forward a revisar

.PARAMETER ObjectName
    Nome do objeto alvo

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER ReleaseKey
    Chave de release

.PARAMETER ReviewResult
    Resultado da revisao: approved | blocked | conditional (usado com -Action record)

.EXAMPLE
    .\code-review.ps1 -Action review -ForwardScript scripts/forward/2026/09/001_forward_CU8888_teste.sql -ObjectName vw_feriados -ObjectType VIEW -ReleaseKey r20260914-CU8888-a1b2c3d
    .\code-review.ps1 -Action record -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_feriados -ObjectType VIEW -ReviewResult approved
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("review","record","status")]
    [string]$Action,

    [string]$ForwardScript = "",
    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ReleaseKey = "",
    [ValidateSet("approved","blocked","conditional")]
    [string]$ReviewResult = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$reviewLogPath = Join-Path $repoRoot "scripts\review-log.json"

if (-not (Test-Path $reviewLogPath)) {
    '{"version":"1.0","lastUpdated":null,"reviews":[]}' | Set-Content -Path $reviewLogPath -Encoding utf8
}

switch ($Action) {
    "review" {
        if (-not $ForwardScript) {
            Write-Host "ERRO: ForwardScript e obrigatorio para review." -ForegroundColor Red
            exit 1
        }

        $fwdPath = Join-Path $repoRoot $ForwardScript
        if (-not (Test-Path $fwdPath)) {
            Write-Host "ERRO: Script forward nao encontrado: $ForwardScript" -ForegroundColor Red
            exit 1
        }

        $content = Get-Content $fwdPath -Raw
        $lines = $content -split "`n"

        Write-Host ""
        Write-Host "=== CODE REVIEW: $ObjectName ($ObjectType) ===" -ForegroundColor Cyan
        Write-Host "  Script:  $ForwardScript" -ForegroundColor DarkGray
        Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
        Write-Host "  Linhas:  $($lines.Count)" -ForegroundColor DarkGray
        Write-Host ""

        $errors = @()
        $warnings = @()
        $passed = @()

        # ===== 1. sql-quality.md: SELECT explicito =====
        Write-Host "  1. QUALIDADE SQL (checklists/data/sql-quality.md)" -ForegroundColor Cyan

        # SELECT *
        if ($content -match "(?i)SELECT\s+\*") {
            $warnings += "SELECT * encontrado (usar colunas explicitas)"
            Write-Host "     [AVISO] SELECT * encontrado" -ForegroundColor Yellow
        } else {
            $passed += "Sem SELECT *"
            Write-Host "     [OK] Sem SELECT *" -ForegroundColor Green
        }

        # Aliases legiveis
        $hasShortAlias = $false
        if ($content -match "(?i)\b[a-z]\b\s+AS\b") { $hasShortAlias = $true }
        if (-not $hasShortAlias) {
            $passed += "Aliases legiveis"
            Write-Host "     [OK] Aliases legiveis" -ForegroundColor Green
        } else {
            $warnings += "Alias muito curto detectado (usar aliases legiveis)"
            Write-Host "     [AVISO] Alias muito curto detectado" -ForegroundColor Yellow
        }

        # JOINs com condicao completa
        if ($content -match "(?i)JOIN\s+\[?\w+\]?\s*$") {
            $errors += "JOIN sem condicao ON detectado"
            Write-Host "     [ERRO] JOIN sem condicao ON" -ForegroundColor Red
        } else {
            $passed += "JOINs com condicao"
            Write-Host "     [OK] JOINs com condicao ON" -ForegroundColor Green
        }

        # NULLs tratados (null-handling.md)
        if ($content -match "(?i)LEFT\s+JOIN") {
            if ($content -match "(?i)ISNULL|COALESCE") {
                $passed += "NULLs tratados com ISNULL/COALESCE"
                Write-Host "     [OK] NULLs tratados (ISNULL/COALESCE)" -ForegroundColor Green
            } else {
                $warnings += "LEFT JOIN sem ISNULL/COALESCE (verificar tratamento de NULL)"
                Write-Host "     [AVISO] LEFT JOIN sem tratamento de NULL" -ForegroundColor Yellow
            }
        }

        # ===== 2. sql-standards.md: Padroes SQL =====
        Write-Host ""
        Write-Host "  2. PADROES SQL (rules/data/sql-standards.md)" -ForegroundColor Cyan

        # SET NOCOUNT ON
        if ($content -match "(?i)SET\s+NOCOUNT\s+ON") {
            $passed += "SET NOCOUNT ON presente"
            Write-Host "     [OK] SET NOCOUNT ON presente" -ForegroundColor Green
        } else {
            $errors += "SET NOCOUNT ON ausente (obrigatorio em procedures)"
            Write-Host "     [ERRO] SET NOCOUNT ON ausente" -ForegroundColor Red
        }

        # TRY/CATCH
        if ($content -match "(?i)BEGIN\s+TRY" -and $content -match "(?i)BEGIN\s+CATCH") {
            $passed += "TRY/CATCH presente"
            Write-Host "     [OK] TRY/CATCH presente" -ForegroundColor Green
        } else {
            $errors += "TRY/CATCH ausente (obrigatorio)"
            Write-Host "     [ERRO] TRY/CATCH ausente" -ForegroundColor Red
        }

        # Filtros de periodo explicitos
        if ($content -match "(?i)SELECT" -and $content -match "(?i)FROM") {
            if ($content -match "(?i)data|periodo|competencia|mes|ano|data_inicial|data_final|@dt") {
                $passed += "Filtros de periodo explicitos"
                Write-Host "     [OK] Filtros de periodo explicitos" -ForegroundColor Green
            }
        }

        # SARGable predicates (sem funcoes em colunas no WHERE)
        $nonSargable = $false
        if ($content -match "(?i)WHERE\s+.*\b(UPPER|LOWER|LEFT|RIGHT|SUBSTRING|CONVERT|CAST|ISNULL|COALESCE)\s*\(") {
            $warnings += "Funcao em coluna no WHERE (nao-sargable) - pode impedir uso de indice"
            $nonSargable = $true
            Write-Host "     [AVISO] Funcao em coluna no WHERE (nao-sargable)" -ForegroundColor Yellow
        }
        if (-not $nonSargable) {
            $passed += "Predicates SARGable"
            Write-Host "     [OK] Predicates SARGable" -ForegroundColor Green
        }

        # ===== 3. query-performance.md: Performance =====
        Write-Host ""
        Write-Host "  3. PERFORMANCE (checklists/data/query-performance.md)" -ForegroundColor Cyan

        # Funcoes em colunas indexadas
        if ($content -match "(?i)WHERE\s+.*\b(UPPER|LOWER|LEFT|RIGHT|SUBSTRING)\s*\(.*\b(=|<>|!=|LIKE)") {
            $warnings += "Funcao em coluna no WHERE pode impedir indice"
            Write-Host "     [AVISO] Funcao em coluna no WHERE (indice)" -ForegroundColor Yellow
        } else {
            $passed += "Sem funcoes em colunas de filtro"
            Write-Host "     [OK] Sem funcoes em colunas de filtro" -ForegroundColor Green
        }

        # SELECT desnecessario em subqueries
        if ($content -match "(?i)SELECT\s+\*\s+FROM\s+\(.*SELECT") {
            $warnings += "SELECT * em subquery (otimizar)"
            Write-Host "     [AVISO] SELECT * em subquery" -ForegroundColor Yellow
        } else {
            $passed += "Sem SELECT * em subqueries"
            Write-Host "     [OK] Sem SELECT * em subqueries" -ForegroundColor Green
        }

        # ===== 4. join-cardinality.md: Cardinalidade de Joins =====
        Write-Host ""
        Write-Host "  4. CARDINALIDADE DE JOINS (checklists/data/join-cardinality.md)" -ForegroundColor Cyan

        $joinCount = ([regex]::Matches($content, "(?i)\bJOIN\b")).Count
        if ($joinCount -gt 0) {
            Write-Host "     [INFO] $joinCount JOIN(s) detectado(s)" -ForegroundColor DarkGray
            $warnings += "$joinCount JOIN(s) - verificar cardinalidade 1:N, N:N e fan-out"
            Write-Host "     [AVISO] Verificar cardinalidade manualmente (1:N, N:N, fan-out)" -ForegroundColor Yellow
        } else {
            $passed += "Sem JOINs (sem risco de cardinalidade)"
            Write-Host "     [OK] Sem JOINs" -ForegroundColor Green
        }

        # ===== 5. Seguranca (safe-database-changes.md) =====
        Write-Host ""
        Write-Host "  5. SEGURANCA (rules/data/safe-database-changes.md)" -ForegroundColor Cyan

        # UPDATE/DELETE sem WHERE
        if ($content -match "(?i)DELETE\s+FROM\s+\[?\w+\]?\s*;") {
            $errors += "DELETE sem WHERE detectado"
            Write-Host "     [ERRO] DELETE sem WHERE" -ForegroundColor Red
        } elseif ($content -match "(?i)DELETE\s+FROM") {
            if ($content -match "(?i)DELETE\s+FROM.*WHERE") {
                $passed += "DELETE com WHERE"
                Write-Host "     [OK] DELETE com WHERE" -ForegroundColor Green
            } else {
                $errors += "DELETE sem WHERE detectado"
                Write-Host "     [ERRO] DELETE sem WHERE" -ForegroundColor Red
            }
        }

        if ($content -match "(?i)UPDATE\s+\[?\w+\]?\s+SET") {
            if ($content -match "(?i)UPDATE\s+\[?\w+\]?\s+SET.*WHERE") {
                $passed += "UPDATE com WHERE"
                Write-Host "     [OK] UPDATE com WHERE" -ForegroundColor Green
            } else {
                $errors += "UPDATE sem WHERE detectado"
                Write-Host "     [ERRO] UPDATE sem WHERE" -ForegroundColor Red
            }
        }

        # MERGE
        if ($content -match "(?i)\bMERGE\b") {
            $warnings += "MERGE detectado (verificar justificativa)"
            Write-Host "     [AVISO] MERGE detectado (justificar uso)" -ForegroundColor Yellow
        }

        # NOLOCK
        if ($content -match "(?i)NOLOCK") {
            if ($content -match "(?i)NOLOCK.*--.*justif|NOLOCK.*--.*motivo") {
                $passed += "NOLOCK justificado"
                Write-Host "     [OK] NOLOCK justificado" -ForegroundColor Green
            } else {
                $warnings += "NOLOCK sem justificativa (pode ler dados sujos)"
                Write-Host "     [AVISO] NOLOCK sem justificativa" -ForegroundColor Yellow
            }
        }

        # ===== 6. Cabecalho =====
        Write-Host ""
        Write-Host "  6. CABECALHO" -ForegroundColor Cyan

        if ($content -match "Task ClickUp\s*:") {
            $passed += "Cabecalho: Task ClickUp"
            Write-Host "     [OK] Task ClickUp presente" -ForegroundColor Green
        } else {
            $errors += "Cabecalho: Task ClickUp ausente"
            Write-Host "     [ERRO] Task ClickUp ausente no cabecalho" -ForegroundColor Red
        }

        if ($content -match "Autor\s*:") {
            $passed += "Cabecalho: Autor"
            Write-Host "     [OK] Autor presente" -ForegroundColor Green
        } else {
            $warnings += "Cabecalho: Autor ausente"
            Write-Host "     [AVISO] Autor ausente no cabecalho" -ForegroundColor Yellow
        }

        if ($content -match "Rollback\s*:") {
            $passed += "Cabecalho: Rollback ref"
            Write-Host "     [OK] Rollback ref presente" -ForegroundColor Green
        } else {
            $errors += "Cabecalho: Rollback ref ausente"
            Write-Host "     [ERRO] Rollback ref ausente no cabecalho" -ForegroundColor Red
        }

        # ===== Veredito =====
        Write-Host ""
        Write-Host "  VEREDITO" -ForegroundColor Cyan
        Write-Host "     Passaram:    $($passed.Count)" -ForegroundColor Green
        Write-Host "     Avisos:      $($warnings.Count)" -ForegroundColor Yellow
        Write-Host "     Erros:       $($errors.Count)" -ForegroundColor Red
        Write-Host ""

        $verdict = "approved"
        $verdictColor = "Green"

        if ($errors.Count -gt 0) {
            $verdict = "blocked"
            $verdictColor = "Red"
        } elseif ($warnings.Count -ge 3) {
            $verdict = "conditional"
            $verdictColor = "Yellow"
        }

        Write-Host "     VEREDITO: $verdict" -ForegroundColor $verdictColor

        if ($errors.Count -gt 0) {
            Write-Host ""
            Write-Host "     ERROS (bloqueiam deploy):" -ForegroundColor Red
            foreach ($e in $errors) { Write-Host "       - $e" -ForegroundColor Red }
        }

        if ($warnings.Count -gt 0) {
            Write-Host ""
            Write-Host "     AVISOS (revisar antes do deploy):" -ForegroundColor Yellow
            foreach ($w in $warnings) { Write-Host "       - $w" -ForegroundColor Yellow }
        }

        Write-Host ""
        Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
        switch ($verdict) {
            "approved" {
                Write-Host "     Code review aprovado. Prosseguir para proxima validacao." -ForegroundColor Green
            }
            "conditional" {
                Write-Host "     1. Revisar avisos e corrigir quando possivel" -ForegroundColor White
                Write-Host "     2. Tech Lead: avaliar avisos e aprovar se aceitavel" -ForegroundColor White
                Write-Host "     3. Registrar resultado (code-review.ps1 -Action record)" -ForegroundColor White
            }
            "blocked" {
                Write-Host "     1. Corrigir todos os erros" -ForegroundColor White
                Write-Host "     2. Re-executar code review" -ForegroundColor White
                Write-Host "     3. Nao prosseguir com deploy ate passar" -ForegroundColor White
            }
        }
    }

    "record" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $ReviewResult) {
            Write-Host "ERRO: ReleaseKey, ObjectName e ReviewResult sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        $log = Get-Content $reviewLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey    = $ReleaseKey
            objectName    = $ObjectName
            objectType    = $ObjectType
            result        = $ReviewResult
            reviewedAt    = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            reviewedBy    = $env:USERNAME
        }
        $log.reviews = @($log.reviews + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $reviewLogPath -Encoding utf8

        $color = switch ($ReviewResult) {
            "approved"   { "Green" }
            "conditional" { "Yellow" }
            "blocked"    { "Red" }
        }
        Write-Host "CODE REVIEW: $ReviewResult" -ForegroundColor $color
        Write-Host "  Objeto: $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
    }

    "status" {
        $log = Get-Content $reviewLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== CODE REVIEW LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.reviews.Count -eq 0) {
            Write-Host "  Nenhuma revisao registrada." -ForegroundColor DarkGray
            return
        }

        foreach ($r in $log.reviews) {
            $color = switch ($r.result) {
                "approved"    { "Green" }
                "conditional" { "Yellow" }
                "blocked"     { "Red" }
            }
            Write-Host "  [$($r.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:    $($r.objectName) ($($r.objectType))" -ForegroundColor White
            Write-Host "    Resultado: $($r.result)" -ForegroundColor $color
            Write-Host "    Revisado:  $($r.reviewedAt)" -ForegroundColor DarkGray
            Write-Host "    Por:       $($r.reviewedBy)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
