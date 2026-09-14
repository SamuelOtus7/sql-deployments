<#
.SYNOPSIS
    Validacao de impacto no banco antes do deploy em PROD.
.DESCRIPTION
    Incorpora as skills impact-analysis e dba-reviewer do framework Otus7:
    - Lista consumidores do objeto (relatorios Power BI, APIs, telas, jobs)
    - Classifica impacto (alto/medio/baixo)
    - Verifica checklist de production-safety
    - Verifica se e objeto financeiro (dupla validacao obrigatoria)
    - Bloqueia se houver risco alto sem mitigacao

    Framework rules incorporadas:
    - rules/data/safe-database-changes.md
    - rules/data/financial-data-care.md
    - rules/data/sql-standards.md
    - checklists/data/production-safety.md
    - checklists/data/sql-quality.md

    Skills do framework:
    - impact-analysis: mapeia o que quebra quando um artefato de dados e alterado
    - dba-reviewer: revisa alteracoes em banco quanto a impacto, rollback e seguranca

.PARAMETER Action
    analyze:  analisa o script forward e gera relatorio de impacto
    record:   registra o resultado da analise no impact-log
    status:   mostra historico de analises de impacto

.PARAMETER ForwardScript
    Caminho do script forward a analisar

.PARAMETER ObjectName
    Nome do objeto alvo (ex: vw_feriados, UspFinGeraPagamento)

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)

.PARAMETER AnalysisResult
    Resultado da analise: approved | blocked | conditional (usado com -Action record)

.PARAMETER Schema
    Schema do objeto (default: dbo)

.EXAMPLE
    .\impact-analysis.ps1 -Action analyze -ForwardScript scripts/forward/2026/09/001_forward_CU8888_teste.sql -ObjectName vw_feriados -ObjectType VIEW -ReleaseKey r20260914-CU8888-a1b2c3d
    .\impact-analysis.ps1 -Action record -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_feriados -ObjectType VIEW -AnalysisResult approved
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("analyze","record","status")]
    [string]$Action,

    [string]$ForwardScript = "",
    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ReleaseKey = "",
    [ValidateSet("approved","blocked","conditional")]
    [string]$AnalysisResult = "",
    [string]$Schema = "dbo"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$impactLogPath = Join-Path $repoRoot "scripts\impact-log.json"

# Garante log
if (-not (Test-Path $impactLogPath)) {
    '{"version":"1.0","lastUpdated":null,"analyses":[]}' | Set-Content -Path $impactLogPath -Encoding utf8
}

# ===== Padroes de objetos financeiros (rules/data/financial-data-care.md) =====
$financialPatterns = @(
    "pagamento", "pagar", "fatura", "faturamento", "financeiro", "frete",
    "adiantamento", "conciliacao", "espelho", "desconto", "imposto",
    "nfse", "titulo", "contas", "extrato", "comprovante"
)

# ===== Padroes de objetos logisticos =====
$logisticPatterns = @(
    "rota", "coleta", "pacote", "motorista", "transportadora", "veiculo",
    "base", "centro_servico", "km", "quilometragem", "entrega", "transferencia"
)

function Test-FinancialObject($name) {
    $lower = $name.ToLower()
    foreach ($p in $financialPatterns) {
        if ($lower -match $p) { return $true }
    }
    return $false
}

function Test-LogisticObject($name) {
    $lower = $name.ToLower()
    foreach ($p in $logisticPatterns) {
        if ($lower -match $p) { return $true }
    }
    return $false
}

