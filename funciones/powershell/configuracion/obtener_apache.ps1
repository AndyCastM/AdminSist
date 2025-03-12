function obtener_apache {
    $pagina_descarga = Invoke-WebRequest -Uri "https://httpd.apache.org/download.cgi" -UseBasicParsing
    $versiones = [regex]::Matches($pagina_descarga.Content, "httpd-(\d+\.\d+\.\d+)") | ForEach-Object { $_.Groups[1].Value }

    #Verificar si se encontraron versiones
    if (-not $versiones) {
        Write-Host "ERROR: No se encontraron versiones disponibles en la página."
        return
    }

    #Ordenar versiones de menor a mayor
    $versiones_ordenadas = $versiones | Sort-Object { [System.Version]$_ }

    #Obtener la última versión estable (la más reciente)
    $ver_lts = $versiones_ordenadas[-1]

    #Obtener la última versión de desarrollo (si existe)
    $ver_dev = ($versiones_ordenadas | Where-Object { $_ -ne $ver_lts } | Select-Object -Last 1)

    #Validar si la versión de desarrollo es válida
    if (-not $ver_dev -or $ver_dev -match "^\d+\.[0-3]\.") {
        $ver_dev = "No hay version de desarrollo disponible"
    }

    #Mostrar los resultados
    Write-Host "Version LTS Apache: $ver_lts"
    Write-Host "Version De Desarrollo Apache: $ver_dev"

    #Retornar la version LTS
    return $ver_lts
}