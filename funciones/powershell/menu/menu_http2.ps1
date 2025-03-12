function menu_http2{
    param (
        [string]$service,
        [string]$stable,
        [string]$mainline
    )
    Write-Host "--- $service ---"

    Write-Host "1. Version LTS: $stable"
    Write-Host "2. Version de desarrollo: $mainline"
    Write-Host "3. Salir"
}