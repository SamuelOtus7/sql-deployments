<#
.SYNOPSIS
    Re-aplica scripts em andamento apos refresh do QAS.
.DESCRIPTION
    O QAS e apagado e recriado a partir do PROD semanalmente (manual).
    Scripts que desenvolvedores estavam testando somem do QAS, mas estao no Git.
    Esta ferramenta re-aplica os scripts em andamento e detecta conflitos
    (se PROD mudou o mesmo objeto que o dev estava trabalhando).

    Conceito-chave: Git e a fonte da verdade, nao o banco. QAS e descartavel por design.

    Fluxo:
    1. Alguem faz o refresh manual do QAS a partir do PROD
    2. Dev diz no chat: "Pos-refresh QAS"
    3. Agente le scripts/qas-state.json (scripts em andamento)
    4. Para cada script em andamento:
       a. CONFLITO - comparar hash do objeto no QAS (agora = PROD) com hash registrado antes
          - Se hash mudou -> PROD alterou o mesmo objeto -> BLOQUEAR + avisar dev
          - Se hash igual -> objeto nao mudou no PROD -> seguro para re-aplicar
       b. RE-APLICAR - se nao ha conflito, aplicar o script no QAS via mssql-37.execute_ddl
       c. ATUALIZAR - atualizar qas-state.json com novo hash e nova data
    5. Agente reporta no chat o que foi re-aplicado e o que foi bloqueado

.PARAMETER Action
    check:     verifica conflitos para todos os scripts em andamento
    reapply:   re-aplica um script especifico apos confirmar que nao ha conflito
    status:    mostra status dos scripts em andamento apos refresh
    clear:     limpa o estado QAS (apos refresh, quando nao ha scripts para re-aplicar)

.PARAMETER ReleaseKey
    Chave de release do script a re-aplicar (usado com -Action reapply)

.PARAMETER ObjectName
    Nome do objeto a verificar conflito

.PARAMETER CurrentHash
    Hash atual do objeto no QAS apos refresh (deve ser igual ao PROD)

.PARAMETER BeforeHash
    Hash do objeto antes da alteracao (registrado no qas-state.json)

.EXAMPLE
    .\qas-refresh.ps1 -Action check
    .\qas-refresh.ps1 -Action reapply -ReleaseKey r20260914-CU8888-a1b2c3d -ObjectName vw_teste -CurrentHash abc123 -BeforeHash abc123
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("check","reapply","status","clear")]
    [string]$Action,

    [string]$ReleaseKey = "",
    [string]$ObjectName = "",
    [string]$CurrentHash = "",
    [string]$BeforeHash = ""
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$qasStatePath = Join-Path $repoRoot "scripts\qas-state.json"
$refreshLogPath = Join-Path $repoRoot "scripts\qas-refresh-log.json"

if (-not (Test-Path $qasStatePath)) {
    '{"version":"1.0","lastUpdated":null,"scripts":[]}' | Set-Content -Path $qasStatePath -Encoding utf8
}

if (-not (Test-Path $refreshLogPath)) {
    '{"version":"1.0","lastUpdated":null,"refreshes":[]}' | Set-Content -Path $refreshLogPath -Encoding utf8
}

