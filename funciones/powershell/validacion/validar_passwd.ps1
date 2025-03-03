function validar_password {
    param (
        [string]$Contrasena,
        [int]$LongitudMinima = 8  # Ajustable según requisitos
    )

    Write-Host "Validando password: $Contrasena" -ForegroundColor Yellow  # Depuración

    # Expresión regular para validar:
    # - Al menos una letra mayúscula
    # - Al menos una letra minúscula
    # - Al menos un número
    # - Al menos un carácter especial (@#$%^&*-_=+!)
    # - Longitud mínima especificada
    $regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&:]{8,15}$"

    return $Contrasena -match $regex
}