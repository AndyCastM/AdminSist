function solicitar_dom {
    param ([string]$mensaje)
    do {
        $dominio = Read-Host $mensaje
        if (-not (validar_dominio $dominio)) {
            Write-Host "Dominio no valido. Intenta de nuevo." -ForegroundColor Red
        }
    } until (validar_dominio $dominio)
    return $dominio
}