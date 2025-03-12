function obtener_nginx {
    $html = Invoke-WebRequest -Uri "https://nginx.org/en/download.html" -UseBasicParsing
    $versions = [regex]::Matches($html.Content, "nginx-(\d+\.\d+\.\d+)") | ForEach-Object { $_.Groups[1].Value }

    # Verificar si se encontraron versiones
    if (-not $versions) {
        Write-Host "ERROR: No se encontraron versiones de NGINX disponibles en la página."
        return $null
    }

    # Ordenar versiones de menor a mayor y eliminar duplicados
    $versions = $versions | Sort-Object { [System.Version]$_ } -Unique

    # Última versión de desarrollo 
    $mainline = $versions[-1]

    # Última versión estable
    $stable = $versions | Where-Object { $_ -ne $mainline } | Select-Object -Last 1

    # Validar si mainline existe, si no, asignar "No disponible"
    if (-not $mainline) {
        $mainline = "No disponible"
    }

    # Retornar ambas versiones como objeto
    return [PSCustomObject]@{
        stable   = $stable
        mainline = $mainline
    }
}

# Uso de la función
$nginx = obtener_nginx

# Acceder a las versiones
Write-Host "Stable: $($nginx.stable)"
Write-Host "Mainline: $($nginx.mainline)"
