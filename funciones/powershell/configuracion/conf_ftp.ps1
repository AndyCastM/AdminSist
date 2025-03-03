function conf_ftp (){
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

    # Eliminar cualquier configuración anterior de acceso anónimo
    Clear-WebConfiguration "/system.ftpServer/security/authorization" -PSPath IIS:\ -Location "$nameserver/Publica"

    # Permitir acceso anónimo SOLO de lectura
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="anonymous";permissions=1} -PSPath IIS:\ -Location "$nameserver/Publica"

    # Bloquear explícitamente la escritura y modificación para anónimos
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Deny";users="anonymous";permissions=6} -PSPath IIS:\ -Location "$nameserver/Publica"

    # Permitir acceso completo solo a usuarios registrados en Publica
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
}