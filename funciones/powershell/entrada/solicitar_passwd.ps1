function solicitar_passwd {
    param ([string]$mensaje)
    do {
        $securePasswd = Read-Host "Ingrese su password" -AsSecureString

        # Convertir SecureString a texto plano para depuración
        $passwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePasswd)
        )
        
        Write-Host "Password ingresada (solo para prueba): $passwd"

        if (-not (validar_password $passwd)) {
            Write-Host "Password no valida. Intenta de nuevo." -ForegroundColor Red
        }
    } until (validar_password $passwd)

    return $passwd
}
