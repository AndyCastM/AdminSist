function ftphttp {
    $ftpServer = "10.0.0.17"
    $ftpUser = "ftpwindows"
    $ftpPass = "windows"
    $credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

    # Obtener la lista de servicios disponibles en el FTP
    $services = get_FTPList | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    
    if ($services.Count -eq 0) {
        Write-Host "No se encontraron servicios en el FTP." -ForegroundColor Red
        return
    }

    Write-Host "`n= CONFIGURACION DE SERVICIOS HTTP DISPONIBLES =" -ForegroundColor Cyan
    for ($i = 0; $i -lt $services.Count; $i++) {
        Write-Host "$($i+1). $($services[$i])"
    }

    do {
        $op = Read-Host "Elija una opcion (1-$($services.Count)), o escriba 0 para salir"
        if ($op -eq "0") { 
            Write-Host "Saliendo..." -ForegroundColor Yellow
            return
        }
        if ($op -match "^\d+$" -and [int]$op -le $services.Count) {
            break
        } else {
            Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
        }
    } while ($true)

    $selectedService = $services[$op - 1]
    Write-Host "= $selectedService =" -ForegroundColor DarkCyan

    # Obtener la lista de archivos disponibles en la carpeta seleccionada
    $files = listar_http -ftpServer $ftpServer -ftpUser $ftpUser -ftpPass $ftpPass -directory $selectedService

    # Asegurar que la variable es un array
    if ($files -isnot [System.Array]) {
        $files = @($files)
    }

    # Filtrar elementos vacíos y limpiar nombres
    $files = $files | Where-Object { ($_ -match '\S') -and ($_ -ne $null) } | ForEach-Object { $_.Trim() }

    if ($files.Count -eq 0) {
        Write-Host "No se encontraron archivos en el directorio." -ForegroundColor Red
        return
    }

    # Mostrar la lista correctamente con foreach
    $index = 1
    foreach ($file in $files) {
        Write-Host "$index. $file"
        $index++
    }

    do {
        $op2 = Read-Host "Elija la version que desea instalar (1-$($files.Count)), o escriba 0 para salir"
        if ($op2 -eq "0") { 
            Write-Host "Saliendo..." -ForegroundColor Yellow
            return
        }
        if ($op2 -match "^\d+$" -and [int]$op2 -le $files.Count) {
            break
        } else {
            Write-Host "Opcion no valida. Intente de nuevo" -ForegroundColor Red
        }
    } while ($true)

    # Asignar versión seleccionada
    $selectedFile = $files[$op2 -1]
    $version = extraer_version -fileName "$selectedFile"

    if ($null -eq $version) {
        return
    }

    Write-Host "Instalador $selectedFile seleccionado de $selectedService" -ForegroundColor DarkCyan

    $port = solicitar_puerto "Ingrese el puerto para $selectedService (1024-65535)"
    if ([string]::IsNullOrEmpty($port)){ return }

    # Descargar e instalar el servicio
    Write-Host "Descargando $selectedService $version..."
    if ($selectedService -eq "Apache") {
        conf_apache_ftp -port "$port" -version "$version"
    } elseif ($selectedService -eq "Nginx") {
        conf_nginx_ftp -port "$port" -version "$version"
    } else {
        Write-Host "Servicio desconocido: $selectedService" -ForegroundColor Red
        return
    }

    # Configurar SSL opcionalmente
    menu_cert
    do {
        $opSSL = Read-Host "Desea configurar SSL? (1-Si, 2-No)"
        if ($opSSL -match "^[12]$") {
            break
        } else {
            Write-Host "Opción no valida. Intente de nuevo" -ForegroundColor Red
        }
    } while ($true)

    if ($opSSL -eq "1") {
        Write-Host "Configurando certificado SSL..."
        if ($selectedService -eq "Apache") {
            cert_apache -port "$port"
        } elseif ($selectedService -eq "Nginx") {
            cert_nginx -port "$port"
        }
    } else {
        Write-Host "No se configurara SSL."
    }

    Write-Host "$selectedService instalado y configurado en el puerto $port" -ForegroundColor Green
}
