function solicitar_rango {
    param ([string]$mensaje, [string]$ipReferencia)
    do {
        $ip = solicitar_ip $mensaje
        $esValida = validar_rango $ip $ipReferencia  # Guarda el resultado

        if (-not $esValida) {
            Write-Host "La IP debe estar en el mismo rango de red." -ForegroundColor Red
        }
    } until ($esValida)  
    return $ip
}
