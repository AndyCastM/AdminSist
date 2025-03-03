function generar_passwd(){
    param (
        [int]$Longitud = 12
    )

    # Definir los caracteres permitidos
    $mayusculas = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $minusculas = "abcdefghijklmnopqrstuvwxyz"
    $numeros = "0123456789"
    $simbolos = "@#$%^&*-_=+!"

    # Asegurar que la contraseña tenga al menos un carácter de cada tipo
    $password = (Get-Random -InputObject $mayusculas) +
                (Get-Random -InputObject $minusculas) +
                (Get-Random -InputObject $numeros) +
                (Get-Random -InputObject $simbolos)

    # Completar el resto de la contraseña con una mezcla aleatoria
    $todosCaracteres = $mayusculas + $minusculas + $numeros + $simbolos
    for ($i = 4; $i -lt $Longitud; $i++) {
        $password += Get-Random -InputObject $todosCaracteres
    }

    # Mezclar la contraseña para evitar patrones predecibles
    -join ($password.ToCharArray() | Get-Random -Count $Longitud)
}

# Generar una contraseña segura de 12 caracteres
$contraSegura = generar_passwd
Write-Output "Contraseña generada: $contraSegura"
