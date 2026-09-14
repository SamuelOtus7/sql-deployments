<#
.SYNOPSIS
    Consulta o registry de validacoes para determinar se um objeto precisa de validacao especifica.
.DESCRIPTION
    Le validations/registry.json e verifica se o objeto alvo tem validacao registrada.
    Se nao tiver, notifica o Tech Lead e bloqueia a publicacao (conforme requisito original).

    Regras:
    - Se o objeto match um pattern de alguma validacao ativa -> retorna a validacao
    - Se o objeto nao match nenhuma validacao -> retorna "no-validation-registered"
    - Se nao ha validacao registrada -> bloqueia e notifica Tech Lead
    - Apenas usuarios em authorizedBypass podem ignorar o bloqueio

.PARAMETER Action
    lookup:     consulta o registry para um objeto especifico
    list:       lista todas as validacoes cadastradas
    add:        adiciona nova validacao (requer authorizedEditors)
    remove:     remove uma validacao (requer authorizedEditors)
    bypass:     registra bypass de validacao (requer authorizedBypass)

.PARAMETER ObjectName
    Nome do objeto a consultar (usado com -Action lookup)

.PARAMETER ObjectType
    Tipo do objeto (VIEW, PROCEDURE, TABLE, FUNCTION)

.PARAMETER User
    Usuario que esta executando (para verificar autorizacao)

.PARAMETER ValidationId
    ID da validacao (para add/remove)

.PARAMETER BypassReason
    Justificativa do bypass (obrigatorio para -Action bypass)

.EXAMPLE
    .\validation-registry.ps1 -Action lookup -ObjectName "sp_integrar_pagamentos_oxpay" -ObjectType "PROCEDURE" -User "samuel.nogueira"
    .\validation-registry.ps1 -Action list
    .\validation-registry.ps1 -Action bypass -ObjectName "vw_feriados" -User "tech-lead" -BypassReason "View simples sem impacto financeiro"
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("lookup","list","add","remove","bypass")]
    [string]$Action,

    [string]$ObjectName = "",
    [string]$ObjectType = "",
    [string]$User = "",
    [string]$ValidationId = "",
    [string]$BypassReason = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$registryPath = Join-Path $repoRoot "validations\registry.json"
$bypassLogPath = Join-Path $repoRoot "scripts\validation-bypass-log.json"

if (-not (Test-Path $registryPath)) {
    Write-Host "ERRO: Registry nao encontrado em validations/registry.json" -ForegroundColor Red
    Write-Host "  Crie o registry antes de continuar." -ForegroundColor Yellow
    exit 1
}

$registry = Get-Content $registryPath -Raw | ConvertFrom-Json

function Test-PatternMatch($name, $patterns) {
    $lower = $name.ToLower()
    foreach ($p in $patterns) {
        $cleanPattern = $p.Trim('*').ToLower()
        if ($lower -match [regex]::Escape($cleanPattern)) {
            return $true
        }
    }
    return $false
}

