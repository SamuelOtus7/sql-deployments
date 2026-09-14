<#
.SYNOPSIS
    Ferramenta de deploy em PRODUCAO com salvaguardas obrigatorias.
.DESCRIPTION
    Sequencia obrigatoria antes de tocar no PROD:
    1. Validar que o script forward existe e passa no lint
    2. Validar que o rollback correspondente existe
    3. Drift check: comparar o objeto no QAS vs PROD
       - Se PROD divergiu do QAS, bloquear (alguem publicou no PROD enquanto testava no QAS)
    4. Backup do objeto: salvar a definicao atual do objeto no PROD antes de modificar
    5. Aplicar o script no PROD via execute_ddl
    6. Smoke test: verificar se o objeto existe e esta acessivel apos o deploy
    7. Registrar no audit log
    8. Remover do estado QAS (qas-state.ps1 -Action remove)

    USO PELO AGENTE: Este script NAO executa DDL diretamente. Ele prepara e valida.
    O agente (Devin) executa o DDL via MCP mssql-prod e registra aqui.

.PARAMETER Action
    pre-check:  valida forward, rollback, e faz drift check (QAS vs PROD)
    backup:     salva definicao atual do objeto no PROD (gera SQL para o agente executar)
    confirm:    marca confirmacao explicita do usuario (obrigatorio antes de apply)
    apply:      registra aplicacao no audit log (apos agente executar DDL com sucesso)
    smoke:     gera query de smoke test para o agente executar
    status:     mostra audit log

.PARAMETER ReleaseKey
    Chave de release (ex: r20260914-CU8888-a1b2c3d)

.PARAMETER ForwardScript
    Caminho do script forward

.PARAMETER RollbackScript
    Caminho do script rollback

.PARAMETER ObjectName
    Nome do objeto (ex: vw_teste, UspFinGeraPagamento)

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.EXAMPLE
    .\deploy-prod.ps1 -Action pre-check -ReleaseKey r20260914-CU8888-a1b2c3d -ForwardScript scripts/forward/2026/09/001_forward_CU8888_teste.sql -RollbackScript scripts/rollback/2026/09/001_rollback_CU8888_teste.sql -ObjectName vw_teste -ObjectType VIEW
    .\deploy-prod.ps1 -Action confirm -ReleaseKey r20260914-CU8888-a1b2c3d
    .\deploy-prod.ps1 -Action apply -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_teste -ObjectType VIEW
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("pre-check","backup","confirm","apply","smoke","status")]
    [string]$Action,

    [string]$ReleaseKey = "",
    [string]$ForwardScript = "",
    [string]$RollbackScript = "",
    [string]$ObjectName = "",
    [string]$ObjectType = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$auditPath = Join-Path $repoRoot "scripts\prod-audit.json"
$backupDir = Join-Path $repoRoot "backups\prod"
$confirmPath = Join-Path $repoRoot "scripts\prod-confirm.json"

# Garante diretorios
if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
if (-not (Test-Path $auditPath)) { '{"version":"1.0","lastUpdated":null,"deployments":[]}' | Set-Content -Path $auditPath -Encoding utf8 }

function Get-Audit {
    return Get-Content $auditPath -Raw | ConvertFrom-Json
}

function Save-Audit($state) {
    $state.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
    $state | ConvertTo-Json -Depth 5 | Set-Content -Path $auditPath -Encoding utf8
}

