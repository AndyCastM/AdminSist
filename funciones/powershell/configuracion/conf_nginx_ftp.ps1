function conf_nginx_ftp{
    param( 
        [string]$port,
        [string]$version
    )

    $ftpServer = "10.0.0.17"
    $ftpUser = "ftpwindows"
    $ftpPass = "windows"
    $directory = "Nginx"

    $ftpFileUrl = "ftp://$ftpServer/$directory/nginx-$version.zip"
    $nginxPath = "C:\nginx"
    $nginxConfPath = "$nginxPath\conf\nginx.conf"
    $zipPath = "$env:TEMP\nginx.zip"

    $webClient = New-Object System.Net.WebClient
    $webClient.Credentials = $credentials
    $webClient.DownloadFile($ftpFileUrl, $zipPath)

    #Descomprimir el archivo
    Expand-Archive -Path $zipPath -DestinationPath "C:\"
    
    #Renombra la carpeta extraída a nginx
    Rename-Item -Path "C:\nginx-$version" -NewName "nginx"
    
    #Configurar el puerto
    (Get-Content $nginxConfPath) -replace "listen       80;", "listen       $port;" | Set-Content $nginxConfPath
    
    #Reemplazar las rutas de los logs en la configuración
    (Get-Content $nginxConfPath) -replace "#error_log\s+logs/error.log;", "error_log C:/nginx/logs/error.log;" | Set-Content $nginxConfPath
    (Get-Content $nginxConfPath) -replace "#pid\s+logs/nginx.pid;", "pid C:/nginx/logs/nginx.pid;" | Set-Content $nginxConfPath
    
    #Iniciamos el servicio
    Start-Process -FilePath "C:\nginx\nginx.exe" -WorkingDirectory "C:\nginx"
    #Verificar si el proceso esta corriendo
    Get-Process -Name nginx
    #Habilitar el puerto en el fireall
    New-NetFirewallRule -DisplayName "Nginx $port" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $port
}