switch ($Action) {
    "lookup" {
        if (-not $ObjectName) {
            Write-Host "ERRO: ObjectName e obrigatorio para lookup." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== VALIDATION REGISTRY LOOKUP: $ObjectName ($ObjectType) ===" -ForegroundColor Cyan
        Write-Host ""

        # Procura validacao que match o objeto
        $matched = @()
        foreach ($v in $registry.validations) {
            if (-not $v.enabled) { continue }
            if ($ObjectType -and $v.objectTypes -notcontains $ObjectType) { continue }
            if (Test-PatternMatch $ObjectName $v.objectPatterns) {
                $matched += $v
            }
        }

        if ($matched.Count -eq 0) {
            Write-Host "  RESULTADO: NENHUMA VALIDACAO REGISTRADA" -ForegroundColor Red
            Write-Host ""
            Write-Host "  *** ATENCAO: Tech Lead deve ser notificado ***" -ForegroundColor Red
            Write-Host ""
            Write-Host "  O objeto '$ObjectName' nao tem validacao registrada no registry." -ForegroundColor White
            Write-Host "  Conforme a regra do processo, a publicacao e BLOQUEADA ate que:" -ForegroundColor Yellow
            Write-Host "    1. O Tech Lead registre uma validacao para este tipo de objeto" -ForegroundColor White
            Write-Host "    2. OU um usuario autorizado faca bypass com justificativa" -ForegroundColor White
            Write-Host ""
            Write-Host "  Para registrar validacao:" -ForegroundColor Cyan
            Write-Host "    validation-registry.ps1 -Action add ..." -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Para bypass (requer autorizacao):" -ForegroundColor Cyan
            Write-Host "    validation-registry.ps1 -Action bypass -ObjectName $ObjectName -User [usuario] -BypassReason '[justificativa]'" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  VEREDITO: blocked" -ForegroundColor Red
            exit 2  # exit code 2 = blocked, no validation
        }

        Write-Host "  RESULTADO: $($matched.Count) validacao(oes) encontrada(s)" -ForegroundColor Green
        Write-Host ""

        foreach ($v in $matched) {
            Write-Host "  [$($v.id)] $($v.processType)" -ForegroundColor Yellow
            Write-Host "    Descricao:    $($v.description)" -ForegroundColor White
            Write-Host "    Dimensoes:    $($v.requiredDimensions -join ', ')" -ForegroundColor White
            Write-Host "    Queries:      $($v.validationQueries.Count) query(s) de validacao" -ForegroundColor DarkGray
            Write-Host ""

            Write-Host "    QUERIES DE VALIDACAO (executar no QAS apos dry-run):" -ForegroundColor Cyan
            foreach ($q in $v.validationQueries) {
                Write-Host "      - $($q.name): $($q.description)" -ForegroundColor White
                Write-Host "        $($q.query)" -ForegroundColor DarkGray
            }
            Write-Host ""
        }

        Write-Host "  VEREDITO: conditional" -ForegroundColor Yellow
        Write-Host "  Validacao especifica requerida. Executar as queries no QAS antes do PROD." -ForegroundColor White
    }

    "list" {
        Write-Host ""
        Write-Host "=== VALIDATION REGISTRY ===" -ForegroundColor Cyan
        Write-Host ""

        if ($registry.validations.Count -eq 0) {
            Write-Host "  Nenhuma validacao cadastrada." -ForegroundColor DarkGray
            return
        }

        foreach ($v in $registry.validations) {
            $status = if ($v.enabled) { "ATIVA" } else { "INATIVA" }
            $statusColor = if ($v.enabled) { "Green" } else { "DarkGray" }
            Write-Host "  [$($v.id)] $($v.processType) ($status)" -ForegroundColor $statusColor
            Write-Host "    Descricao:    $($v.description)" -ForegroundColor White
            Write-Host "    Patterns:     $($v.objectPatterns -join ', ')" -ForegroundColor DarkGray
            Write-Host "    Tipos:        $($v.objectTypes -join ', ')" -ForegroundColor DarkGray
            Write-Host "    Dimensoes:    $($v.requiredDimensions -join ', ')" -ForegroundColor DarkGray
            Write-Host "    Queries:      $($v.validationQueries.Count)" -ForegroundColor DarkGray
            Write-Host "    Criado por:   $($v.createdBy)" -ForegroundColor DarkGray
            Write-Host ""
        }

        Write-Host "  Editores autorizados: $($registry.authorizedEditors -join ', ')" -ForegroundColor DarkGray
        Write-Host "  Bypass autorizados:   $($registry.authorizedBypass -join ', ')" -ForegroundColor DarkGray
    }

    "add" {
        if (-not $User) {
            Write-Host "ERRO: User e obrigatorio para add." -ForegroundColor Red
            exit 1
        }
        if ($registry.authorizedEditors -notcontains $User) {
            Write-Host "ERRO: Usuario '$User' nao tem permissao para editar o registry." -ForegroundColor Red
            Write-Host "  Editores autorizados: $($registry.authorizedEditors -join ', ')" -ForegroundColor Yellow
            exit 1
        }
        # add sera implementado via edicao manual do registry.json ou via script interativo
        Write-Host "Para adicionar uma validacao, edite validations/registry.json manualmente." -ForegroundColor Yellow
        Write-Host "Usuario $User tem permissao de edicao." -ForegroundColor Green
    }

    "remove" {
        if (-not $User) {
            Write-Host "ERRO: User e obrigatorio para remove." -ForegroundColor Red
            exit 1
        }
        if ($registry.authorizedEditors -notcontains $User) {
            Write-Host "ERRO: Usuario '$User' nao tem permissao para editar o registry." -ForegroundColor Red
            exit 1
        }
        Write-Host "Para remover a validacao $ValidationId, edite validations/registry.json manualmente." -ForegroundColor Yellow
    }

    "bypass" {
        if (-not $ObjectName -or -not $User -or -not $BypassReason) {
            Write-Host "ERRO: ObjectName, User e BypassReason sao obrigatorios para bypass." -ForegroundColor Red
            exit 1
        }
        if ($registry.authorizedBypass -notcontains $User) {
            Write-Host "ERRO: Usuario '$User' nao tem permissao para bypass de validacao." -ForegroundColor Red
            Write-Host "  Bypass autorizados: $($registry.authorizedBypass -join ', ')" -ForegroundColor Yellow
            exit 1
        }

        # Registra o bypass
        if (-not (Test-Path $bypassLogPath)) {
            '{"version":"1.0","lastUpdated":null,"bypasses":[]}' | Set-Content -Path $bypassLogPath -Encoding utf8
        }
        $log = Get-Content $bypassLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            objectName    = $ObjectName
            objectType    = $ObjectType
            bypassedBy    = $User
            reason        = $BypassReason
            bypassedAt    = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        }
        $log.bypasses = @($log.bypasses + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $bypassLogPath -Encoding utf8

        Write-Host "BYPASS DE VALIDACAO: APROVADO" -ForegroundColor Green
        Write-Host "  Objeto:     $ObjectName ($ObjectType)" -ForegroundColor White
        Write-Host "  Por:         $User" -ForegroundColor White
        Write-Host "  Motivo:      $BypassReason" -ForegroundColor White
        Write-Host "  Timestamp:   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  O deploy pode prosseguir sem validacao especifica." -ForegroundColor Green
        Write-Host "  O bypass fica registrado no log para auditoria." -ForegroundColor DarkGray
    }
}
