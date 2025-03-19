function ftphttp {
    $ftpUser = "ftpwindows"
    $ftpPass = "windows"
    $credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)
    # Listar servicios disponibles
    $services = get_FTPList 
    if ($services.Count -eq 0) {
        Write-Host "No se encontraron servicios en el FTP." -ForegroundColor Red
        return
    }

    # Limpiar nombres de servicios para evitar espacios en blanco
    $services = $services | ForEach-Object { $_.Trim() }

    # Mostrar las opciones disponibles
    Write-Host "`n= CONFIGURACION DE SERVICIOS HTTP DISPONIBLES =" -ForegroundColor Cyan
    for ($i = 0; $i -lt $services.Count; $i++) {
        Write-Host "$($i+1). $($services[$i])"
    }

    # Seleccionar servicio
    $op = Read-Host "Elija una opcion (1-2), o escriba 0 para salir"
    if ($op -eq "0") 
    { Write-Host "Saliendo..." -ForegroundColor Yellow; return }
    elseif ($op -eq "1"){
        Write-Host "= Apache =" -ForegroundColor DarkCyan
        $ftpServer = "10.0.0.17"
        $ftpUser = "ftpwindows"
        $ftpPass = "windows"
        $directory = "Apache"
        listar_http -ftpServer $ftpServer -ftpUser $ftpUser -ftpPass $ftpPass -directory $directory
        do {
            $op2 = Read-Host "Desea instalar Apache? 1-Si, 2-No"
            if ($op2 -match "^[12]$") {
                break
            } else {
                Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
            }
        } while ($true)

        if ($op2 -eq "2") 
        { Write-Host "Saliendo..." -ForegroundColor Yellow; return }

        $port = solicitar_puerto "Ingresa el puerto para Apache (1024-65535)"
        if ([string]::IsNullOrEmpty($port)){
            return
        }

        $ftpFileUrl = "ftp://$ftpServer/$directory/httpd-2.4.63-250207-win64-VS17.zip"
        $dZip = "$env:USERPROFILE\Downloads\apache-2.4.63.zip"
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
        } else {
            Write-Host "Error: No se encontró el ejecutable httpd.exe en $extdestino"
        }

        menu_cert
        do {
            $op2 = Read-Host "Elija una opcion (1-2)"
            if ($op2 -match "^[12]$") {
                break
            } else {
                Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
            }
        } while ($true)
                                
        Write-Host "Opcion seleccionada: $op2"
                                
        if ($op2 -eq "1") {
            Write-Host "Configurando certificado SSL..."
            cert_apache -port "$port"
        } else {
            Write-Host "No se configurará SSL."
        }
    } elseif ($op -eq "2"){
        Write-Host "= Nginx =" -ForegroundColor DarkCyan
        $ftpServer = "10.0.0.17"
        $ftpUser = "ftpwindows"
        $ftpPass = "windows"
        $directory = "Nginx"
        listar_http -ftpServer $ftpServer -ftpUser $ftpUser -ftpPass $ftpPass -directory $directory
        do {
            $op2 = Read-Host "Elija la version que desea instalar: (1-2)"
            if ([string]::IsNullOrEmpty($op2)){
                return
            }
            if ($op2 -match "^[12]$") {
                break
            } else {
                Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
            }
        } while ($true)

        if ($op2 -eq "1") {
            $port = solicitar_puerto "Ingresa el puerto para Nginx (1024-65535)"
            if ([string]::IsNullOrEmpty($port)){
                return
            }
            Write-Host "Descargando Nginx 1.26.3..."
            $version = "1.26.3"
            conf_nginx_ftp -port "$port" -version "$version"
        } else {
            $port = solicitar_puerto "Ingresa el puerto para Nginx (1024-65535)"
            if ([string]::IsNullOrEmpty($port)){
                return
            }
            Write-Host "Descargando Nginx 1.27.4..."
            $version = "1.27.4"
            conf_nginx_ftp -port "$port" -version "$version"
        }

        menu_cert
        do {
            $op2 = Read-Host "Elija una opcion (1-2)"
            if ($op2 -match "^[12]$") {
                break
            } else {
                Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
            }
        } while ($true)
                                
        Write-Host "Opcion seleccionada: $op2"
                                
        if ($op2 -eq "1") {
            Write-Host "Configurando certificado SSL..."
            cert_nginx -port "$port"
        } else {
            Write-Host "No se configurara SSL."
        }
        
    }

}