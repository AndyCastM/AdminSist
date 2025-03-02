# Verifica si el script se está ejecutando como Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como Administrador." -ForegroundColor Red
    exit
}

# Instalación de los componentes necesarios para FTP en IIS
Write-Host "Instalando los componentes necesarios..." -ForegroundColor Cyan
Install-WindowsFeature Web-FTP-Server, Web-Basic-Auth -IncludeManagementTools
Import-Module WebAdministration

# Definir rutas de carpetas principales
$ftpRoot = "C:\ServidorFTP"
$ftpPublic = "$ftpRoot\Publica"
$ftpReprobados = "$ftpRoot\Reprobados"
$ftpRecursadores = "$ftpRoot\Recursadores"

# Crear directorios
Write-Host "Creando directorios..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $ftpPublic -Force
New-Item -ItemType Directory -Path $ftpReprobados -Force
New-Item -ItemType Directory -Path $ftpRecursadores -Force

# Crear y configurar el sitio FTP en IIS
Write-Host "Configurando servidor FTP..." -ForegroundColor Cyan
New-WebFtpSite -Name "FTPServidor" -Port 21 -PhysicalPath $ftpRoot -Force
Set-ItemProperty IIS:\Sites\FTPServidor -Name physicalPath -Value $ftpRoot

# Crear grupos de usuarios
$ADSI = [ADSI]"WinNT://$env:ComputerName"
$groupNames = @("reprobados", "recursadores")
foreach ($group in $groupNames) {
    if (-not ($ADSI.Children | Where-Object { $_.Name -eq $group })) {
        $newGroup = $ADSI.Create("Group", $group)
        $newGroup.SetInfo()
        Write-Host "Grupo $group creado." -ForegroundColor Green
    }
}

# Configurar reglas de firewall
Write-Host "Configurando reglas de firewall..." -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "FTP" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow

# Crear un certificado SSL si no existe
$certName = "MiFTP"
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*$certName*" }

if (-not $cert) {
    Write-Host "Creando un nuevo certificado SSL..."
    $cert = New-SelfSignedCertificate -DnsName $certName -CertStoreLocation "Cert:\LocalMachine\My"
}

# Obtener el Thumbprint del Certificado
# El thumbprint es un identificador único de un certificado digital
$thumbprint = $cert.Thumbprint
Write-Host "Certificado encontrado: $thumbprint"

# Asignar el Certificado al Servidor FTP en IIS
Set-ItemProperty -Path "IIS:\Sites\FTPServidor" -Name ftpServer.security.ssl.serverCertHash -Value $thumbprint
Write-Host "Certificado SSL asignado al servidor FTP."

# 4️⃣ Configurar SSL en el canal de control y datos (Forzar SSL)
Set-ItemProperty -Path "IIS:\Sites\FTPServidor" -Name ftpServer.security.ssl.controlChannelPolicy -Value 2
Set-ItemProperty -Path "IIS:\Sites\FTPServidor" -Name ftpServer.security.ssl.dataChannelPolicy -Value 2
Write-Host "SSL requerido en control y datos."


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
    
    $newUser = $ADSI.Create("User", $username)
    $newUser.SetPassword($password)
    $newUser.SetInfo()
    Write-Host "Usuario $username creado." -ForegroundColor Green
    
    # Agregar usuario a grupo
    $group = [ADSI]"WinNT://$env:ComputerName/$groupName,group"
    $group.Add("WinNT://$env:ComputerName/$username,user")
    Write-Host "Usuario $username agregado al grupo $groupName." -ForegroundColor Green
    
    # Crear carpeta personal
    $userFolder = "$ftpRoot\LocalUser\$username"
    New-Item -ItemType Directory -Path $userFolder -Force
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
    $groupNew = [ADSI]"WinNT://$env:ComputerName/$newGroup,group"
    
    $groupOld.Remove("WinNT://$env:ComputerName/$username,user")
    $groupNew.Add("WinNT://$env:ComputerName/$username,user")
    Write-Host "Usuario $username movido a $newGroup." -ForegroundColor Green
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
            $password = Read-Host "Ingrese contraseña" -AsSecureString
            $group = Read-Host "Ingrese grupo (reprobados/recursadores)"
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
            CambiarGrupo -username $username -newGroup $newGroup
        }
        "3" {
            exit
        }
        default {
            Write-Host "Opcion no valida." -ForegroundColor Red
        }
    }
}
