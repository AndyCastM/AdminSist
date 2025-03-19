
function listar_http {
    param (
        [string]$ftpServer,
        [string]$ftpUser,
        [string]$ftpPass,
        [string]$directory
    )

    # Construcción de la ruta FTP
    $baseFtpPath = "ftp://$ftpServer/"
    $ftpPath = "$baseFtpPath$directory"

    # Credenciales
    $credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

    try {
        # Crear solicitud FTP para listar archivos
        $request = [System.Net.FtpWebRequest]::Create($ftpPath)
        $request.Credentials = $credentials
        $request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
        $request.UseBinary = $true
        $request.UsePassive = $true

        # Obtener respuesta
        $response = $request.GetResponse()
        $reader = New-Object System.IO.StreamReader $response.GetResponseStream()
        $fileList = $reader.ReadToEnd() -split "`n"

        # Cerrar conexiones
        $reader.Close()
        $response.Close()

        Write-Host "Contenido de '$directory':"

        # Limpiar nombres de archivos quitando el prefijo del directorio
        $cleanFileList = $fileList | ForEach-Object { ($_ -replace '^.*/', '').Trim() }
        $cleanFileList | ForEach-Object { Write-Host $_ }
    }
    catch {
        Write-Host "Error al acceder a '$directory': $_" -ForegroundColor Red
    }
}