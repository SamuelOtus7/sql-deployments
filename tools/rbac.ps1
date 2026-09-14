<#
.SYNOPSIS
    Verifica permissoes de usuario via RBAC.
.DESCRIPTION
    Le config/rbac.json e verifica se o usuario tem a permissao necessaria.
    Identifica o usuario atual via git config user.name ou env USERNAME.

.PARAMETER Action
    check:        verifica se o usuario tem uma permissao especifica
    list:         lista as permissoes do usuario atual
    matrix:       mostra a matriz de permissoes completa
    add-user:     adiciona mapeamento usuario->roles (requer manage-rbac)
    remove-user:  remove mapeamento usuario (requer manage-rbac)

.PARAMETER User
    Usuario a verificar (default: auto-detect via git config user.name)

.PARAMETER Permission
    Permissao a verificar (usado com -Action check)

.PARAMETER NewUser
    Nome do novo usuario (usado com -Action add-user)

.PARAMETER NewRoles
    Roles do novo usuario (array, usado com -Action add-user)

.EXAMPLE
    .\rbac.ps1 -Action check -Permission publish-without-validation
    .\rbac.ps1 -Action list
    .\rbac.ps1 -Action matrix
#>
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("check","list","matrix","add-user","remove-user")]
    [string]$Action,

    [string]$User = "",
    [string]$Permission = "",
    [string]$NewUser = "",
    [string[]]$NewRoles = @()
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$rbacPath = Join-Path $repoRoot "config\rbac.json"

if (-not (Test-Path $rbacPath)) {
    Write-Host "ERRO: config/rbac.json nao encontrado." -ForegroundColor Red
    exit 1
}

$rbac = Get-Content $rbacPath -Raw | ConvertFrom-Json

function Get-CurrentUser {
    if ($User) { return $User }
    # Tenta git config user.name
    try {
        $gitUser = git config user.name 2>$null
        if ($gitUser) { return $gitUser.Trim() }
    } catch {}
    # Fallback para env USERNAME
    if ($env:USERNAME) { return $env:USERNAME }
    return "unknown"
}

function Resolve-UserRoles($userName) {
    $roles = @()
    # Case-insensitive lookup
    foreach ($prop in $rbac.users.PSObject.Properties) {
        if ($prop.Name -ieq $userName) {
            $roles = $prop.Value
            break
        }
    }
    return $roles
}

function Resolve-Permissions($userName) {
    $roles = Resolve-UserRoles $userName
    $perms = @()
    foreach ($role in $roles) {
        if ($rbac.roles.PSObject.Properties.Name -contains $role) {
            $perms += $rbac.roles.$role.permissions
        }
    }
    return $perms | Select-Object -Unique
}

