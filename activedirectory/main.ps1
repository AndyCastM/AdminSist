# Importamos el modulo donde estaran las funciones de Active Directory
Import-Module "C:\Users\Administrador\activedirectory\adfunctions.psm1" -Force

# Fijamos la IP
$ip = "10.0.0.12"
#New-NetIPAddress -IPAddress $ip -InterfaceAlias "Ethernet 2" -PrefixLength 24

# Verificamos si el rol de Active Directory esta instalado
$adRole = Get-WindowsFeature -Name AD-Domain-Services

if ($adRole.Installed) {
    Write-Host "El rol de Active Directory ya está instalado." -ForegroundColor Yellow
} else {
    Write-Host "Instalando el rol de Active Directory..." -ForegroundColor Green
    # Instalamos el rol de Active Directory
    instalar_ad
}

while ($true) {
    Write-Host "--- P9. Active Directory ---" -ForegroundColor Green
    Write-Host "1. Crear OUs (Cuates, No Cuates)" -ForegroundColor Green
    Write-Host "2. Crear Usuarios" -ForegroundColor Green
    Write-Host "3. Salir" -ForegroundColor Green

    $opc = Read-Host "Seleccione una opcion"

    switch ($opc){
        "1" {
            Write-Host "Creando OUs..." -ForegroundColor Green
            crear_ou
            Write-Host "OUs creadas exitosamente." -ForegroundColor Green
        }
        "2" {
            $usuario = solicitar_usuario "Ingrese nombre de usuario"
            if ([string]::IsNullOrEmpty($usuario)){
                break
            }
            $ou = menu_ou
            if ([string]::IsNullOrEmpty($ou)){
                break
            }
            Write-Host "Creando Usuario..." -ForegroundColor Green
            # Falta preguntar por el OU
            crear_usuario "$usuario" "$ou"
            Write-Host "Usuario creado exitosamente." -ForegroundColor Green
        }
        "3" {
            Write-Host "Saliendo..." -ForegroundColor Green
            exit
        }
        default {
            Write-Host "Opcion no valida. Intente de nuevo." -ForegroundColor Red
        }
    }
}