function solicitar_user {
    param ([string]$mensaje)
    do {
        $user = Read-Host $mensaje

        if (-not (validar_user $user)) {
            Write-Host "Usuario no válido. Intenta de nuevo." -ForegroundColor Red
        } elseif (UsuarioExiste $user) {
            Write-Host "El usuario $user ya existe. Intenta de nuevo." -ForegroundColor Red
        } else {
            return $user  # Devuelve el usuario válido y no existente
        }
    } until ($false)  # El bucle se ejecuta hasta que se retorna un usuario válido
}