switch ($Action) {
    "check" {
        $state = Get-Content $qasStatePath -Raw | ConvertFrom-Json

        Write-Host ""
        Write-Host "=== POS-REFRESH QAS: VERIFICACAO DE CONFLITOS ===" -ForegroundColor Cyan
        Write-Host ""

        if ($state.scripts.Count -eq 0) {
            Write-Host "  Nenhum script em andamento." -ForegroundColor Green
            Write-Host "  QAS limpo e alinhado com PROD. Nada para re-aplicar." -ForegroundColor Green
            return
        }

        Write-Host "  Scripts em andamento: $($state.scripts.Count)" -ForegroundColor Yellow
        Write-Host ""

        $safe = @()
        $conflict = @()

        foreach ($s in $state.scripts) {
            Write-Host "  [$($s.releaseKey)]" -ForegroundColor Yellow
            Write-Host "    Objeto:     $($s.objectName)" -ForegroundColor White
            Write-Host "    Forward:    $($s.forwardScript)" -ForegroundColor DarkGray
            Write-Host "    Hash antes: $($s.objectHash)" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "    Para verificar conflito, o agente deve:" -ForegroundColor Cyan
            Write-Host "      1. Obter hash atual do objeto no QAS via mssql-37.execute_query" -ForegroundColor White
            Write-Host "      2. Comparar com hash registrado antes ($($s.objectHash))" -ForegroundColor White
            Write-Host "      3. Se igual -> seguro para re-aplicar" -ForegroundColor Green
            Write-Host "      4. Se diferente -> CONFLITO (PROD mudou o objeto)" -ForegroundColor Red
            Write-Host ""

            Write-Host "    Query para obter hash atual no QAS:" -ForegroundColor Cyan
            Write-Host @"
SELECT CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', m.definition), 2) AS current_hash
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.name = '$($s.objectName)';
"@ -ForegroundColor Gray
            Write-Host ""
            Write-Host "    Apos obter o hash, executar:" -ForegroundColor Cyan
            Write-Host "      qas-refresh.ps1 -Action reapply -ReleaseKey $($s.releaseKey) -ObjectName $($s.objectName) -CurrentHash <hash_atual> -BeforeHash $($s.objectHash)" -ForegroundColor DarkGray
            Write-Host ""
        }

        Write-Host "  RESUMO:" -ForegroundColor Cyan
        Write-Host "    Total de scripts em andamento: $($state.scripts.Count)" -ForegroundColor White
        Write-Host "    Para cada um, verificar conflito antes de re-aplicar." -ForegroundColor Yellow
    }

    "reapply" {
        if (-not $ReleaseKey -or -not $ObjectName -or -not $CurrentHash -or -not $BeforeHash) {
            Write-Host "ERRO: ReleaseKey, ObjectName, CurrentHash e BeforeHash sao obrigatorios para reapply." -ForegroundColor Red
            exit 1
        }

        Write-Host ""
        Write-Host "=== RE-APLICACAO POS-REFRESH: $ObjectName ===" -ForegroundColor Cyan
        Write-Host "  Release:      $ReleaseKey" -ForegroundColor DarkGray
        Write-Host "  Hash antes:   $BeforeHash" -ForegroundColor DarkGray
        Write-Host "  Hash atual:   $CurrentHash" -ForegroundColor DarkGray
        Write-Host ""

        # Verifica conflito
        if ($CurrentHash -ne $BeforeHash) {
            Write-Host "  RESULTADO: CONFLITO DETECTADO" -ForegroundColor Red
            Write-Host ""
            Write-Host "  O objeto '$ObjectName' mudou no PROD desde que o dev comecou a trabalhar." -ForegroundColor Red
            Write-Host "  Hash antes:  $BeforeHash" -ForegroundColor Red
            Write-Host "  Hash atual:  $CurrentHash" -ForegroundColor Red
            Write-Host ""
            Write-Host "  ACAO NECESSARIA:" -ForegroundColor Cyan
            Write-Host "    1. Dev deve fazer rebase da branch com a main" -ForegroundColor White
            Write-Host "    2. Resolver conflito manualmente" -ForegroundColor White
            Write-Host "    3. Re-testar no QAS" -ForegroundColor White
            Write-Host "    4. NAO re-aplicar ate resolver o conflito" -ForegroundColor Red
            Write-Host ""
            Write-Host "  Re-aplicacao BLOQUEADA." -ForegroundColor Red

            # Registra no log
            $log = Get-Content $refreshLogPath -Raw | ConvertFrom-Json
            $entry = [PSCustomObject]@{
                releaseKey    = $ReleaseKey
                objectName    = $ObjectName
                result        = "conflict"
                beforeHash    = $BeforeHash
                currentHash   = $CurrentHash
                timestamp     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            }
            $log.refreshes = @($log.refreshes + $entry)
            $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
            $log | ConvertTo-Json -Depth 5 | Set-Content -Path $refreshLogPath -Encoding utf8

            exit 5  # exit code 5 = conflict
        }

        Write-Host "  RESULTADO: SEM CONFLITO" -ForegroundColor Green
        Write-Host "  O objeto '$ObjectName' nao mudou no PROD. Seguro para re-aplicar." -ForegroundColor Green
        Write-Host ""
        Write-Host "  PROXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "    1. Agente: re-aplicar o script forward no QAS via mssql-37.execute_ddl" -ForegroundColor White
        Write-Host "    2. Agente: executar smoke test no QAS" -ForegroundColor White
        Write-Host "    3. Agente: atualizar qas-state.json com novo hash" -ForegroundColor White
        Write-Host "    4. Registrar resultado:" -ForegroundColor White
        Write-Host "       qas-state.ps1 -Action add -ReleaseKey $ReleaseKey -ForwardScript <script> -ObjectName $ObjectName -ObjectHash <novo_hash>" -ForegroundColor DarkGray

        # Registra no log
        $log = Get-Content $refreshLogPath -Raw | ConvertFrom-Json
        $entry = [PSCustomObject]@{
            releaseKey    = $ReleaseKey
            objectName    = $ObjectName
            result        = "reapplied"
            beforeHash    = $BeforeHash
            currentHash   = $CurrentHash
            timestamp     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        }
        $log.refreshes = @($log.refreshes + $entry)
        $log.lastUpdated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz")
        $log | ConvertTo-Json -Depth 5 | Set-Content -Path $refreshLogPath -Encoding utf8

        Write-Host ""
        Write-Host "  Re-aplicacao AUTORIZADA." -ForegroundColor Green
    }

    "status" {
        $state = Get-Content $qasStatePath -Raw | ConvertFrom-Json
        $log = Get-Content $refreshLogPath -Raw | ConvertFrom-Json

        Write-Host ""
        Write-Host "=== STATUS POS-REFRESH QAS ===" -ForegroundColor Cyan
        Write-Host ""

        Write-Host "  Scripts em andamento (qas-state.json):" -ForegroundColor Cyan
        if ($state.scripts.Count -eq 0) {
            Write-Host "    Nenhum script em andamento." -ForegroundColor Green
        } else {
            foreach ($s in $state.scripts) {
                Write-Host "    [$($s.releaseKey)] $($s.objectName) (status: $($s.status))" -ForegroundColor White
            }
        }

        Write-Host ""
        Write-Host "  Historico de re-aplicacoes:" -ForegroundColor Cyan
        if ($log.refreshes.Count -eq 0) {
            Write-Host "    Nenhuma re-aplicacao registrada." -ForegroundColor DarkGray
        } else {
            foreach ($r in $log.refreshes) {
                $color = if ($r.result -eq "reapplied") { "Green" } else { "Red" }
                Write-Host "    [$($r.releaseKey)] $($r.objectName): $($r.result)" -ForegroundColor $color
                Write-Host "      Antes: $($r.beforeHash) | Atual: $($r.currentHash)" -ForegroundColor DarkGray
                Write-Host "      Timestamp: $($r.timestamp)" -ForegroundColor DarkGray
            }
        }
    }

    "clear" {
        $state = '{"version":"1.0","lastUpdated":null,"scripts":[]}'
        Set-Content -Path $qasStatePath -Value $state -Encoding utf8
        Write-Host "Estado QAS limpo. Nenhum script em andamento." -ForegroundColor Green
        Write-Host "Use apos confirmar que todos os scripts foram publicados em PROD ou cancelados." -ForegroundColor DarkGray
    }
}
