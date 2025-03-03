# Verifica si el script se está ejecutando como Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como Administrador." -ForegroundColor Red
    exit
}

Write-Host "Fijando IP estática para Servidor FTP" -ForegroundColor Cyan
New-NetIPAddress -IPAddress "10.0.0.19" -InterfaceAlias "Ethernet 2" -PrefixLength 24

# Definir rutas de carpetas principales
$nameserver = "ServidorFTP"
$ftpRoot = "C:\ServidorFTP"
$ftpPublic = "$ftpRoot\Publica"
$ftpReprobados = "$ftpRoot\Reprobados"
$ftpRecursadores = "$ftpRoot\Recursadores"

# Verificar si IIS y el Servidor FTP están instalados
$ftpInstalled = Get-WindowsFeature Web-FTP-Server

if ($ftpInstalled.Installed -eq $false) {
    # Instalación de los componentes necesarios para FTP en IIS
    Write-Host "Instalando componentes necesarios para el Servidor FTP" -ForegroundColor Cyan
    Install-WindowsFeature Web-FTP-Server -IncludeManagementTools -IncludeAllSubFeature
    Install-WindowsFeature Web-Basic-Auth
} else {
    Write-Host "Servidor FTP ya está instalado." -ForegroundColor Green
}

Import-Module WebAdministration


# Crear directorios
Write-Host "Creando directorios..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path "C:\ServidorFTP\" -Force
New-Item -ItemType Directory -Path $ftpPublic -Force
New-Item -ItemType Directory -Path $ftpReprobados -Force
New-Item -ItemType Directory -Path $ftpRecursadores -Force

# Crear y configurar el sitio FTP 
Write-Host "Configurando servidor FTP..." -ForegroundColor Cyan
New-WebFtpSite -Name "$nameServer" -IPAddress "*" -Port 21
Set-ItemProperty "IIS:\Sites\$nameServer" -Name physicalPath -Value 'C:\ServidorFTP\'

# Creación del grupo de usuarios "reprobados" que podrán acceder al FTP
$FTPUserGroupName = "reprobados"
$ADSI = [ADSI]"WinNT://$env:ComputerName"
$FTPUserGroup = $ADSI.Create("Group", "$FTPUserGroupName")
$FTPUserGroup.SetInfo()

# Creación del grupo de usuarios "recursadores" que podrán acceder al FTP
$FTPUserGroupName = "recursadores"
$ADSI = [ADSI]"WinNT://$env:ComputerName"
$FTPUserGroup = $ADSI.Create("Group", "$FTPUserGroupName")
$FTPUserGroup.SetInfo()

# Configurar permisos de acceso:
Write-Host "Configurando permisos de acceso..." -ForegroundColor Cyan

Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="*";permissions=3} -PSPath IIS:\ -Location "$nameServer"

# Le quita las propiedades default a los directorios del servidor FTP que se configuro arriba
Remove-WebConfigurationProperty -PSPath IIS:\ -Location "$nameServer/Publica" -Filter "system.ftpServer/security/authorization" -Name "."
Remove-WebConfigurationProperty -PSPath IIS:\ -Location "$nameServer/Reprobados" -Filter "system.ftpServer/security/authorization" -Name "."
Remove-WebConfigurationProperty -PSPath IIS:\ -Location "$nameServer/Recursadores" -Filter "system.ftpServer/security/authorization" -Name "."

# Permitir acceso anónimo de solo lectura a la carpeta Publica
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="*";permissions=1} -PSPath IIS:\ -Location "$nameserver/Publica"

# Permitir acceso completo a usuarios registrados en Publica
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="reprobados";permissions=3} -PSPath IIS:\ -Location "$nameserver/Publica"
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="recursadores";permissions=3} -PSPath IIS:\ -Location "$nameserver/Publica"

# Permitir acceso completo a cada usuario en su respectiva carpeta
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="reprobados";permissions=3} -PSPath IIS:\ -Location "$nameserver/Reprobados"
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="recursadores";permissions=3} -PSPath IIS:\ -Location "$nameserver/Recursadores"

# Configurar reglas de firewall para FTP
Write-Host "Configurando reglas de firewall..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "FTP" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow

# Habilitar autenticación anónima y básica en FTP
Set-ItemProperty "IIS:\Sites\$nameserver" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value $true
Set-ItemProperty "IIS:\Sites\$nameserver" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true