switch ($Action) {
    "pre-check" {
        Write-Host ""
        Write-Host "=== PRE-CHECK PROD: $ReleaseKey ===" -ForegroundColor Cyan
        Write-Host ""

        $errors = @()
        $warnings = @()

        # 1. Forward script existe?
        $fwdPath = Join-Path $repoRoot $ForwardScript
        if (-not (Test-Path $fwdPath)) {
            $errors += "Forward script nao encontrado: $ForwardScript"
        } else {
            Write-Host "  [OK] Forward script encontrado: $ForwardScript" -ForegroundColor Green
        }

        # 2. Rollback script existe?
        if ($RollbackScript) {
            $rbPath = Join-Path $repoRoot $RollbackScript
            if (-not (Test-Path $rbPath)) {
                $errors += "Rollback script nao encontrado: $RollbackScript"
            } else {
                Write-Host "  [OK] Rollback script encontrado: $RollbackScript" -ForegroundColor Green
            }
        } else {
            $errors += "Rollback script nao informado"
        }

        # 3. ObjectName informado?
        if (-not $ObjectName) {
            $errors += "ObjectName nao informado"
        } else {
            Write-Host "  [OK] Objeto alvo: $ObjectName ($ObjectType)" -ForegroundColor Green
        }

        # 4. ReleaseKey informado?
        if (-not $ReleaseKey) {
            $errors += "ReleaseKey nao informado"
        } else {
            Write-Host "  [OK] Release key: $ReleaseKey" -ForegroundColor Green
        }

        # 5. Script forward tem TRY/CATCH?
        if (Test-Path $fwdPath) {
            $content = Get-Content $fwdPath -Raw
            if ($content -notmatch "BEGIN TRY") { $errors += "Forward script sem BEGIN TRY" }
            if ($content -notmatch "BEGIN CATCH") { $errors += "Forward script sem BEGIN CATCH" }
            if ($content -notmatch "SET NOCOUNT ON") { $warnings += "Forward script sem SET NOCOUNT ON" }
        }

        # 6. Rollback referencia o forward?
        if ($RollbackScript -and (Test-Path (Join-Path $repoRoot $RollbackScript))) {
            $rbContent = Get-Content (Join-Path $repoRoot $RollbackScript) -Raw
            if ($rbContent -notmatch "Forward ref\s*:") {
                $warnings += "Rollback script sem 'Forward ref :' no cabecalho"
            }
        }

        # Resultado
        Write-Host ""
        if ($warnings.Count -gt 0) {
            Write-Host "  AVISOS:" -ForegroundColor Yellow
            foreach ($w in $warnings) { Write-Host "    - $w" -ForegroundColor Yellow }
        }

        if ($errors.Count -gt 0) {
            Write-Host ""
            Write-Host "  ERROS (bloqueiam deploy):" -ForegroundColor Red
            foreach ($e in $errors) { Write-Host "    - $e" -ForegroundColor Red }
            Write-Host ""
            Write-Host "  PRE-CHECK FALHOU. Corrija antes de continuar." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "  PRE-CHECK APROVADO." -ForegroundColor Green
        Write-Host ""
        Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "    1. Agente: drift check (comparar objeto no QAS vs PROD via MCP)" -ForegroundColor White
        Write-Host "    2. Agente: backup do objeto no PROD (salvar definicao atual)" -ForegroundColor White
        Write-Host "    3. Usuario: confirmar explicitamente o deploy" -ForegroundColor White
        Write-Host "    4. Agente: aplicar DDL no PROD via mssql-prod.execute_ddl" -ForegroundColor White
        Write-Host "    5. Agente: smoke test no PROD" -ForegroundColor White
        Write-Host "    6. Agente: registrar no audit log" -ForegroundColor White
        Write-Host "    7. Agente: remover do estado QAS" -ForegroundColor White
    }

    "backup" {
        if (-not $ObjectName) {
            Write-Host "ERRO: ObjectName e obrigatorio para backup." -ForegroundColor Red
            exit 1
        }

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $backupDir "${ObjectName}_${timestamp}.sql"

        # Gera SQL para o agente executar e salvar o resultado
        $typeMap = @{
            "VIEW"     = "V"
            "PROCEDURE" = "P"
            "TABLE"    = "U"
            "FUNCTION" = "FN"
            "TRIGGER"  = "TR"
        }

        $typeCode = $typeMap[$ObjectType]
        if (-not $typeCode) { $typeCode = "U" }

        $backupQuery = @"
-- Backup do objeto [$ObjectName] ($ObjectType)
-- Gerado em: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')
-- Release: $ReleaseKey
-- Execute via mssql-prod.execute_query para obter a definicao atual
SELECT m.definition
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.name = '$ObjectName'
  AND o.type = '$typeCode';
"@

        $backupQuery | Set-Content -Path $backupFile -Encoding utf8

        Write-Host "BACKUP PROD: Definicao atual de $ObjectName sera salva em:" -ForegroundColor Green
        Write-Host "  $backupFile" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "QUERY para o agente executar no PROD (mssql-prod.execute_query):" -ForegroundColor Cyan
        Write-Host ""
        Write-Host $backupQuery -ForegroundColor White
        Write-Host ""
        Write-Host "O agente deve:" -ForegroundColor Yellow
        Write-Host "  1. Executar a query acima no mssql-prod" -ForegroundColor White
        Write-Host "  2. Salvar o resultado (definition) no arquivo de backup" -ForegroundColor White
        Write-Host "  3. Prosseguir para confirm + apply" -ForegroundColor White
    }

    "confirm" {
        if (-not $ReleaseKey) {
            Write-Host "ERRO: ReleaseKey e obrigatorio para confirm." -ForegroundColor Red
            exit 1
        }

        # Registra confirmacao explicita com timestamp
        $confirm = [PSCustomObject]@{
            releaseKey    = $ReleaseKey
            confirmedAt   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            confirmedBy   = $env:USERNAME
            status        = "confirmed"
        }

        $confirm | ConvertTo-Json -Depth 3 | Set-Content -Path $confirmPath -Encoding utf8

        Write-Host "CONFIRMACAO PROD: Release $ReleaseKey confirmada por $env:USERNAME." -ForegroundColor Green
        Write-Host "  Agora o agente pode aplicar o DDL no PROD." -ForegroundColor DarkGray
    }

    "apply" {
        if (-not $ReleaseKey) {
            Write-Host "ERRO: ReleaseKey e obrigatorio para apply." -ForegroundColor Red
            exit 1
        }

        # Verifica confirmacao
        if (-not (Test-Path $confirmPath)) {
            Write-Host "ERRO: Deploy nao confirmado. Execute -Action confirm primeiro." -ForegroundColor Red
            exit 1
        }

        $confirm = Get-Content $confirmPath -Raw | ConvertFrom-Json
        if ($confirm.releaseKey -ne $ReleaseKey -or $confirm.status -ne "confirmed") {
            Write-Host "ERRO: Confirmacao nao corresponde a release $ReleaseKey." -ForegroundColor Red
            exit 1
        }

        # Registra no audit log
        $audit = Get-Audit
        $entry = [PSCustomObject]@{
            releaseKey    = $ReleaseKey
            objectName    = $ObjectName
            objectType    = $ObjectType
            forwardScript = $ForwardScript
            rollbackScript = $RollbackScript
            deployedAt    = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            deployedBy    = $env:USERNAME
            status        = "deployed"
            confirmedAt   = $confirm.confirmedAt
        }

        $audit.deployments = @($audit.deployments + $entry)
        Save-Audit $audit

        # Limpa confirmacao
        Remove-Item $confirmPath -Force -ErrorAction SilentlyContinue

        Write-Host "AUDIT PROD: Deploy de $ReleaseKey registrado." -ForegroundColor Green
        Write-Host "  Objeto: $ObjectName ($ObjectType)" -ForegroundColor DarkGray
        Write-Host "  Deployed by: $env:USERNAME" -ForegroundColor DarkGray
        Write-Host "  Status: deployed" -ForegroundColor Green
    }

    "smoke" {
        if (-not $ObjectName) {
            Write-Host "ERRO: ObjectName e obrigatorio para smoke." -ForegroundColor Red
            exit 1
        }

        $typeMap = @{
            "VIEW"     = "V"
            "PROCEDURE" = "P"
            "TABLE"    = "U"
            "FUNCTION" = "FN"
            "TRIGGER"  = "TR"
        }
        $typeCode = $typeMap[$ObjectType]
        if (-not $typeCode) { $typeCode = "U" }

        $smokeQuery = @"
-- Smoke test: verificar se o objeto existe e e valido apos deploy
SELECT
    name,
    type_desc,
    create_date,
    modify_date,
    OBJECTPROPERTY(object_id, 'IsExecuted') AS is_executable
FROM sys.objects
WHERE name = '$ObjectName'
  AND type = '$typeCode';
"@

        Write-Host "SMOKE TEST PROD: Verificar $ObjectName apos deploy." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "QUERY para o agente executar no PROD (mssql-prod.execute_query):" -ForegroundColor White
        Write-Host ""
        Write-Host $smokeQuery -ForegroundColor Gray
        Write-Host ""
        Write-Host "Se retornar 1 linha: objeto existe. Deploy OK." -ForegroundColor Green
        Write-Host "Se retornar 0 linhas: objeto nao existe. Deploy falhou - executar rollback." -ForegroundColor Red
    }

    "status" {
        $audit = Get-Audit
        Write-Host ""
        Write-Host "=== AUDIT LOG PROD ===" -ForegroundColor Cyan
        Write-Host ""

        if ($audit.deployments.Count -eq 0) {
            Write-Host "  Nenhum deploy registrado." -ForegroundColor DarkGray
            return
        }

        foreach ($d in $audit.deployments) {
            Write-Host "  [$($d.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:      $($d.objectName) ($($d.objectType))" -ForegroundColor White
            Write-Host "    Forward:     $($d.forwardScript)" -ForegroundColor DarkGray
            Write-Host "    Rollback:    $($d.rollbackScript)" -ForegroundColor DarkGray
            Write-Host "    Deployed:    $($d.deployedAt)" -ForegroundColor DarkGray
            Write-Host "    Deployed by: $($d.deployedBy)" -ForegroundColor DarkGray
            Write-Host "    Status:      $($d.status)" -ForegroundColor Green
            Write-Host ""
        }
    }
}
