function solicitar_ip {
    param ([string]$mensaje)
    do {
        $ip = Read-Host $mensaje
        if (-not (validar_ip $ip)) {
            Write-Host "IP no valida. Intenta de nuevo." -ForegroundColor Red
        }
    } until (validar_ip $ip)
    return $ip
}