function Get-ImpactLevel($objectName, $objectType, $scriptContent) {
    # rules/data/financial-data-care.md: objeto financeiro = alto risco
    $isFinancial = Test-FinancialObject $objectName
    $isLogistic = Test-LogisticObject $objectName

    # Verifica operacoes destrutivas no script
    $hasDeleteWithoutWhere = $false
    $hasUpdateWithoutWhere = $false
    $hasDropTable = $false
    $hasAlterTable = $false
    $hasTruncate = $false

    if ($scriptContent) {
        # DELETE sem WHERE
        if ($scriptContent -match "(?i)DELETE\s+FROM\s+\[?\w+\]?\s*;") { $hasDeleteWithoutWhere = $true }
        # UPDATE sem WHERE
        if ($scriptContent -match "(?i)UPDATE\s+\[?\w+\]?\s+SET.*;") {
            if ($scriptContent -notmatch "(?i)UPDATE\s+\[?\w+\]?\s+SET.*WHERE") { $hasUpdateWithoutWhere = $true }
        }
        # DROP TABLE
        if ($scriptContent -match "(?i)DROP\s+TABLE") { $hasDropTable = $true }
        # ALTER TABLE
        if ($scriptContent -match "(?i)ALTER\s+TABLE") { $hasAlterTable = $true }
        # TRUNCATE
        if ($scriptContent -match "(?i)TRUNCATE\s+TABLE") { $hasTruncate = $true }
    }

    # Classificacao de impacto (alto/medio/baixo)
    # Alto: financeiro + operacao destrutiva, ou DROP TABLE, ou TRUNCATE
    if ($isFinancial -and ($hasDropTable -or $hasTruncate -or $hasDeleteWithoutWhere)) { return "ALTO" }
    if ($hasDropTable -or $hasTruncate) { return "ALTO" }
    if ($isFinancial -and $hasAlterTable) { return "ALTO" }
    if ($isFinancial) { return "MEDIO" }
    if ($isLogistic -and ($hasDeleteWithoutWhere -or $hasUpdateWithoutWhere)) { return "ALTO" }
    if ($isLogistic) { return "MEDIO" }
    if ($hasDeleteWithoutWhere -or $hasUpdateWithoutWhere) { return "ALTO" }
    if ($hasAlterTable) { return "MEDIO" }
    if ($objectType -eq "TABLE") { return "MEDIO" }

    return "BAIXO"
}

