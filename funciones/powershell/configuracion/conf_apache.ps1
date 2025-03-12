function conf_apache {
    param( 
        [string]$port,
        [string]$version
    )

    # Definir la URL de descarga de Apache con la versión especificada
    $url = "https://www.apachelounge.com/download/VS17/binaries/httpd-$version-250207-win64-VS17.zip"
    $dZip = "$env:USERPROFILE\Downloads\apache-$version.zip"
    $extdestino = "C:\Apache24"

     try {
        Write-Host "Iniciando instalación de Apache HTTP Server versión $version..."

         # Descargar Apache desde la URL especificada
        Write-Host "Descargando Apache desde: $url"
        $agente = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

        # Sobrescribir la política de certificados SSL para evitar problemas con certificados no confiables
        add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

        # Descargar el archivo ZIP de Apache
        Invoke-WebRequest -Uri $url -OutFile $dZip -MaximumRedirection 10 -UserAgent $agente -UseBasicParsing
        Write-Host "Apache descargado en: $dZip"

        # Extraer el contenido del ZIP en la carpeta de destino
        Expand-Archive -Path $dZip -DestinationPath "C:\" -Force
        Remove-Item -Path $dZip -Force   # Eliminar el archivo ZIP después de extraerlo
        
         # Configurar el puerto en el archivo de configuración httpd.conf
        $configFile = Join-Path $extdestino "conf\httpd.conf"
        if (Test-Path $configFile) {
            (Get-Content $configFile) -replace "Listen 80", "Listen $port" | Set-Content $configFile
            Write-Host "Configuración actualizada para escuchar en el puerto $port"
        } else {
            Write-Host "Error: No se encontró el archivo de configuración en $configFile"
            return
        }

         # Buscar el ejecutable de Apache dentro de la carpeta extraída
        $apacheExe = Get-ChildItem -Path $extdestino -Recurse -Filter httpd.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($apacheExe) {
            $exeApache = $apacheExe.FullName
            Write-Host "Instalando Apache como servicio..."
            # Instalar Apache como un servicio de Windows
            Start-Process -FilePath $exeApache -ArgumentList '-k', 'install', '-n', 'Apache24' -NoNewWindow -Wait
            Write-Host "Iniciando servicio Apache..."
            Start-Service -Name "Apache24"
            Write-Host "Apache instalado y ejecutándose en el puerto $:port"

            # Habilitar el puerto en el firewall al final de la instalación
            New-NetFirewallRule -DisplayName "Abrir Puerto $port" -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow
        } else {
            Write-Host "Error: No se encontró el ejecutable httpd.exe en $extdestino"
        }
    } catch {
        Write-Host "Error durante la instalación de Apache: $_"
    }

}