switch ($Action) {
    "check" {
        if (-not $Permission) {
            Write-Host "ERRO: Permission e obrigatorio para check." -ForegroundColor Red
            exit 1
        }

        $currentUser = Get-CurrentUser
        $perms = Resolve-Permissions $currentUser

        Write-Host ""
        Write-Host "=== RBAC CHECK ===" -ForegroundColor Cyan
        Write-Host "  Usuario:     $currentUser" -ForegroundColor White
        Write-Host "  Permissao:   $Permission" -ForegroundColor White

        if ($perms -contains $Permission) {
            Write-Host "  Resultado:   PERMITIDO" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "  Resultado:   NEGADO" -ForegroundColor Red
            $roles = Resolve-UserRoles $currentUser
            Write-Host "  Roles:       $($roles -join ', ')" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "  Roles que tem esta permissao:" -ForegroundColor Yellow
            foreach ($roleName in $rbac.roles.PSObject.Properties.Name) {
                if ($rbac.roles.$roleName.permissions -contains $Permission) {
                    Write-Host "    - $roleName" -ForegroundColor Yellow
                }
            }
            exit 3  # exit code 3 = denied
        }
    }

    "list" {
        $currentUser = Get-CurrentUser
        $roles = Resolve-UserRoles $currentUser
        $perms = Resolve-Permissions $currentUser

        Write-Host ""
        Write-Host "=== PERMISSOES DO USUARIO ===" -ForegroundColor Cyan
        Write-Host "  Usuario: $currentUser" -ForegroundColor White
        Write-Host ""
        Write-Host "  Roles:" -ForegroundColor Cyan
        if ($roles.Count -eq 0) {
            Write-Host "    (nenhum role atribuido)" -ForegroundColor Red
            Write-Host "    Contate o admin para ser adicionado em config/rbac.json" -ForegroundColor Yellow
        } else {
            foreach ($r in $roles) {
                $desc = if ($rbac.roles.PSObject.Properties.Name -contains $r) { $rbac.roles.$r.description } else { "(role desconhecido)" }
                Write-Host "    - $r : $desc" -ForegroundColor Green
            }
        }
        Write-Host ""
        Write-Host "  Permissoes ($($perms.Count)):" -ForegroundColor Cyan
        foreach ($p in ($perms | Sort-Object)) {
            Write-Host "    - $p" -ForegroundColor White
        }
    }

    "matrix" {
        Write-Host ""
        Write-Host "=== MATRIZ DE PERMISSOES ===" -ForegroundColor Cyan
        Write-Host ""

        # Coleta todas as permissoes
        $allPerms = @()
        foreach ($roleName in $rbac.roles.PSObject.Properties.Name) {
            $allPerms += $rbac.roles.$roleName.permissions
        }
        $allPerms = $allPerms | Select-Object -Unique | Sort-Object

        # Header
        $roleNames = $rbac.roles.PSObject.Properties.Name
        Write-Host ("  {0,-35}" -f "Permissao") -NoNewline -ForegroundColor Yellow
        foreach ($rn in $roleNames) {
            Write-Host ("{0,-22}" -f $rn) -NoNewline -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Host ("  {0}" -f ("-" * (35 + 22 * $roleNames.Count))) -ForegroundColor DarkGray

        # Linhas
        foreach ($p in $allPerms) {
            Write-Host ("  {0,-35}" -f $p) -NoNewline
            foreach ($rn in $roleNames) {
                $has = $rbac.roles.$rn.permissions -contains $p
                $cell = if ($has) { "[X]" } else { "[ ]" }
                $color = if ($has) { "Green" } else { "DarkGray" }
                Write-Host ("{0,-22}" -f $cell) -NoNewline -ForegroundColor $color
            }
            Write-Host ""
        }

        Write-Host ""
        Write-Host "  Usuarios cadastrados:" -ForegroundColor Cyan
        foreach ($u in $rbac.users.PSObject.Properties.Name) {
            Write-Host "    $u : $($rbac.users.$u -join ', ')" -ForegroundColor White
        }
    }

    "add-user" {
        $currentUser = Get-CurrentUser
        $perms = Resolve-Permissions $currentUser

        if ($perms -notcontains "manage-rbac") {
            Write-Host "ERRO: Usuario '$currentUser' nao tem permissao manage-rbac." -ForegroundColor Red
            exit 3
        }

        if (-not $NewUser -or $NewRoles.Count -eq 0) {
            Write-Host "ERRO: NewUser e NewRoles sao obrigatorios para add-user." -ForegroundColor Red
            exit 1
        }

        # Valida roles
        foreach ($r in $NewRoles) {
            if ($rbac.roles.PSObject.Properties.Name -notcontains $r) {
                Write-Host "ERRO: Role '$r' nao existe." -ForegroundColor Red
                Write-Host "  Roles disponiveis: $($rbac.roles.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow
                exit 1
            }
        }

        # Adiciona usuario
        $rbac.users | Add-Member -NotePropertyName $NewUser -NotePropertyValue $NewRoles -Force
        $rbac | ConvertTo-Json -Depth 10 | Set-Content -Path $rbacPath -Encoding utf8

        Write-Host "Usuario adicionado: $NewUser ($($NewRoles -join ', '))" -ForegroundColor Green
        Write-Host "  Por: $currentUser" -ForegroundColor DarkGray
    }

    "remove-user" {
        $currentUser = Get-CurrentUser
        $perms = Resolve-Permissions $currentUser

        if ($perms -notcontains "manage-rbac") {
            Write-Host "ERRO: Usuario '$currentUser' nao tem permissao manage-rbac." -ForegroundColor Red
            exit 3
        }

        if (-not $NewUser) {
            Write-Host "ERRO: NewUser e obrigatorio para remove-user." -ForegroundColor Red
            exit 1
        }

        if ($rbac.users.PSObject.Properties.Name -notcontains $NewUser) {
            Write-Host "ERRO: Usuario '$NewUser' nao encontrado." -ForegroundColor Red
            exit 1
        }

        $rbac.users.PSObject.Properties.Remove($NewUser)
        $rbac | ConvertTo-Json -Depth 10 | Set-Content -Path $rbacPath -Encoding utf8

        Write-Host "Usuario removido: $NewUser" -ForegroundColor Green
        Write-Host "  Por: $currentUser" -ForegroundColor DarkGray
    }
}
