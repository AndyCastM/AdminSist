
function cert_nginx {
    param(
        [int]$port
    )

    Write-Host "Activando SSL en Nginx..." -ForegroundColor Yellow
    $RutaDestino = "C:\nginx"
    $SSLDir = Join-Path $RutaDestino "conf\ssl"
    $opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"

    # Crear el directorio SSL si no existe
    if (-not (Test-Path $SSLDir)) {
        New-Item -Path $SSLDir -ItemType Directory -Force | Out-Null
    }

    # Rutas de los archivos de certificado y clave privada
    $CertFile = Join-Path $SSLDir "nginx-selfsigned.crt"
    $KeyFile = Join-Path $SSLDir "nginx-selfsigned.key"

    # Generar un certificado autofirmado si no existe
    if (-not (Test-Path $CertFile) -or -not (Test-Path $KeyFile)) {
        if (Test-Path $opensslPath) {
            Write-Host "Generando un certificado autofirmado para Nginx..." -ForegroundColor Yellow
            & $opensslPath req -x509 -nodes -days 365 -newkey rsa:2048 `
                -keyout $KeyFile -out $CertFile -subj "/C=MX/ST=Sinaloa/L=LosMochis/O=Org/OU=IT/CN=localhost"
        } else {
            Write-Host "OpenSSL no encontrado en $opensslPath" -ForegroundColor Red
            return
        }
    }

    # Ruta del archivo de configuración de Nginx
    $ArchivoConf = Join-Path $RutaDestino "conf\nginx.conf"

    # Comprobar si ya hay una configuración SSL en nginx.conf
    if (Select-String -Path $ArchivoConf -Pattern "listen $port ssl" -Quiet) {
        Write-Host "La configuración SSL ya está presente en nginx.conf" -ForegroundColor Green
    } else {
        # Configuración SSL para Nginx
        $SSLConfig = @"
server {
    listen $port ssl;
    server_name localhost;

    ssl_certificate "C:/nginx/conf/ssl/nginx-selfsigned.crt";
    ssl_certificate_key "C:/nginx/conf/ssl/nginx-selfsigned.key";

    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout 5m;

    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        root html;
        index index.html index.htm;
    }

    error_log logs/error.log;
    access_log logs/access.log;
}
"@

    $ContenidoActual = Get-Content $ArchivoConf -Raw

    # Si ya tiene "http {" pero no tiene "server { listen $port ssl"
    if ($ContenidoActual -match "http\s*{[^}]*}" -and $ContenidoActual -notmatch "listen $port ssl") {
        # Inserta la configuración SSL dentro del bloque "http { }"
        $ContenidoModificado = $ContenidoActual -replace "(http\s*{)", "`$1`n$SSLConfig"

        # Guarda los cambios
        Set-Content -Path $ArchivoConf -Value $ContenidoModificado
    } elseif ($ContenidoActual -notmatch "http {") {
        # Si no hay "http { }", lo agregamos manualmente
        $ContenidoModificado = "http {`n$SSLConfig`n}" + "`n" + $ContenidoActual
        Set-Content -Path $ArchivoConf -Value $ContenidoModificado
    } else {
        Write-Host "La configuración SSL ya está presente en nginx.conf" -ForegroundColor Green
    }
    }

    # Reglas de firewall
    if (-not (Get-NetFirewallRule | Where-Object { $_.DisplayName -eq "Nginx HTTPS" })) {
        New-NetFirewallRule -DisplayName "Nginx HTTPS" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow
    } else {
        Write-Host "La regla de firewall ya existe." -ForegroundColor Cyan
    }

    # Cerrar procesos que usen el puerto antes de iniciar Nginx
    Write-Host "Verificando procesos en el puerto $port..." -ForegroundColor Yellow
    $procesos = netstat -ano | Select-String ":$port"
    if ($procesos) {
        $procesos -match "\s+(\d+)$" | Out-Null
        $pid_ = $matches[1]
        if ($pid_) {
            Write-Host "Cerrando proceso en el puerto $port (PID: $pid)..." -ForegroundColor Red
            Stop-Process -Id $pid_ -Force
            Start-Sleep -Seconds 2
        }
    }

    cd C:\nginx
    .\nginx.exe -t -c C:\nginx\conf\nginx.conf  # Forzar uso del archivo correcto

    Write-Host "Iniciando Nginx..." -ForegroundColor Yellow
    Start-Process -FilePath "$RutaDestino\nginx.exe" -ArgumentList "-c C:\nginx\conf\nginx.conf" -WorkingDirectory $RutaDestino
    Start-Sleep -Seconds 3

    Write-Host "Recargando configuración de Nginx..." -ForegroundColor Yellow
    Start-Process -FilePath "$RutaDestino\nginx.exe" -ArgumentList "-s reload -c C:\nginx\conf\nginx.conf" -WorkingDirectory $RutaDestino

}
