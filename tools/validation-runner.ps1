<#
.SYNOPSIS
    Executa validacoes configuradas no registry e gera veredito.
.DESCRIPTION
    Recebe os resultados das queries de validacao executadas no QAS pelo agente,
    verifica se cada dimensao retornou pelo menos 1 registro, e gera um veredito.

    Fluxo:
    1. validation-registry.ps1 -Action lookup (descobre quais validacoes aplicar)
    2. Agente executa cada query no QAS via mssql-37.execute_query
    3. Agente chama este script com -Action evaluate passando os resultados
    4. Script verifica se cada dimensao retornou >= 1
    5. Gera veredito: approved (todas passaram) ou failed (alguma falhou)
    6. Registra no validation-log

.PARAMETER Action
    evaluate:  avalia os resultados das queries de validacao
    record:    registra o resultado da validacao no log
    status:    mostra historico de validacoes executadas

.PARAMETER ReleaseKey
    Chave de release

.PARAMETER ObjectName
    Nome do objeto validado

.PARAMETER ObjectType
    Tipo do objeto

.PARAMETER ValidationId
    ID da validacao executada (ex: V001)

.PARAMETER ProcessType
    Tipo de processo (ex: pagamento, rota, pacote)

.PARAMETER Results
    Resultados das queries no formato simples: name=value;name=value;...
    Exemplo: "contagem_por_cliente=5;contagem_por_transportadora=3;contagem_por_periodo=2;contagem_por_motorista=10;contagem_por_rota=8"
    value >= 1 = passou, value = 0 = falhou

.PARAMETER ResultsFile
    Caminho para arquivo com os resultados (mesmo formato simples, um por linha ou separado por ;)

.PARAMETER ValidationResult
    Resultado final: approved ou failed (usado com -Action record)

.EXAMPLE
    .\validation-runner.ps1 -Action evaluate -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName sp_integrar_pagamentos_oxpay -ObjectType PROCEDURE -ValidationId V001 -ProcessType pagamento -Results '[{"name":"contagem_por_cliente","value":5},{"name":"contagem_por_transportadora","value":3},{"name":"contagem_por_periodo","value":2},{"name":"contagem_por_motorista","value":10},{"name":"contagem_por_rota","value":8}]'
    .\validation-runner.ps1 -Action record -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName sp_integrar_pagamentos_oxpay -ObjectType PROCEDURE -ValidationId V001 -ProcessType pagamento -ValidationResult approved
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("evaluate","record","status")]
    [string]$Action,

    [string]$ReleaseKey = "",
    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$ValidationId = "",
    [string]$ProcessType = "",
    [string]$Results = "",
    [string]$ResultsFile = "",
    [ValidateSet("approved","failed")]
    [string]$ValidationResult = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$validationLogPath = Join-Path $repoRoot "scripts\validation-log.json"

if (-not (Test-Path $validationLogPath)) {
    '{"version":"1.0","lastUpdated":null,"validations":[]}' | Set-Content -Path $validationLogPath -Encoding utf8
}

