function cert_apache{
    param(
        [int]$port
    )
    Write-Host "Activando SSL en Apache..." -ForegroundColor Yellow
    $extdestino = "C:\Apache24"
    $ArchivoConf = Join-Path $extdestino "conf\httpd.conf"

    # Crear el directorio ssl dentro de la configuración de Apache si no existe,
    # se usará para almacenar el certificado SSL
    $SSLDir = Join-Path $extdestino "conf\ssl"
    if (-not (Test-Path $SSLDir)) {
        New-Item -Path $SSLDir -ItemType Directory
    }

    # Definir rutas para los archivos de certificado 
    $CertFile = Join-Path $SSLDir "apache-selfsigned.crt"
    $KeyFile = Join-Path $SSLDir "apache-selfsigned.key"
    $opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"

    # Si no existe, generar un certificado SSL autofirmado con OpenSSL
    if (-not (Test-Path $CertFile) -or -not (Test-Path $KeyFile)) {
        Write-Host "Generando un certificado autofirmado..." -ForegroundColor Yellow
        & $opensslPath req -x509 -nodes -days 365 -newkey rsa:2048 `
            -keyout $KeyFile -out $CertFile -subj "/C=MX/ST=Sinaloa/L=LosMochis/O=Org/OU=IT/CN=localhost"
    }

    # Configurar el archivo httpd-ssl.conf para habilitar SSL en Apache
    $SSLConfig = Join-Path $extdestino "conf\extra\httpd-ssl.conf"
    Write-Host "Configurando SSL en Apache..." -ForegroundColor Yellow
    @"
<VirtualHost *:$port>
    ServerName localhost
    DocumentRoot "C:/Apache24/htdocs"

    SSLEngine on
    SSLCertificateFile "$SSLDir/apache-selfsigned.crt"
    SSLCertificateKeyFile "$SSLDir/apache-selfsigned.key"

    <Directory "C:/Apache24/htdocs">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "C:/Apache24/logs/error_log"
    CustomLog "C:/Apache24/logs/access_log" common
</VirtualHost>
"@ | Set-Content -Path $SSLConfig

    # Agregar la directiva Include al archivo de configuración principal
    Add-Content -Path $ArchivoConf -Value "Include conf/extra/httpd-ssl.conf"
    Write-Host "SSL configurado correctamente en Apache para el puerto $port." -ForegroundColor Green

    # Evitar advertencias configurando ServerName en el archivo principal de configuración
    Add-Content -Path $ArchivoConf -Value "ServerName localhost:$port"

    #Habilitar regla de firewall
    New-NetFirewallRule -DisplayName "Apache HTTP/S Server" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow

    #Habilitar los modulos SSL
    $sslModule = "LoadModule ssl_module modules/mod_ssl.so"
    $socacheModule = "LoadModule socache_shmcb_module modules/mod_socache_shmcb.so"

    #Verificamos si las líneas ya están habilitadas
    $sslModuleEnabled = (Get-Content $ArchivoConf) -contains $sslModule
    $socacheModuleEnabled = (Get-Content $ArchivoConf) -contains $socacheModule

    #Si los modulos no estan habilitados, los descomenta en el archivo de configuración de Apache.
    if (-not $sslModuleEnabled) {
        (Get-Content $ArchivoConf) | ForEach-Object { 
            if ($_ -match "#$sslModule") {
                $_ -replace "#$sslModule", $sslModule
            } else {
                $_
            }
        } | Set-Content $ArchivoConf
    }

    if (-not $socacheModuleEnabled) {
        (Get-Content $ArchivoConf) | ForEach-Object { 
            if ($_ -match "#$socacheModule") {
                $_ -replace "#$socacheModule", $socacheModule
            } else {
                $_
            }
        } | Set-Content $ArchivoConf
    }
    # Reiniciar Apache para aplicar cambios
    Write-Host "Reiniciando Apache para aplicar configuración SSL..." -ForegroundColor Yellow
    Restart-Service -Name "Apache24" -Force
    Write-Host "Apache reiniciado exitosamente con SSL habilitado." -ForegroundColor Green
}