switch ($Action) {
    "analyze" {
        if (-not $ObjectName -or -not $ObjectType) {
            Write-Host "ERRO: ObjectName e ObjectType sao obrigatorios para analyze." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== ANALISE DE IMPACTO: $ObjectName ($ObjectType) ===" -ForegroundColor Cyan
        Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
        Write-Host ""

        # Le o script forward
        $scriptContent = ""
        if ($ForwardScript) {
            $fwdPath = Join-Path $repoRoot $ForwardScript
            if (Test-Path $fwdPath) {
                $scriptContent = Get-Content $fwdPath -Raw
                Write-Host "  [OK] Script forward lido: $ForwardScript" -ForegroundColor Green
            } else {
                Write-Host "  [AVISO] Script forward nao encontrado: $ForwardScript" -ForegroundColor Yellow
            }
        }

        # ===== 1. Classificacao de impacto (skill: impact-analysis) =====
        $impactLevel = Get-ImpactLevel $ObjectName $ObjectType $scriptContent
        $isFinancial = Test-FinancialObject $ObjectName
        $isLogistic = Test-LogisticObject $ObjectName

        Write-Host ""
        Write-Host "  1. CLASSIFICACAO DE IMPACTO" -ForegroundColor Cyan
        $levelColor = switch ($impactLevel) {
            "ALTO"  { "Red" }
            "MEDIO" { "Yellow" }
            "BAIXO" { "Green" }
        }
        Write-Host "     Nivel: $impactLevel" -ForegroundColor $levelColor
        if ($isFinancial) {
            Write-Host "     Objeto FINANCEIRO detectado (rules/data/financial-data-care.md)" -ForegroundColor Red
            Write-Host "     -> Dupla validacao obrigatoria" -ForegroundColor Red
        }
        if ($isLogistic) {
            Write-Host "     Objeto LOGISTICO detectado" -ForegroundColor Yellow
        }

        # ===== 2. Checklist de seguranca (checklists/data/production-safety.md) =====
        Write-Host ""
        Write-Host "  2. CHECKLIST DE SEGURANCA (production-safety.md)" -ForegroundColor Cyan
        $checklist = [ordered]@{
            "Analise de impacto concluida"      = $true  # estamos fazendo agora
            "Rollback documentado e testado"     = $false # verificar no script
            "Validado em ambiente seguro (QAS)" = $false # verificar qas-state
            "Sem UPDATE/DELETE sem WHERE"       = $true
            "Sem migration destrutiva sem backup" = $true
            "Relatorios dependentes verificados" = $false # agente deve verificar
            "Dados financeiros com dupla validacao" = (-not $isFinancial)
        }

        # Verifica rollback no script
        if ($scriptContent -match "(?i)rollback|reverter|reversao") {
            $checklist["Rollback documentado e testado"] = $true
        }

        # Verifica operacoes destrutivas
        if ($scriptContent) {
            if ($scriptContent -match "(?i)DELETE\s+FROM\s+\[?\w+\]?\s*;") {
                $checklist["Sem UPDATE/DELETE sem WHERE"] = $false
            }
        }

        foreach ($item in $checklist.GetEnumerator()) {
            $status = if ($item.Value) { "[OK]" } else { "[PENDENTE]" }
            $color = if ($item.Value) { "Green" } else { "Yellow" }
            Write-Host "     $status $($item.Key)" -ForegroundColor $color
        }

        # ===== 3. Operacoes destrutivas (skill: dba-reviewer) =====
        Write-Host ""
        Write-Host "  3. OPERACOES DESTRUTIVAS (dba-reviewer)" -ForegroundColor Cyan
        $destructiveOps = @()
        if ($scriptContent -match "(?i)DROP\s+TABLE") { $destructiveOps += "DROP TABLE" }
        if ($scriptContent -match "(?i)TRUNCATE") { $destructiveOps += "TRUNCATE" }
        if ($scriptContent -match "(?i)DELETE\s+FROM\s+\[?\w+\]?\s*;") { $destructiveOps += "DELETE sem WHERE" }
        if ($scriptContent -match "(?i)ALTER\s+TABLE") { $destructiveOps += "ALTER TABLE" }

        if ($destructiveOps.Count -eq 0) {
            Write-Host "     [OK] Nenhuma operacao destrutiva detectada" -ForegroundColor Green
        } else {
            foreach ($op in $destructiveOps) {
                Write-Host "     [ALERTA] $op detectada" -ForegroundColor Red
            }
        }

        # ===== 4. Queries para o agente executar (mapear consumidores) =====
        Write-Host ""
        Write-Host "  4. MAPEAMENTO DE CONSUMIDORES (impact-analysis)" -ForegroundColor Cyan
        Write-Host "     O agente deve executar estas queries no PROD para mapear dependencias:"
        Write-Host ""

        # Query 1: objetos que referenciam este objeto
        $typeCode = switch ($ObjectType) {
            "VIEW"      { "V" }
            "PROCEDURE" { "P" }
            "TABLE"     { "U" }
            "FUNCTION"  { "FN" }
            "TRIGGER"   { "TR" }
            default     { "U" }
        }

        Write-Host "     Query 1: Objetos que referenciam [$Schema].[$ObjectName]:" -ForegroundColor White
        Write-Host "     (executar via mssql-prod.execute_query)" -ForegroundColor DarkGray
        Write-Host @"
SELECT DISTINCT
    o.name AS dependent_name,
    o.type_desc AS dependent_type,
    m.definition
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE m.definition LIKE '%$ObjectName%'
  AND o.name <> '$ObjectName'
ORDER BY o.type_desc, o.name;
"@ -ForegroundColor Gray
        Write-Host ""

        # Query 2: se for TABLE, verificar FKs
        if ($ObjectType -eq "TABLE") {
            Write-Host "     Query 2: Foreign keys que referenciam [$Schema].[$ObjectName]:" -ForegroundColor White
            Write-Host @"
SELECT
    fk.name AS fk_name,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS schema_name,
    OBJECT_NAME(fk.parent_object_id) AS table_name,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS column_name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE fk.referenced_object_id = OBJECT_ID('$Schema.$ObjectName');
"@ -ForegroundColor Gray
            Write-Host ""
        }

        # Query 3: se for financeiro, verificar dependencias financeiras
        if ($isFinancial) {
            Write-Host "     Query 3: Dependencias financeiras (rules/data/financial-data-care.md):" -ForegroundColor Red
            Write-Host "     Objeto financeiro requer dupla validacao. Verificar:" -ForegroundColor Red
            Write-Host "     - Relatorios Power BI que consomem este objeto" -ForegroundColor White
            Write-Host "     - Procedures que chamam este objeto" -ForegroundColor White
            Write-Host "     - Jobs/agendamentos que dependem deste objeto" -ForegroundColor White
            Write-Host ""
        }

        # ===== 5. Veredito =====
        Write-Host "  5. VEREDITO" -ForegroundColor Cyan
        $verdict = "approved"
        $verdictColor = "Green"
        $conditions = @()

        if ($impactLevel -eq "ALTO") {
            $verdict = "conditional"
            $verdictColor = "Yellow"
            $conditions += "Impacto ALTO requer aprovacao explicita do Tech Lead"
        }
        if ($isFinancial) {
            $verdict = "conditional"
            $verdictColor = "Yellow"
            $conditions += "Objeto financeiro requer dupla validacao (rules/data/financial-data-care.md)"
        }
        if ($destructiveOps.Count -gt 0) {
            $verdict = "conditional"
            $verdictColor = "Yellow"
            $conditions += "Operacao destrutiva detectada requer justificativa documentada"
        }

        # Verifica itens pendentes no checklist
        $pendingItems = ($checklist.GetEnumerator() | Where-Object { -not $_.Value }).Count
        if ($pendingItems -gt 2) {
            $verdict = "blocked"
            $verdictColor = "Red"
            $conditions += "$pendingItems itens pendentes no checklist de seguranca"
        }

        Write-Host "     Veredito: $verdict" -ForegroundColor $verdictColor
        if ($conditions.Count -gt 0) {
            Write-Host "     Condicoes:" -ForegroundColor $verdictColor
            foreach ($c in $conditions) {
                Write-Host "       - $c" -ForegroundColor $verdictColor
            }
        }

        Write-Host ""
        Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
        switch ($verdict) {
            "approved" {
                Write-Host "     Analise aprovada. Prosseguir para backup + deploy." -ForegroundColor Green
            }
            "conditional" {
                Write-Host "     1. Agente: executar queries de mapeamento de consumidores no PROD" -ForegroundColor White
                Write-Host "     2. Agente: verificar relatorios Power BI dependentes" -ForegroundColor White
                Write-Host "     3. Tech Lead: aprovar explicitamente o deploy" -ForegroundColor White
                Write-Host "     4. Registrar resultado (impact-analysis.ps1 -Action record)" -ForegroundColor White
            }
            "blocked" {
                Write-Host "     1. Corrigir itens pendentes no checklist" -ForegroundColor White
                Write-Host "     2. Documentar justificativas para operacoes destrutivas" -ForegroundColor White
                Write-Host "     3. Re-executar analise" -ForegroundColor White
            }
        }
    }

    "record" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $AnalysisResult) {
            Write-Host "ERRO: ReleaseKey, ObjectName e AnalysisResult sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        $log = Get-Content $impactLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey    = $ReleaseKey
            objectName    = "$Schema.$ObjectName"
            objectType    = $ObjectType
            result        = $AnalysisResult
            analyzedAt    = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            analyzedBy    = $env:USERNAME
        }
        $log.analyses = @($log.analyses + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $impactLogPath -Encoding utf8

        $color = switch ($AnalysisResult) {
            "approved"   { "Green" }
            "conditional" { "Yellow" }
            "blocked"    { "Red" }
        }
        Write-Host "ANALISE DE IMPACTO: $AnalysisResult" -ForegroundColor $color
        Write-Host "  Objeto: $Schema.$ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Release: $ReleaseKey" -ForegroundColor DarkGray
    }

    "status" {
        $log = Get-Content $impactLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== IMPACT ANALYSIS LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.analyses.Count -eq 0) {
            Write-Host "  Nenhuma analise registrada." -ForegroundColor DarkGray
            return
        }

        foreach ($a in $log.analyses) {
            $color = switch ($a.result) {
                "approved"    { "Green" }
                "conditional" { "Yellow" }
                "blocked"     { "Red" }
            }
            Write-Host "  [$($a.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:    $($a.objectName) ($($a.objectType))" -ForegroundColor White
            Write-Host "    Resultado: $($a.result)" -ForegroundColor $color
            Write-Host "    Analisado: $($a.analyzedAt)" -ForegroundColor DarkGray
            Write-Host "    Por:       $($a.analyzedBy)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