switch ($Action) {
    "evaluate" {
        if (-not $ObjectName -or -not $ValidationId -or (-not $Results -and -not $ResultsFile)) {
            Write-Host "ERRO: ObjectName, ValidationId e Results (ou ResultsFile) sao obrigatorios para evaluate." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== VALIDACAO: $ObjectName ($ObjectType) ===" -ForegroundColor Cyan
        Write-Host "  Validacao: $ValidationId ($ProcessType)" -ForegroundColor DarkGray
        Write-Host "  Release:   $ReleaseKey" -ForegroundColor DarkGray
        Write-Host ""

        # Le resultados de arquivo ou parametro
        $resultsRaw = $Results
        if ($ResultsFile) {
            if (-not (Test-Path $ResultsFile)) {
                Write-Host "ERRO: Arquivo de resultados nao encontrado: $ResultsFile" -ForegroundColor Red
                exit 1
            }
            $resultsRaw = Get-Content $ResultsFile -Raw
        }

        # Parse dos resultados (formato: name=value;name=value;...)
        $parsedResults = @()
        $pairs = $resultsRaw -split ";" | Where-Object { $_.Trim() -ne "" }
        foreach ($pair in $pairs) {
            $parts = $pair -split "=", 2
            if ($parts.Count -eq 2) {
                $parsedResults += [PSCustomObject]@{
                    name  = $parts[0].Trim()
                    value = [int]($parts[1].Trim())
                }
            }
        }

        if ($parsedResults.Count -eq 0) {
            Write-Host "ERRO: Nenhum resultado encontrado. Formato esperado: name=value;name=value;..." -ForegroundColor Red
            Write-Host "  Recebido: $resultsRaw" -ForegroundColor DarkGray
            exit 1
        }

        Write-Host "  [INFO] $($parsedResults.Count) resultado(s) para avaliar." -ForegroundColor DarkGray

        # Avalia cada resultado
        $passed = @()
        $failed = @()

        Write-Host "  RESULTADOS POR DIMENSAO:" -ForegroundColor Cyan
        Write-Host ""

        foreach ($r in $parsedResults) {
            $dimName = $r.name -replace "contagem_por_", ""
            $value = [int]$r.value
            $status = if ($value -ge 1) { "PASS" } else { "FAIL" }
            $color = if ($value -ge 1) { "Green" } else { "Red" }

            Write-Host "    [$status] $dimName : $value registro(s)" -ForegroundColor $color

            if ($value -ge 1) {
                $passed += $dimName
            } else {
                $failed += $dimName
            }
        }

        Write-Host ""
        Write-Host "  RESUMO:" -ForegroundColor Cyan
        Write-Host "    Passaram: $($passed.Count)/$($parsedResults.Count)" -ForegroundColor Green
        Write-Host "    Falharam: $($failed.Count)/$($parsedResults.Count)" -ForegroundColor $(if ($failed.Count -gt 0) { "Red" } else { "DarkGray" })

        if ($failed.Count -gt 0) {
            Write-Host ""
            Write-Host "    DIMENSOES QUE FALHARAM:" -ForegroundColor Red
            foreach ($f in $failed) {
                Write-Host "      - $f (0 registros - sem dados para esta dimensao)" -ForegroundColor Red
            }
        }

        # Veredito
        Write-Host ""
        Write-Host "  VEREDITO" -ForegroundColor Cyan

        if ($failed.Count -eq 0) {
            Write-Host "    VEREDITO: approved" -ForegroundColor Green
            Write-Host "    Todas as dimensoes retornaram dados." -ForegroundColor Green
            Write-Host "    A validacao especifica de '$ProcessType' passou." -ForegroundColor Green
            Write-Host ""
            Write-Host "    O deploy em PROD esta liberado (apos impacto + code review + dry-run + confirmacao)." -ForegroundColor Green
            Write-Host ""
            Write-Host "    Registrar resultado:" -ForegroundColor Cyan
            Write-Host "      validation-runner.ps1 -Action record -ReleaseKey $ReleaseKey -ObjectName $ObjectName -ObjectType $ObjectType -ValidationId $ValidationId -ProcessType $ProcessType -ValidationResult approved" -ForegroundColor DarkGray
        } else {
            Write-Host "    VEREDITO: failed" -ForegroundColor Red
            Write-Host "    $($failed.Count) dimensao(oes) retornaram 0 registros." -ForegroundColor Red
            Write-Host "    A validacao especifica de '$ProcessType' FALHOU." -ForegroundColor Red
            Write-Host ""
            Write-Host "    O deploy em PROD esta BLOQUEADO." -ForegroundColor Red
            Write-Host ""
            Write-Host "    PROXIMOS PASSOS:" -ForegroundColor Cyan
            Write-Host "      1. Investigar por que as dimensoes falharam retornaram 0" -ForegroundColor White
            Write-Host "      2. Verificar se o script forward esta correto" -ForegroundColor White
            Write-Host "      3. Verificar se ha dados de teste no QAS para estas dimensoes" -ForegroundColor White
            Write-Host "      4. Corrigir e re-executar a validacao" -ForegroundColor White
            Write-Host "      5. NAO publicar em PROD ate a validacao passar" -ForegroundColor Red
            Write-Host ""
            Write-Host "    Registrar resultado:" -ForegroundColor Cyan
            Write-Host "      validation-runner.ps1 -Action record -ReleaseKey $ReleaseKey -ObjectName $ObjectName -ObjectType $ObjectType -ValidationId $ValidationId -ProcessType $ProcessType -ValidationResult failed" -ForegroundColor DarkGray
        }
    }

    "record" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $ValidationId -or -not $ValidationResult) {
            Write-Host "ERRO: ReleaseKey, ObjectName, ValidationId e ValidationResult sao obrigatorios para record." -ForegroundColor Red
            exit 1
        }

        $log = Get-Content $validationLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey      = $ReleaseKey
            objectName      = $ObjectName
            objectType      = $ObjectType
            validationId    = $ValidationId
            processType     = $ProcessType
            result          = $ValidationResult
            validatedAt     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            validatedBy     = $env:USERNAME
        }
        $log.validations = @($log.validations + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $validationLogPath -Encoding utf8

        $color = if ($ValidationResult -eq "approved") { "Green" } else { "Red" }
        Write-Host "VALIDACAO REGISTRADA: $ValidationResult" -ForegroundColor $color
        Write-Host "  Objeto:     $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Validacao:  $ValidationId ($ProcessType)" -ForegroundColor White
        Write-Host "  Release:    $ReleaseKey" -ForegroundColor DarkGray
        Write-Host "  Validado:   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')" -ForegroundColor DarkGray
    }

    "status" {
        $log = Get-Content $validationLogPath -Raw | ConvertFrom-Json
        Write-Host ""
        Write-Host "=== VALIDATION LOG ===" -ForegroundColor Cyan
        Write-Host ""

        if ($log.validations.Count -eq 0) {
            Write-Host "  Nenhuma validacao registrada." -ForegroundColor DarkGray
            return
        }

        foreach ($v in $log.validations) {
            $color = if ($v.result -eq "approved") { "Green" } else { "Red" }
            Write-Host "  [$($v.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:     $($v.objectName) ($($v.objectType))" -ForegroundColor White
            Write-Host "    Validacao:  $($v.validationId) ($($v.processType))" -ForegroundColor White
            Write-Host "    Resultado:  $($v.result)" -ForegroundColor $color
            Write-Host "    Validado:   $($v.validatedAt)" -ForegroundColor DarkGray
            Write-Host "    Por:        $($v.validatedBy)" -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
