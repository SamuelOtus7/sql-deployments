<#
.SYNOPSIS
    Orquestra o fluxo de hotfix para incidentes em producao.
.DESCRIPTION
    Fluxo acelerado para correcoes urgentes em producao.
    Backup obrigatorio, validacao minima (impacto + code review),
    deploy rapido com rollback automatico.

.PARAMETER Action
    start:    inicia o fluxo de hotfix (valida permissoes + cria branch)
    validate: executa validacao acelerada (impacto + code review)
    record:   registra o hotfix no audit log
    status:   mostra status do hotfix em andamento

.PARAMETER TaskId
    ID da task ClickUp (ex: CU-9999)

.PARAMETER ObjectName
    Nome do objeto alvo do hotfix

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION, TRIGGER)

.PARAMETER ForwardScript
    Caminho do script forward

.PARAMETER RollbackScript
    Caminho do script rollback

.PARAMETER ReleaseKey
    Chave de release do hotfix

.PARAMETER Motivo
    Motivo do hotfix (obrigatorio)

.PARAMETER DryRunSkipped
    Indica se o dry-run foi pulado (emergencia critica)

.PARAMETER SmokeResult
    Resultado do smoke test: pass ou fail

.PARAMETER Status
    Status final: published ou rolled-back

.EXAMPLE
    .\hotfix.ps1 -Action start -TaskId CU-9999 -ObjectName UspFinGeraPagamento -ObjectType PROCEDURE -Motivo "Bug em producao causando pagamento duplicado"
    .\hotfix.ps1 -Action record -ReleaseKey r20260914-CU9999-hotfix-a1b2c3d -TaskId CU-9999 -ObjectName UspFinGeraPagamento -Motivo "Bug em producao" -DryRunSkipped -SmokeResult pass -Status published
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("start","validate","record","status")]
    [string]$Action,

    [string]$TaskId = "",
    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ForwardScript = "",
    [string]$RollbackScript = "",
    [string]$ReleaseKey = "",
    [string]$Motivo = "",
    [switch]$DryRunSkipped,
    [ValidateSet("pass","fail")]
    [string]$SmokeResult = "",
    [ValidateSet("published","rolled-back")]
    [string]$Status = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$hotfixLogPath = Join-Path $repoRoot "scripts\hotfix-log.json"

if (-not (Test-Path $hotfixLogPath)) {
    '{"version":"1.0","lastUpdated":null,"hotfixes":[]}' | Set-Content -Path $hotfixLogPath -Encoding utf8
}

