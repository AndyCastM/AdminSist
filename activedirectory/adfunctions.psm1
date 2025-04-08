#Variables globales
$global:dominio = "aprobados.com"
$global:netbios = "APROBADOS"
$global:ou1 = "cuates"
$global:ou2 = "no cuates"

# Separar nombre y extensión
$global:partesDominio = $global:dominio -split "\."
# Asignar nombre y extensión por separado
$global:nombreDominio = $global:partesDominio[0]         
$global:extensionDominio = $global:partesDominio[1]      

# DN base para creacion de OU, usuarios
$global:baseDN = "DC=$($global:nombreDominio),DC=$($global:extensionDominio)"

# OU Paths
# $global:ouPath1 = "OU=$($global:ou1),$($global:baseDN)"
# $global:ouPath2 = "OU=$($global:ou2),$($global:baseDN)"

function instalar_ad(){
    # Instala el rol de Active Directory Domain Services
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

    # Importa el módulo de Active Directory
    Import-Module ActiveDirectory

    # Promover a controlador de dominio
    Install-ADDSForest `
    -DomainName $global:dominio `
    -DomainNetbiosName $global:netbios `
    -InstallDNS `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
}

function crear_ou() {
    # Crear OUs
    New-ADOrganizationalUnit -Name $global:ou1 -Path $global:baseDN
    New-ADOrganizationalUnit -Name $global:ou2 -Path $global:baseDN
}

function solicitar_usuario {
    param ([string]$mensaje)

    while ($true) {
        $usuario = Read-Host $mensaje

        if (-not (validar_usuario $usuario)) {
            Write-Host "Usuario no válido. Intenta de nuevo." -ForegroundColor Red
        } elseif (usuario_existe $usuario) {
            Write-Host "El usuario '$usuario' ya existe en Active Directory. Intenta de nuevo." -ForegroundColor Red
        } else {
            return $usuario
        }
    }
}

function validar_usuario {
    param (
        [string]$usuario,
        [int]$minLength = 5
    )

    $regex = '^[a-zA-Z][a-zA-Z0-9]*$'

    if ($usuario.Length -lt $minLength) {
        return $false
    }

    return $usuario -match $regex  
}

function usuario_existe {
    param (
        [string]$usuario
    )

    try {
        Get-ADUser -Identity $usuario -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function solicitar_contra {
    param (
        [string]$usuario
    )

    while ($true) {
        $contra1 = Read-Host "Ingresa la contraseña para el usuario '$usuario'" -AsSecureString
        $contra2 = Read-Host "Confirma la contraseña" -AsSecureString

        # Convertir SecureString a texto plano para validación
        $plain1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($contra1)
        )
        $plain2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($contra2)
        )

        if ($plain1 -ne $plain2) {
            Write-Host "Las contraseñas no coinciden. Intenta de nuevo." -ForegroundColor Red
        } elseif ($plain1.Length -lt 5 -or
                  $plain1 -notmatch '[A-Z]' -or
                  $plain1 -notmatch '[a-z]' -or
                  $plain1 -notmatch '[0-9]' -or
                  $plain1 -notmatch '[^a-zA-Z0-9]') {
            Write-Host "La contraseña no es valida. Debe tener al menos 5 caracteres, incluir una mayuscula, una minuscula, un numero y un simbolo especial." -ForegroundColor Red
        } else {
            Write-Host "Contraseña valida." -ForegroundColor Green
            return $contra1  # Devuelve la contraseña como SecureString
        }
    }
}

function crear_usuario {
    param (
        [string]$usario,
        [string]$ou
    )

    # Solicitar la contraseña (secure)
    $contra = solicitar_contra -usuario $usuario

    $dnOu = "OU=$ou,$global:baseDN"
    
    if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$dnOu)" -ErrorAction SilentlyContinue) {
        $securePass = ConvertTo-SecureString $contra -AsPlainText -Force

        New-ADUser `
            -Name $usuario `
            -SamAccountName $usuario `
            -UserPrincipalName "$usuario@$global:dominio" `
            -AccountPassword $securePass `
            -Enabled $true `
            -Path $dnOu

        Write-Host "Usuario '$usuario' creado en OU '$ou'." -ForegroundColor Green
    } else {
        Write-Host "La OU '$ou' no existe. No se puede crear el usuario." -ForegroundColor Red
    }
}
