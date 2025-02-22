function solicitar_rango {
    param ([string]$mensaje, [string]$ipReferencia)
    do {
        $ip = solicitar_ip $mensaje
        if (-not (validar_rango $ip, $ipReferencia)) {
            Write-Host "La IP debe estar en el mismo rango de red." -ForegroundColor Red
        }
    } until (validar_rango $ip, $ipReferencia)
    return $ip
}