$IPAddress = [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName()) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -First 1

#Hacer un certificado autofirmado
$certeliminar = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object { $_.Subject -eq "CN=${IPAddress}" }

# Verificar que se haya obtenido el certificado
if ($certeliminar -ne $null) {
    # Eliminar el certificado utilizando la variable
    Remove-Item -Path $certeliminar.PSPath -Force
    Write-Host "El certificado ha sido eliminado correctamente."
} else {
    Write-Host "No se encontró ningún certificado con el nombre CN=${IPAddress}"
}

New-SelfSignedCertificate `
-DnsName "$IPAddress" `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-CertStoreLocation "Cert:\LocalMachine\My" `
-NotAfter (Get-Date).AddYears(1) 

#Obtener el certificado en una variable para luego sacarle el thumbprint
$cert = Get-ChildItem -Path "cert:\LocalMachine\My" | Where-Object {$_.Subject -eq "CN=${IPAddress}" }

$thumbprint = $cert.Thumbprint

# Permitir la autenticación con SSL (opcional, según tus necesidades de seguridad)
Set-ItemProperty "IIS:\Sites\$nameServer" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value 1
Set-ItemProperty "IIS:\Sites\$nameServer" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value 1

Set-ItemProperty "IIS:\Sites\$nameServer" -Name ftpServer.security.ssl.controlChannelPolicy -Value "SslRequire" 
Set-ItemProperty "IIS:\Sites\$nameServer" -Name ftpServer.security.ssl.dataChannelPolicy -Value "SslRequire" 
Clear-Host
Write-Host "Certificado Creado:"
Get-ChildItem Cert:\LocalMachine\My 

Set-ItemProperty "IIS:\Sites\$nameServer" -Name ftpServer.security.ssl.serverCertStoreName -Value "My" 
Set-ItemProperty "IIS:\Sites\$nameServer" -Name ftpServer.security.ssl.serverCertHash -Value $thumbprint
Set-ItemProperty "IIS:\Sites\$nameServer" -Name ftpServer.userIsolation.mode -Value "IsolateRootDirectoryOnly"

# Crear carpeta para usuarios locales
mkdir C:\ServidorFTP\LocalUser -Force
mkdir C:\ServidorFTP\LocalUser\Public -Force

# Enlazar carpeta pública
cmd /c mklink /d "C:\ServidorFTP\LocalUser\Public\Public" "C:\ServidorFTP\Publica"

Restart-WebItem "IIS:\Sites\$nameServer"

# Función para crear un usuario FTP
function CrearUsuarioFTP {
    param(
        [string]$username,
        [string]$password,
        [string]$groupName
    )
    
    $ADSI = [ADSI]"WinNT://$env:ComputerName"
    
    if ($ADSI.Children | Where-Object { $_.Name -eq $username }) {
        Write-Host "El usuario ya existe." -ForegroundColor Yellow
        return
    }
    
    $newUser = $ADSI.Create("User", "$username")
    $newUser.SetInfo()
    $newUser.SetPassword("$password")
    $newUser.SetInfo()
    Write-Host "Usuario $username creado." -ForegroundColor Green
    
    # Agregar usuario a grupo
    $UserAccount = New-Object System.Security.Principal.NTAccount("$username")
    $SID = $UserAccount.Translate([System.Security.Principal.SecurityIdentifier])
    $group = [ADSI]"WinNT://$env:ComputerName/$groupName,group"
    $User = [ADSI]"WinNT://$SID"
    $group.Add($User.Path)

    Write-Host "Usuario $username agregado al grupo $groupName." -ForegroundColor Green
    $group_min = $groupName.ToLower()
    # Crear carpeta personal
    $userFolder = "$ftpRoot\LocalUser\$username\$username"
    New-Item -ItemType Directory -Path $userFolder -Force

    if (-Not (Test-Path "C:\ServidorFTP\LocalUser\$username\Publica\")) {
        cmd /c mklink /d "C:\ServidorFTP\LocalUser\$username\Publica\" "C:\ServidorFTP\Publica\"
    }

    if (-Not (Test-Path "C:\ServidorFTP\LocalUser\$username\$groupName\")) {
        cmd /c mklink /d "C:\ServidorFTP\LocalUser\$username\$groupName\" "C:\ServidorFTP\$groupName\"
    }

    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="$group_min";permissions=7} -PSPath IIS:\ -Location "$nameServer/LocalUser/$username/Publica"
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="$group_min";permissions=3} -PSPath IIS:\ -Location "$nameServer/LocalUser/$username/$groupName"
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="$group_min";permissions=3} -PSPath IIS:\ -Location "$nameServer/LocalUser/$username/$username"

    # Reiniciamos el servidor FTP IIS
    Restart-WebItem "IIS:\Sites\$nameServer"
    Restart-Service ftpsvc

}

# Función para cambiar usuario de grupo
function CambiarGrupo {
    param(
        [string]$username,
        [string]$newGroup
    )
    
    $oldGroup = "reprobados"
    if ($newGroup -eq "reprobados") { $oldGroup = "recursadores" }
    
    $groupOld = [ADSI]"WinNT://$env:ComputerName/$oldGroup,group"
    
    if ($groupOld.Members() -contains "WinNT://$env:ComputerName/$username,user") {
        $groupOld.Remove("WinNT://$env:ComputerName/$username,user")
    }
    
    $UserAccount = New-Object System.Security.Principal.NTAccount("$username")
    $SID = $UserAccount.Translate([System.Security.Principal.SecurityIdentifier])
    $groupNew = [ADSI]"WinNT://$env:ComputerName/$newGroup,group"
    $User = [ADSI]"WinNT://$SID"
    $groupNew.Add($User.Path)

    $enlace_viejo = "$ftpRoot\LocalUser\$username\$groupOld\"
    $enlace_nuevo = "$ftpRoot\LocalUser\$username\$newGroup\"
    $enlace_carpeta = "C:\ServidorFTP\$newGroup\"
    # Eliminar enlace simbólico si existe
    if (Test-Path $enlace_viejo) {
        Remove-Item $enlace_viejo -Force
        Write-Host "Enlace simbólico eliminado: $enlace_viejo" -ForegroundColor Yellow
    }

    # Crear nuevo enlace simbólico al nuevo grupo
    cmd /c mklink /d "$enlace_nuevo" "$enlace_carpeta"
    Write-Host "Nuevo enlace simbólico creado: $enlace_nuevo → $enlace_carpeta" -ForegroundColor Green

    Write-Host "Usuario $username movido a $newGroup." -ForegroundColor Green
    
    # Reiniciamos el servidor FTP IIS
    Restart-WebItem "IIS:\Sites\$nameServer"
    Restart-Service ftpsvc

}

# Menú interactivo
while ($true) {
    Write-Host "--- SERVIDOR FTP ---" -ForegroundColor Cyan
    Write-Host "1. Crear usuario FTP"
    Write-Host "2. Cambiar usuario de grupo"
    Write-Host "3. Salir"
    
    $option = Read-Host "Seleccione una opcion"
    
    switch ($option) {
        "1" {
            $username = Read-Host "Ingrese nombre de usuario"
            $password = Read-Host "Ingrese password" -AsSecureString
            Write-Host "Seleccione el grupo:"
            Write-Host "1) Reprobados"
            Write-Host "2) Recursadores"
            $groupOption = Read-Host "Ingrese una opcion"

            if ($groupOption -eq "1") 
            {
                CrearUsuarioFTP -username $username -password (New-Object PSCredential "user", $password).GetNetworkCredential().Password -groupName "reprobados"
            }
            elseif ($groupOption -eq "2") {
                CrearUsuarioFTP -username $username -password (New-Object PSCredential "user", $password).GetNetworkCredential().Password -groupName "recursadores"
            }
            else {
                Write-Host "Opcion de grupo no valida." -ForegroundColor Red            
            }
        }
        "2" {
            $username = Read-Host "Ingrese nombre de usuario"
            Write-Host "Seleccione el grupo:"
            Write-Host "1) Reprobados"
            Write-Host "2) Recursadores"
            $newGroup = Read-Host "Nuevo grupo:"
            
            if ($newGroup -eq "1") 
            {
                CambiarGrupo -username $username -newGroup "reprobados"            
            }
            elseif ($newGroup -eq "2") {
                CambiarGrupo -username $username -newGroup "recursadores"            
            }
            else {
                Write-Host "Opcion de grupo no valida." -ForegroundColor Red            
            }
        }
        "3" {
            exit
        }
        default {
            Write-Host "Opcion no valida." -ForegroundColor Red
        }
    }
}
