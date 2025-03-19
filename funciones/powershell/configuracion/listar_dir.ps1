function listar_dir {
    try {
        $ftpServer = "10.0.0.17"
        $ftpUser = "ftpwindows"
        $ftpPass = "windows"
        $ftpPath = "/"
        $credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

        $request = [System.Net.FtpWebRequest]::Create("ftp://$ftpServer$ftpPath")
        $request.Credentials = $credentials
        $request.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
        $request.UseBinary = $true
        $request.UsePassive = $true
        $response = $request.GetResponse()
        $reader = New-Object System.IO.StreamReader $response.GetResponseStream()
        $fileList = $reader.ReadToEnd() -split "`n"
        $reader.Close()
        $response.Close()

        return $fileList
    } catch {
        Write-Host "Error al conectar con el servidor FTP: $_" -ForegroundColor Red
        return @()
    }
}