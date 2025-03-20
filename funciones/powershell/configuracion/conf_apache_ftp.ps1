function conf_apache_ftp {
    param( 
        [string]$port,
        [string]$version
    )

    $ftpServer = "10.0.0.17"
    $ftpUser = "ftpwindows"
    $ftpPass = "windows"
    $directory = "Apache"

    $ftpFileUrl = "ftp://$ftpServer/$directory/httpd-$version-250207-win64-VS17.zip"
    $dZip = "$env:USERPROFILE\Downloads\apache-$version.zip"
    $extdestino = "C:\Apache24"
    $webClient = New-Object System.Net.WebClient
    $webClient.Credentials = $credentials
    $webClient.DownloadFile($ftpFileUrl, $dZip)
    Expand-Archive -Path $dZip -DestinationPath "C:\" -Force
    $configFile = Join-Path $extdestino "conf\httpd.conf"
    if (Test-Path $configFile) {
        (Get-Content $configFile) -replace "Listen 80", "Listen $port" | Set-Content $configFile
        Write-Host "Configuración actualizada para escuchar en el puerto $port" -ForegroundColor Green
    } else {
        Write-Host "Error: No se encontró el archivo de configuración en $configFile"
        return
    }
        
    $apacheExe = Get-ChildItem -Path $extdestino -Recurse -Filter httpd.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($apacheExe) {
        $exeApache = $apacheExe.FullName
        #Write-Host "Instalando Apache como servicio..." -ForegroundColor Green
        # Instalar Apache como un servicio de Windows
        Start-Process -FilePath $exeApache -ArgumentList '-k', 'install', '-n', 'Apache24' -NoNewWindow -Wait
        Write-Host "Iniciando Apache..." -ForegroundColor Green
        Start-Service -Name "Apache24"
        Write-Host "Apache instalado y ejecutándose correctamente en el puerto $:port" -ForegroundColor Green

        # Habilitar el puerto en el firewall al final de la instalación
        New-NetFirewallRule -DisplayName "Abrir Puerto $port" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow
    }
}