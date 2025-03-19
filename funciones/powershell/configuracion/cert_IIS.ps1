function cert_IIS {
    param(
        [int]$port
    )

    Write-Host "Configurando certificado SSL para IIS en el puerto $port..." -ForegroundColor Cyan
                
    # Verificar si el sitio "Default Web Site" existe
    $site = Get-WebSite | Where-Object { $_.Name -eq "Default Web Site" }
    if ($site) {
        Remove-Website "Default Web Site"
        #Write-Host "El sitio 'Default Web Site' ya existe." -ForegroundColor Yellow
        New-WebSite -Name "Default Web Site" -Port $port -PhysicalPath "%SystemDrive%\inetpub\wwwroot" -Ssl
    } else {
        Write-Host "Creando el sitio 'Default Web Site' en el puerto $port..." -ForegroundColor Cyan
        New-WebSite -Name "Default Web Site" -Port $port -PhysicalPath "%SystemDrive%\inetpub\wwwroot" -Ssl
    }

    # Verificar y eliminar bindings HTTP/HTTPS si ya existen
    $bindingHttp = Get-WebBinding -Name "Default Web Site" | Where-Object { $_.protocol -eq "http" -and $_.bindingInformation -like "*:80:*" }
    if ($bindingHttp) {
        Remove-WebBinding -Name "Default Web Site" -Protocol "http" -BindingInformation "*:80:"
        Write-Host "Se eliminó el binding HTTP en el puerto 80." -ForegroundColor Green
    }

    $bindingHttps = Get-WebBinding -Name "Default Web Site" | Where-Object { $_.protocol -eq "https" -and $_.bindingInformation -like "*:${port}:*" }
    if ($bindingHttps) {
        Remove-WebBinding -Name "Default Web Site" -Protocol "https" -BindingInformation "*:${port}:"
        Write-Host "Se eliminó el binding HTTPS en el puerto $port." -ForegroundColor Green
    }

    # Crear un certificado autofirmado
    $certificado = New-SelfSignedCertificate -DnsName "10.0.0.19" -CertStoreLocation "Cert:\LocalMachine\My"

    if (-not $certificado) {
        Write-Host "Error al crear el certificado autofirmado." -ForegroundColor Red
        return
    }

    Write-Host "Certificado autofirmado creado correctamente." -ForegroundColor Green

    # Agregar un nuevo binding HTTPS en el puerto especificado
    New-WebBinding -Name "Default Web Site" -Protocol "https" -Port $port

    # Asociar el certificado al binding HTTPS usando netsh
    $appId = "{4dc3e181-e14b-4a21-b022-59fc669b0914}"  # AppID de IIS
    $cmd = "netsh http add sslcert ipport=0.0.0.0:$port certhash=$($certificado.Thumbprint) appid=`"$appId`""
    
    Invoke-Expression $cmd

    Write-Host "Certificado asignado correctamente al servicio IIS." -ForegroundColor Green

    # Reiniciar IIS para aplicar los cambios
    iisreset
}
