function extraer_version {
    param (
        [string]$fileName
    )

    # Expresión regular para versiones en formato X.Y.Z
    if ($fileName -match "(\d+\.\d+\.\d+)") {
        return $matches[1]
    } else {
        Write-Host "No se encontró versión en el archivo: $fileName" -ForegroundColor Red
        return $null
    }
}