switch ($Action) {
    "start" {
        if (-not $TaskId -or -not $ObjectName -or -not $Motivo) {
            Write-Host "ERRO: TaskId, ObjectName e Motivo sao obrigatorios para start." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== HOTFIX INICIADO: $TaskId ===" -ForegroundColor Red
        Write-Host "  Objeto: $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Motivo: $Motivo" -ForegroundColor Yellow
        Write-Host ""

        Write-Host "  FLUXO DE HOTFIX (acelerado):" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "    1. Criar branch: sql/hotfix-$($TaskId.ToLower())-$($ObjectName.ToLower())" -ForegroundColor White
        Write-Host "    2. Escrever forward + rollback (pre-commit valida)" -ForegroundColor White
        Write-Host "    3. Commit + push" -ForegroundColor White
        Write-Host "    4. Validacao acelerada:" -ForegroundColor White
        Write-Host "       a. impact-analysis.ps1 (OBRIGATORIO)" -ForegroundColor Yellow
        Write-Host "       b. code-review.ps1 (OBRIGATORIO)" -ForegroundColor Yellow
        Write-Host "       c. Dry-run QAS (pular em emergencia critica)" -ForegroundColor DarkGray
        Write-Host "       d. Validacao negocio (PULAR em hotfix)" -ForegroundColor DarkGray
        Write-Host "    5. Backup PROD (OBRIGATORIO - sem backup, sem deploy)" -ForegroundColor Red
        Write-Host "    6. Confirmar publicacao em PROD? (sim/nao)" -ForegroundColor White
        Write-Host "    7. Aplicar no PROD via mssql-prod.execute_ddl" -ForegroundColor White
        Write-Host "    8. Smoke test pos-deploy" -ForegroundColor White
        Write-Host "    9. Se falhar: rollback automatico" -ForegroundColor White
        Write-Host "   10. Registrar no audit log (OBRIGATORIO)" -ForegroundColor White
        Write-Host ""

        Write-Host "  COMANDOS:" -ForegroundColor Cyan
        Write-Host "    git checkout -b sql/hotfix-$($TaskId.ToLower())-$($ObjectName.ToLower())" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Apos escrever os scripts:" -ForegroundColor Cyan
        Write-Host "    hotfix.ps1 -Action validate -ForwardScript <forward> -ObjectName $ObjectName -ObjectType $ObjectType" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Apos deploy:" -ForegroundColor Cyan
        Write-Host "    hotfix.ps1 -Action record -ReleaseKey <key> -TaskId $TaskId -ObjectName $ObjectName -Motivo `"$Motivo`" -SmokeResult pass -Status published" -ForegroundColor DarkGray
    }

    "validate" {
        if (-not $ForwardScript -or -not $ObjectName) {
            Write-Host "ERRO: ForwardScript e ObjectName sao obrigatorios para validate." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== HOTFIX: VALIDACAO ACELERADA ===" -ForegroundColor Red
        Write-Host "  Objeto: $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Script: $ForwardScript" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  Camada 1: Analise de Impacto (OBRIGATORIO)" -ForegroundColor Yellow
        Write-Host "    Executar: impact-analysis.ps1 -Action analyze -ForwardScript $ForwardScript -ObjectName $ObjectName -ObjectType $ObjectType" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  Camada 2: Code Review (OBRIGATORIO)" -ForegroundColor Yellow
        Write-Host "    Executar: code-review.ps1 -Action review -ForwardScript $ForwardScript -ObjectName $ObjectName -ObjectType $ObjectType" -ForegroundColor DarkGray
        Write-Host ""

        if ($DryRunSkipped) {
            Write-Host "  Camada 3: Dry-run QAS (PULADO - emergencia critica)" -ForegroundColor Red
            Write-Host "    ATENCAO: Dry-run pulado. Deploy sem validacao completa." -ForegroundColor Red
            Write-Host "    Tech Lead deve autorizar explicitamente." -ForegroundColor Red
        } else {
            Write-Host "  Camada 3: Dry-run QAS (recomendado)" -ForegroundColor Yellow
            Write-Host "    Executar: dry-run-qas.ps1 -Action generate -ObjectName $ObjectName -ObjectType $ObjectType" -ForegroundColor DarkGray
        }
        Write-Host ""

        Write-Host "  Camada 4: Validacao de negocio (PULAR em hotfix)" -ForegroundColor DarkGray
        Write-Host "    Hotfix nao executa validacao de negocio por padrao." -ForegroundColor DarkGray
        Write-Host "    Se o objeto for financeiro, considere validar manualmente." -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "    1. Executar Camada 1 e Camada 2" -ForegroundColor White
        Write-Host "    2. Se aprovado: backup PROD" -ForegroundColor White
        Write-Host "    3. Confirmar publicacao" -ForegroundColor White
        Write-Host "    4. Aplicar no PROD" -ForegroundColor White
        Write-Host "    5. Smoke test" -ForegroundColor White
        Write-Host "    6. Registrar hotfix" -ForegroundColor White
    }

    "record" {
        if (-not $ReleaseKey -or -not $TaskId -or -not $ObjectName -or -not $Motivo -or -not $SmokeResult -or -not $Status) {
            Write-Host "ERRO: ReleaseKey, TaskId, ObjectName, Motivo, SmokeResult e Status sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        $log = Get-Content $hotfixLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey      = $ReleaseKey
            taskId          = $TaskId
            objectName      = $ObjectName
            objectType      = $ObjectType
            motivo          = $Motivo
            dryRunSkipped   = $DryRunSkipped.IsPresent
            smokeResult     = $SmokeResult
            status          = $Status
            recordedAt      = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            recordedBy      = $env:USERNAME
        }
        $log.hotfixes = @($log.hotfixes + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $hotfixLogPath -Encoding utf8

        $color = if ($Status -eq "published") { "Green" } else { "Red" }
        Write-Host "HOTFIX REGISTRADO: $Status" -ForegroundColor $color
        Write-Host "  Release:   $ReleaseKey" -ForegroundColor White
        Write-Host "  Task:      $TaskId" -ForegroundColor White
        Write-Host "  Objeto:    $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Motivo:    $Motivo" -ForegroundColor Yellow
        Write-Host "  Dry-run:   $(if ($DryRunSkipped.IsPresent) { 'PULADO' } else { 'executado' })" -ForegroundColor $(if ($DryRunSkipped.IsPresent) { "Red" } else { "Green" })
        Write-Host "  Smoke:     $SmokeResult" -ForegroundColor $(if ($SmokeResult -eq "pass") { "Green" } else { "Red" })
        Write-Host "  Status:    $Status" -ForegroundColor $color
        Write-Host "  Por:       $env:USERNAME" -ForegroundColor DarkGray
        Write-Host "  Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')" -ForegroundColor DarkGray

        # Registra no AUDIT_LOG.md
        $auditPath = Join-Path $repoRoot "changelog\AUDIT_LOG.md"
        $auditEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') — HOTFIX

- **Release:** $ReleaseKey
- **Task:** $TaskId
- **Objeto:** $ObjectName ($ObjectType)
- **Motivo:** $Motivo
- **Dry-run pulado:** $(if ($DryRunSkipped.IsPresent) { 'sim' } else { 'nao' })
- **Smoke test:** $SmokeResult
- **Status:** $Status
- **Por:** $env:USERNAME
"@
        Add-Content -Path $auditPath -Value $auditEntry -Encoding utf8
        Write-Host ""
        Write-Host "  Registrado tambem em changelog/AUDIT_LOG.md" -ForegroundColor DarkGray
    }

    "status" {
        $log = Get-Content $hotfixLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== HOTFIX LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.hotfixes.Count -eq 0) {
            Write-Host "  Nenhum hotfix registrado." -ForegroundColor DarkGray
            return
        }

        foreach ($h in $log.hotfixes) {
            $color = if ($h.status -eq "published") { "Green" } else { "Red" }
            Write-Host "  [$($h.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Task:      $($h.taskId)" -ForegroundColor White
            Write-Host "    Objeto:    $($h.objectName) ($($h.objectType))" -ForegroundColor White
            Write-Host "    Motivo:    $($h.motivo)" -ForegroundColor Yellow
            Write-Host "    Dry-run:   $(if ($h.dryRunSkipped) { 'PULADO' } else { 'executado' })" -ForegroundColor $(if ($h.dryRunSkipped) { "Red" } else { "Green" })
            Write-Host "    Smoke:     $($h.smokeResult)" -ForegroundColor $(if ($h.smokeResult -eq "pass") { "Green" } else { "Red" })
            Write-Host "    Status:    $($h.status)" -ForegroundColor $color
            Write-Host "    Registrado: $($h.recordedAt)" -ForegroundColor DarkGray
            Write-Host "    Por:       $($h.recordedBy)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
