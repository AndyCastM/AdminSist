function solicitar_user {
    param ([string]$mensaje)
    do {
        $user = Read-Host $mensaje
        if (-not (validar_user $user)) {
            Write-Host "Usuario no valido. Intenta de nuevo." -ForegroundColor Red
        }
    } until (validar_user $user)
    return $user
}